require 'mongo'
require './process'

# Implements methods for controlling Mongo on VirtualBox instances.
module Mongo
  # Starts Mongo on each of the given VMs.
  def Mongo.start(*vms)
    vms.each { |vm| vm.run("sudo service mongodb start") }
    sleep 3 # TODO: Find a command we can run to check for Mongo being ready.
  end

  # Stops Mongo on each of the given VMs.
  def Mongo.stop(*vms)
    vms.each { |vm| vm.run("sudo service mongodb start") }
  end

  # Fills Mongo with data for the given host.
  def Mongo.fill(description, processes, records, host, db_name)
    process(description, processes) do |i|
      collection = Mongo::Connection.new(host).db(db_name)["0"]
      records.times do |n|
        collection.update({"_id" => n.to_s}, {
          "name" => "name-#{rand(100)}",
          "email" => "email-#{n}"
        })
      end
    end
  end
end

