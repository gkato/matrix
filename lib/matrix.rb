require 'parallel'
require 'date'

require_relative "../lib/inputs"
require_relative "../lib/data_loader"
require_relative "../lib/reporter"
require_relative "../lib/strategy"

class Matrix

  def create_posssibilities
    stops = (1..5).to_a
    start = (1..5).to_a
    gain_1 = (1..5).to_a
    gain_2 = (5..8).to_a
    total_loss = [-100, -150, -200, -250]
    total_gain = [100, 150, 200, 250]
    breakeven = [true, false]
    one_shot = [true, false]

    possibilities = Inputs.combine_arrays(gain_1, gain_2, :gain_1, :gain_2)
    possibilities = Inputs.combine_array_map(stops, possibilities, :start)
    possibilities = Inputs.combine_array_map(start, possibilities, :stop)
    possibilities = Inputs.combine_array_map(total_gain, possibilities, :total_gain)
    possibilities = Inputs.combine_array_map(total_loss, possibilities, :total_loss)
    possibilities = Inputs.combine_array_map(breakeven, possibilities, :breakeven)
    possibilities = Inputs.combine_array_map(one_shot, possibilities, :one_shote)

    possibilities.each_with_index { |poss, i| poss[:possId] = i }
    possibilities
  end

  def start
    matrix_db = MatrixDB.new(['localhost'], database:"matrix")
    possibilities = matrix_db.on(:possibilities).find({}).to_a

    if possibilities.empty?
      possibilities = create_posssibilities
      matrix_db.on(:possibilities).insert_many(possibilities)
    end

    #possibilities = [{possId:"current", :breakeven=>true,:total_loss=>-100, :total_gain=>250, :stop=>4, :start=>3, :gain_1=>4, :gain_2=>5, one_shot:true}]

    trading_days = DataLoader.fetch_trading_days("WDO")

    poss_size = possibilities.size
    days = trading_days.size
    puts "Existem #{possibilities.size} possibilidades e #{trading_days.size} dia(s). Total is #{poss_size * days}"

    start = Time.now
    Parallel.each(trading_days, in_threads: 10) do |file|
      data_loader = DataLoader.new(hosts:['localhost'], database:"matrix")
      result_db = MatrixDB.new(['localhost'], database:"matrix")

      day = data_loader.load(file)
      results = []
      formated_date = day[:tt].first[:date].strftime("%d/%m/%Y")

      Parallel.each(possibilities, in_threads: 20) do |poss|
        strategy = Strategy.new(poss, 10, 11, day[:tt], day[:openning], formated_date)
        strategy.visual = false
        result = strategy.run_strategy

        result_db.on(:results).insert_one({ possId:poss[:possId], date:formated_date, net:result })
      end

      data_loader.close
      result_db.close
    end
    finish = Time.now
    diff = finish - start

    puts "Tooks #{diff}ms"

    puts "Preparing results.."

    possibilities.each do |poss|
      poss[:per_day] = (matrix_db.on(:results).find({possId:poss[:possId]}) || []).to_a
      poss[:net] = 0
      poss[:per_day].each do |per_day|
        poss[:net] += per_day[:net]
      end
    end
    matrix_db.close
    Reporter.by_possibility(possibilities)
    puts ""
  end
end
