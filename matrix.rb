require 'byebug'
require 'parallel'
require File.join(File.dirname(__FILE__), '.', 'data_loader')
require File.join(File.dirname(__FILE__), '.', 'tt')
require File.join(File.dirname(__FILE__), '.', 'reporter')
require File.join(File.dirname(__FILE__), '.', 'strategy')
require File.join(File.dirname(__FILE__), '.', 'inputs')

def format_date(date)
  day = date.day
  month = date.month

  day = "0#{day}" if day.to_s.size == 1
  month = "0#{month}" if month.to_s.size == 1

  "#{day}/#{month}/#{date.year}"
end

full_historic = DataLoader.load_data(11, 50)
possibilities = Inputs.generate_inputs

poss_size = possibilities.size
days = full_historic.size
puts "Existem #{possibilities.size} possibilidades e #{full_historic.size} dia(s). Total is #{poss_size * days}"

results_per_day = {}
start = Time.now
Parallel.each(full_historic.values, in_threads: days) do |day|
  results = []
  formated_date = format_date(day[:tt].first.date)

  #Parallel.each(possibilities, in_threads: 20) do |poss|
  possibilities.each do |poss|
    strategy = Strategy.new(poss, 10, 11, day[:tt], day[:openning], formated_date)
    result = strategy.run_stategy

    results << result
  end
  results.sort! { |a,b| a[:net] <=> b[:net] }
  date = day[:tt].first.date
  results_per_day[formated_date] = results

end
finish = Time.now
diff = finish - start

puts "Tooks #{diff}ms"

#Reporter.report(results_per_day)
Reporter.by_possibility(possibilities)
debugger
puts ""
