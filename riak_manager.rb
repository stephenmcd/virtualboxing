require 'riak/client'
require './process'


# Implements methods for controlling Riak on VirtualBox instances.
module Riak
  # Starts Riak on each of the given VMs, and waits until
  # the ping command returns a valid response.
  def Riak.start(*vms)
    vms.each { |vm| vm.run("riak start") }
    vms.each { |vm| vm.run("riak ping") { |out| out =~ /pong/m } }
  end

  # Stops Riak on each of the given VMs.
  def Riak.stop(*vms)
    vms.each { |vm| vm.run("riak stop") }
  end

  # Fills Riak with data for the given host.
  def Riak.fill(options)
    process(options[:description], options[:processes]) do |i|
      connection = Riak::Client.new(:host => options[:host], :protocol => "pbc")
      bucket = connection.bucket i.to_s
      options[:records].times do |n|
        item = bucket.get_or_new n.to_s
        item.content_type = "text/json"
        item.data = {
          "name" => "name-#{rand(100)}",
          "email" => "email-#{n}",
        }
        item.store
      end
    end
  end

  # Starts Riak on the given VMs, and joins all other than the first
  # to the first VM.
  def Riak.start_cluster(vms)
    Riak.start *vms
    vms[1..-1].each { |vm| vm.run("riak-admin join riak@#{vms.first.host}") }
    vms.first.run("riak-admin member_status") do |out|
      # member_status will report all nodes as valid once they've
      # joined but are still moving data. The pending column for each
      # node will show "--" once all data is moved, so check for the
      # correct number of occurences of it also.
      out =~ /Valid:#{vms.size}/m && out.split(" -- ").size == vms.size + 1
    end
  end

  # Starts Riak on the given VMs, and tells all other than the first
  # to leave the first.
  def Riak.stop_cluster(vms)
    Riak.start *vms
    vms[1..-1].each { |vm| vm.run("riak-admin leave") }
    vms.first.run("riak-admin member_status") do |output|
      output =~ /Valid:1 \/ Leaving:0/m
    end
  end
end
