require 'parallel'
require 'date'
require 'byebug'
#require 'data_loader'
#require 'tt'
#require 'reporter'
#require 'strategy'
#require 'inputs'

require_relative "../lib/inputs"
require_relative "../lib/data_loader"
require_relative "../lib/reporter"
require_relative "../lib/strategy"

class Matrix
  def format_date(date)
    day = date.day
    month = date.month

    day = "0#{day}" if day.to_s.size == 1
    month = "0#{month}" if month.to_s.size == 1

    "#{day}/#{month}/#{date.year}"
  end

  def start
    ### Possibilities
    stops = (1..5).to_a
    start = (1..5).to_a
    gain_1 = (1..5).to_a
    gain_2 = (5..8).to_a
    total_loss = [-100, -150, -200, -250]
    total_gain = [100, 150, 200, 250]
    extra = {net:0, stops:0, gains:0, per_day:[]}

    possibilities = Inputs.combine_arrays(gain_1, gain_2, :gain_1, :gain_2)
    possibilities = Inputs.combine_array_map(stops, possibilities, :start)
    possibilities = Inputs.combine_array_map(start, possibilities, :stop)
    possibilities = Inputs.combine_array_map(total_gain, possibilities, :total_gain)
    possibilities = Inputs.combine_array_map(total_loss, possibilities, :total_loss, extra)

    full_historic = DataLoader.load_data(11, 50, "WDO", 10)

    poss_size = possibilities.size
    days = full_historic.size
    puts "Existem #{possibilities.size} possibilidades e #{full_historic.size} dia(s). Total is #{poss_size * days}"

    results_per_day = {}
    start = Time.now
    Parallel.each(full_historic.values, in_threads: days) do |day|
      results = []
      formated_date = day[:tt].first.date.strftime("%d/%m/%Y")

      #Parallel.each(possibilities, in_threads: 20) do |poss|
      possibilities.each do |poss|
        strategy = Strategy.new(poss, 10, 11, day[:tt], day[:openning], formated_date)
        result = strategy.run_strategy

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
  end
end
