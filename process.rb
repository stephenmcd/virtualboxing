
# Fork and run the given block for the given number of processes.
def process(description, processes)
  puts "Starting: #{description}"
  start = Time.now
  processes.times { |i| fork { yield i } }
  processes.times { Process.wait }
  delta = ((Time.now - start) * 10**2).round.to_f / 10**2
  puts "#{description} took #{delta} seconds to run"
end

