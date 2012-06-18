Virtual Boxing
==============

Created by [Stephen McDonald](http://twitter.com/stephen_mcd)

virtualboxing is a set of utilities for comparing timings on bulk
operations across various databases in a distributed environment. It
consists of routines for controlling multiple [VirtualBox][1] instances
and implementations of some initial operations for [MongoDB][2] and
[Riak][3].

Disclaimer
----------

The benchmarking performed by virtualboxing is in no way scientific
or conclusive. It was created for the purpose of exploring distributed
database setups, their libraries and comparing operations.

Setup
-----

Getting everything set up involves creating a VirtualBox VM, configuring
it and then cloning it for as many instances as you'd like to use.
Some manual configuration of each instance is also required. Here are
the steps involved with [Ubuntu][4] used as the VM's OS:

1. Create an initial VirtualBox VM
2. Install Ubuntu
3. Install [VirtualBox Guest Additions][4]
4. Configure [key-based SSH authentication][5]
5. [Install MongoDB][6]
6. [Install Riak][7]

Once your base VM is set up, clone its hard disk and create a new VM for
each hard disk for as many extra VMs as you'd like to use.

    $ cd ~/.VirtualBox/HardDisks/
    $ VBoxManage clonehd original.vdi another.vdi

You'll then need to configure the host names for Riak on each VM. This
should be as simple adding the host name as the node name in
`/etc/riak/vm.args`. For example if the host's IP is 192.168.1.80:

    -name riak@192.168.1.80

and as the host for HTTP and Protocol Buffers in `/etc/riak/app.config`:

    {http, [ {"192.168.1.80", 8098 } ]},

    ...

    {pb_ip,   "192.168.1.80" }

It's also recommended to SSH once onto each VM so that you can be
prompted to add the VM to your known hosts on your host machine.

Configuration
-------------

All configuration is provided via `config.yml`. The main configuration
required is each of the VM names (as entered when creating the VMs in
VirtualBox Manager) and IP addresses for each VM. Here's the example
`config.yml` provided:

    # VirtualBox VM names mapped to their IP addresses.
    vms:
      Ubuntu Green:  192.168.1.80
      Ubuntu Red:    192.168.1.81
      Ubuntu Blue:   192.168.1.70

    # SSH username for each of the VMS. SSH key authentication is assumed.
    ssh-user: steve

    # Number of processes to fork when benchmarking.
    processes: 10

    # Number of records to create PER PROCESS when filling with data.
    records: 10000

    # Database name to use for Mongo.
    mongo-db-name: steve

Running
-------

Ensure you have the required Ruby libraries installed using [Bundler][8]:

    $ bundle install

Actual run-time occurs via the `run.rb` script:

    $ ./run.rb

Whilst running, of particular interest will be the `riak-admin member_status`
command on the first node. Combined with `watch` you can monitor the
Riak cluster as it forms and is torn down:

    $ ssh steve@192.168.1.80
    $ watch -n .2 riak-admin member_status

Next Steps
----------

The following list of items are suggested for further exploration:

* Trial different database configurations, particularly for MongoDB
  which is renowned for fast yet unsafe defaults
* Use a load balancer as the entry point for connecting to the
  Riak cluster
* Set up MongoDB Replica Sets
* Benchmark different [storage backends for Riak][9]
* Benchmark existing test with indexes created
* Benchmark searching
* Benchmark deleting

[1]: http://www.virtualbox.org/
[2]: http://www.mongodb.org/
[3]: http://wiki.basho.com/Riak.html
[4]: http://www.virtualbox.org/manual/ch04.html#idp11274368
[5]: http://www.laubenheimer.net/ssh-keys.shtml
[6]: http://www.mongodb.org/display/DOCS/Quickstart+Unix
[7]: http://wiki.basho.com/Installing-on-Debian-and-Ubuntu.html
[8]: http://gembundler.com/
[9]: http://wiki.basho.com/Storage-Backends.html
