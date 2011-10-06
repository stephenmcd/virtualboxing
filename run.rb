require 'rubygems'
require 'yaml'
require './vm'
require './mongo_manager'
require './riak_manager'

# Set up vms, config and commands.
CONFIG = YAML.load(File.open(File.join(File.dirname(__FILE__), "config.yml")))
vms = CONFIG["vms"].map { |name, host| VM.new name, host, CONFIG["ssh-user"] }

# Ensure all VMs are stopped, start them, and ensure all
# DBs and clusters are stopped.
puts "Starting: VMs"
vms.each { |vm| vm.start }
puts "Stopping: Riak Cluster"
Riak.stop_cluster vms
Riak.stop *vms
Mongo.stop *vms

# Start Mongo on the first VM and fill it with data.
Mongo.start vms.first
Mongo.fill "Create Mongo Collections with a single node",
            CONFIG["processes"],
            CONFIG["records"],
            vms.first.host,
            CONFIG["mongo-db-name"]

# Stop Mongo and start Riak on the first VM, and fill Riak with data.
Mongo.stop vms.first
Riak.start vms.first
Riak.fill "Create Riak Buckets with a single node",
           CONFIG["processes"],
           CONFIG["records"],
           vms.first.host

# Start the Riak Cluster and fill it with data.
puts "Starting: Riak Cluster"
Riak.start_cluster vms
Riak.fill "Create Riak Buckets with #{vms.size} node",
           CONFIG["processes"],
           CONFIG["records"],
           vms.first.host
puts "Stopping: Riak Cluster"
Riak.stop_cluster vms

# Wait for the user to confirm exit, and kill the VMs.
puts "Finished. Keep VMs running? (y/N)"
vms.each { |vm| vm.stop } unless gets =~ /y/i
