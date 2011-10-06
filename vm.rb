require 'net/ssh'

# Represents each of the VirtualBox VMs with a name, host.
class VM
  def initialize(*options)
    @name, @host, @user = options
    @connected = false
  end
  attr_accessor :name, :host

  # Start the VM and wait until SSH is available using the given
  # username.
  def start
    stop
    sleep 2
    IO.popen "virtualbox --startvm '#{@name}'"
  end

  # Stop the VM.
  def stop
    #  begin
    #    ssh("sudo shutdown -h 0")
    #  rescue Errno::EHOSTUNREACH; end
    IO.popen "kill -9 `ps aux | grep 'startvm #{@name}' | grep -v grep | awk '{print $2}'`"
  end

  # Try to connect over SSH to the VM until successful.
  def connect
    begin
      Net::SSH.start @host, @user
    rescue
      retry
    end
    @connected = true
  end

  # Runs the given command over SSH. When a block is provided, it will
  # re-run the SSH command until the block returns true.
  def run(command, &block)
    connect unless @connected
    Net::SSH.start(@host, @user) do |ssh|
      out = ssh.exec! command
      run(command, &block) unless block.nil? or block.call out
    end
  end
end
