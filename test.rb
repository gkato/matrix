require 'byebug'
require 'parallel'
require File.join(File.dirname(__FILE__), '.', 'data_loader')
require File.join(File.dirname(__FILE__), '.', 'tt')
require File.join(File.dirname(__FILE__), '.', 'reporter')
require File.join(File.dirname(__FILE__), '.', 'strategy')
require File.join(File.dirname(__FILE__), '.', 'inputs')


full_historic = DataLoader.load_data(11, 50)
possibilities = Inputs.generate_inputs.first(5)

poss_size = possibilities.size
days = full_historic.size
puts "Existem #{possibilities.size} possibilidades e #{full_historic.size} dia(s). Total is #{poss_size * days}"

total_results = {}
Parallel.each(full_historic.values, in_threads: days) do |day|
  results = []
  possibilities.each do |poss|
    strategy = Strategy.new(poss, 10, 11, day[:tt], day[:openning])
    results << strategy.run_stategy
  end
  results.sort! { |a,b| a[:net] <=> b[:net] }
  date = day[:tt].first.date
  total_results["#{date.day}/#{date.month}"] = results

end

debugger
Reporter.report(total_results)
