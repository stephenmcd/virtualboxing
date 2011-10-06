
# Fork and run the given block for the given number of processes.
def process(description, processes)
  puts "Starting: #{description}"
  start = Time.now
  processes.times { |i| fork { yield i } }
  processes.times { Process.wait }
  puts "#{description} took #{(Time.now - start).round.to_f / 10**2} seconds to run"
end

