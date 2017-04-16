require_relative '../trade_systems/trade_system_v1'

class TSContainerV1

  attr_accessor :matrix_db

  def initialize
    @matrix_db = MatrixDB.new
  end

  def tradesystem_infos(ts_name)
    infos = ts_name.scan(/^ts_(.*_v\d)_([A-Z]+)$/).flatten
    {name:ts_name, strategy_name:infos[0], strat_equity:"#{infos[0]}_#{infos[1]}", equity:infos[1]}
  end

  def create_trade_systems(ts_name)
    trade_systems = (@matrix_db.on("trade_systems").find({name:ts_name}) || []).to_a
    return trade_systems if !trade_systems.empty?

    trade_systems = TradeSystemV1.create_inputs
    trade_systems.each_with_index do |ts, i|
      ts[:tsId] = i
      ts[:name] = ts_name
    end
    @matrix_db.on("trade_systems").insert_many(trade_systems)
    trade_systems
  end

  def first_day_strat_equity(strat_equity)
    result = @matrix_db.on("results").find({strategy_name:strat_equity}).sort({date:1}).limit(1).first()
    if result
      d = result[:date]
      return DateTime.strptime("#{d.day}/#{d.month}/#{d.year}", "%d/%m/%Y")
    end
  end

  def start(ts_name)
    ts_infos = tradesystem_infos(ts_name)
    possibilities = create_trade_systems(ts_name)
    start_date = first_day_strat_equity(ts_infos[:strat_equity])

    results = []
    possibilities.each do |poss|
      opts = {start_date:start_date, index:poss[:index], n_days:poss[:n_days], tsId:poss[:tsId], name:ts_name, stop:poss[:stop]}
      trade_system = TradeSystemV1.new(ts_infos[:strat_equity], opts)
      results << trade_system.simulate
      trade_system.clear_simulation_fields
    end
    results.sort {|a,b| a[:net] <=> b[:net] }.each do |result|
      puts result
    end
    @matrix_db.close
  end
end
