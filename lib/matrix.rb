require 'parallel'
require 'date'
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

  def start
    ### Possibilities
    stops = (1..5).to_a
    start = (1..5).to_a
    gain_1 = (1..5).to_a
    gain_2 = (5..8).to_a
    total_loss = [-100, -150, -200, -250]
    total_gain = [100, 150, 200, 250]
    breakeven = [true, false]
    extra = {net:0, stops:0, gains:0, per_day:[]}

    possibilities = Inputs.combine_arrays(gain_1, gain_2, :gain_1, :gain_2)
    possibilities = Inputs.combine_array_map(stops, possibilities, :start)
    possibilities = Inputs.combine_array_map(start, possibilities, :stop)
    possibilities = Inputs.combine_array_map(total_gain, possibilities, :total_gain)
    possibilities = Inputs.combine_array_map(total_loss, possibilities, :total_loss)
    possibilities = Inputs.combine_array_map(breakeven, possibilities, :breakeven)

    #possibilities = [{:breakeven=>true,:total_loss=>-100, :total_gain=>250, :stop=>4, :start=>3, :gain_1=>4, :gain_2=>5}]

    full_historic = DataLoader.load_data("WDO", 20)

    poss_size = possibilities.size
    days = full_historic.size
    puts "Existem #{possibilities.size} possibilidades e #{full_historic.size} dia(s). Total is #{poss_size * days}"

    start = Time.now
    Parallel.each(full_historic.values, in_threads: days) do |day|
      results = []
      formated_date = day[:tt].first.date.strftime("%d/%m/%Y")

      possibilities.each do |poss|
        poss.merge!({net:0, stops:0, gains:0, per_day:[]}) if poss[:per_day].nil?

        strategy = Strategy.new(poss, 10, 11, day[:tt], day[:openning], formated_date)
        strategy.visual = false
        result = strategy.run_strategy

        poss[:net] += result if result
        poss[:per_day] << {date:formated_date, net:result}

      end

    end
    finish = Time.now
    diff = finish - start

    puts "Tooks #{diff}ms"

    Reporter.by_possibility(possibilities)
    puts ""
  end
end
