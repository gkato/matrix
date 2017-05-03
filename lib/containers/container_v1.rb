require 'parallel'
require 'date'

require_relative "../inputs"
require_relative "../data_loader"
require_relative "../reporter"
require_relative "../strategies/opening_v1"
require_relative "../strategies/opening_pullback_v1"
require_relative "../strategies/opening_pullback_v2"
require_relative "../strategies/opening_pullback_v3"

class ContainerV1

  def start(opts={})
    strategy_name = opts[:strategy_name] || "opening_v1"
    equity = opts[:equity] || "WDO"
    threads_days = opts[:threads_days] || 10
    threads_poss = opts[:threads_poss] || 20
    visual = opts[:visual] || false
    ticval = ticval_discover(equity)
    time_limit = opts[:time_limit] || 11
    allowed_days = opts[:trading_days] || []

    puts "Executando estratégia: #{strategy_name}, ativo #{equity}"

    strategy_clazz = Object.const_get(strategy_name.split('_').collect(&:capitalize).join)
    matrix_db = MatrixDB.new

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
      data_loader = DataLoader.new
      result_db = MatrixDB.new

      formated_date = date_from_file(file, equity)
      current_date = DateTime.strptime(formated_date, "%d/%m/%Y")
      done_possibilities = (result_db.on(:results).find({strategy_name:strat_equity, date:current_date}) || []).to_a

      if done_possibilities.size != possibilities.size
        done_ids = done_possibilities.map {|i| i[:possId]}
        poss_to_process = possibilities.select {|i| !done_ids.include?(i[:possId])}

        if(poss_to_process.size != possibilities.size)
          puts "Resuming processing for day #{formated_date}, #{poss_to_process.size} reamaining..."
        end

        day = data_loader.load(file)

        processed = []
        Parallel.each(poss_to_process, in_threads: 20) do |poss|
          strategy = strategy_clazz.new(poss, ticval, time_limit, day[:tt], day[:openning])
          strategy.visual = visual
          result = strategy.run_strategy

          processed << { possId:poss[:possId], date:current_date, net:result, strategy_name:poss[:name] }
        end
        result_db.on(:results).insert_many(processed)
      end

      data_loader.close
      result_db.close
    end
    diff = Time.now- start
    puts "Tooks #{diff}ms"

    matrix_db.close
  end

  def equity_from_strat(strat_equity)
    return nil if strat_equity.nil?
    strat_equity.scan(/.*(WIN|WDO)/).flatten.first rescue nil
  end

  def ticval_discover(equity="WDO")
    return 10 if equity.nil? || equity == "WDO"
    return 1 if equity == "WIN"
  end

  def date_from_file(file, equity)
    file.scan(/#{equity}.*_Trade_(.*)\.csv/).flatten.first.gsub("-","/")
  end

  def get_strategy_class(strategy_name)
    Object.const_get(strategy_name.gsub(/_(WDO|WIN)/,'').split('_').collect(&:capitalize).join)
  end

  def run_results(strat_equity, opts={})
    matrix_db = MatrixDB.new

    results_index = opts[:index] || 4
    possibilities = create_posssibilities(matrix_db, strat_equity)
    possibilities = possibilities.find_all {|poss| poss[:possId] == opts[:possId]  } if opts[:possId]

    prepare_results(possibilities, matrix_db, strat_equity) do |poss|
      query = {strategy_name:strat_equity, possId:poss[:possId]}
      start_date = opts[:start_date]
      end_date = opts[:end_date]
      query.merge!({date:{"$gte":start_date, "$lte":end_date}}) if (start_date && end_date)
      (matrix_db.on(:results).find(query) || []).to_a
    end
    Reporter.by_possibility(possibilities, results_index)
    matrix_db.close
  end

  def create_posssibilities(matrix_db, strat_equity)
    possibilities = (matrix_db.on(:possibilities).find({"name":strat_equity}) || []).to_a

    equity = equity_from_strat(strat_equity)
    if possibilities.empty?
      possibilities = get_strategy_class(strat_equity).create_inputs(equity)
      possibilities.each_with_index do |poss, i|
        poss[:possId] = i
        poss[:name] = strat_equity
      end

      matrix_db.on(:possibilities).insert_many(possibilities)
    end
    possibilities
  end

  def prepare_results(possibilities, matrix_db, strat_equity, &block)
    puts "Preparing results.."

    possibilities = (possibilities || []).to_a
    possibilities.each do |poss|
      poss[:per_day] = yield(poss)
      poss[:net] = 0
      poss[:per_day].each do |per_day|
        poss[:net] += per_day[:net]
      end
    end
  end
end
