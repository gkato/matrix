require 'parallel'
require 'date'

require_relative "../lib/inputs"
require_relative "../lib/data_loader"
require_relative "../lib/reporter"
require_relative "../lib/strategies/opening_v1"

class Matrix

  def start(opts={})
    strategy_name = opts[:strategy_name] || "opening_v1"
    equity = opts[:equity] || "WDO"
    threads_days = opts[:threads_days] || 10
    threads_poss = opts[:threads_poss] || 20
    visual = opts[:visual] || false
    ticval = opts[:tic_val] || 10
    time_limit = opts[:time_limit] || 11
    allowed_days = opts[:trading_days] || []

    strategy_clazz = Object.const_get(strategy_name.split('_').collect(&:capitalize).join)
    matrix_db = MatrixDB.new(['localhost'], database:"matrix")

    strat_equity = "#{strategy_name}_#{equity}"
    possibilities = create_posssibilities(matrix_db, strat_equity)

    trading_days = DataLoader.fetch_trading_days(equity)
    trading_days = trading_days.select { |file| allowed_days.empty? || allowed_days.include?(date_from_file(file, equity)) }

    puts "Processando dias #{trading_days}" if !allowed_days.empty?

    poss_size = possibilities.size
    days = trading_days.size
    puts "Existem #{possibilities.size} possibilidades e #{trading_days.size} dia(s). Total is #{poss_size * days}"

    start = Time.now
    Parallel.each(trading_days, in_threads: 1) do |file|
      data_loader = DataLoader.new(hosts:['localhost'], database:"matrix")
      result_db = MatrixDB.new(['localhost'], database:"matrix")

      formated_date = date_from_file(file, equity)
      done_possibilities = (result_db.on(:results).find({strategy_name:strat_equity, date:formated_date}) || []).to_a

      if done_possibilities.size != possibilities.size
        done_ids = done_possibilities.map {|i| i[:possId]}
        poss_to_process = possibilities.select {|i| !done_ids.include?(i[:possId])}

        if(poss_to_process.size != possibilities.size)
          puts "Resuming processing for day #{formated_date}, #{poss_to_process.size} reamaining..."
        end

        day = data_loader.load(file)
        formated_date = day[:tt].first[:date].strftime("%d/%m/%Y")

        Parallel.each(poss_to_process, in_threads: 1) do |poss|
          strategy = strategy_clazz.new(poss, ticval, time_limit, day[:tt], day[:openning], formated_date)
          strategy.visual = visual
          result = strategy.run_strategy

          result_db.on(:results).insert_one({ possId:poss[:possId], date:formated_date, net:result, strategy_name:poss[:name] })
        end
      end

      data_loader.close
      result_db.close
    end
    diff = Time.now- start
    puts "Tooks #{diff}ms"

    prepare_results(possibilities, matrix_db, strat_equity)

    matrix_db.close
  end

  def date_from_file(file, equity)
    file.scan(/#{equity}.*_Trade_(.*)\.csv/).flatten.first.gsub("-","/")
  end

  def get_strategy_class(strategy_name)
    Object.const_get(strategy_name.gsub(/_(WDO|WIN)/,'').split('_').collect(&:capitalize).join)
  end

  def run_results(strat_equity, opts={})
    matrix_db = MatrixDB.new(['localhost'], database:"matrix")

    possibilities = create_posssibilities(matrix_db, strat_equity)
    possibilities = possibilities.find_all {|poss| poss[:possId] == opts[:possId]  } if opts[:possId]
    #possibilities = [{possId:"current", :breakeven=>true,:total_loss=>-100, :total_gain=>250, :stop=>4, :start=>3, :gain_1=>4, :gain_2=>5, one_shot:true}]
    prepare_results(possibilities, matrix_db, strat_equity)

    matrix_db.close
  end

  def create_posssibilities(matrix_db, strat_equity)
    possibilities = (matrix_db.on(:possibilities).find({"name":strat_equity}) || []).to_a

    if possibilities.empty?
      possibilities = get_strategy_class(strat_equity).create_inputs
      possibilities.each_with_index do |poss, i|
        poss[:possId] = i
        poss[:name] = strat_equity
      end

      matrix_db.on(:possibilities).insert_many(possibilities)
    end
    possibilities
  end

  def prepare_results(possibilities, matrix_db, strat_equity)
    puts "Preparing results.."

    possibilities = (possibilities || []).to_a
    possibilities.each do |poss|
      poss[:per_day] = (matrix_db.on(:results).find({strategy_name:strat_equity, possId:poss[:possId]}) || []).to_a
      poss[:net] = 0
      poss[:per_day].each do |per_day|
        poss[:net] += per_day[:net]
      end
    end
    Reporter.by_possibility(possibilities)
  end
end
