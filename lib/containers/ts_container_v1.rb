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

  def first_simulation_day_from(start_date)
    month = start_date.month
    first_day_next_month = start_date.next_day
    while month == first_day_next_month.month
      first_day_next_month = first_day_next_month.next_day
    end
    first_day_next_month
  end

  def build_ts_opts(ts_name, start_date, poss)
    opts = {start_date:start_date, index:poss[:index], n_days:poss[:n_days], tsId:poss[:tsId], name:ts_name, stop:poss[:stop]}
    opts.merge!({initial_index:poss[:initial_index]}) if poss[:initial_index]
    opts
  end

  def get_start_date(strat_equity)
    first_simulation_day_from(first_day_strat_equity(strat_equity))
  end

  def start(ts_name,opts={})
    ts_infos = tradesystem_infos(ts_name)

    possibilities = create_trade_systems(ts_name)
    possibilities.delete_if { |poss| poss[:tsId] != opts[:tsId] } if opts[:tsId]

    start_date = get_start_date(ts_infos[:strat_equity])

    results = []
    possibilities.each do |poss|
      opts = build_ts_opts(ts_name, start_date, poss)
      trade_system = TradeSystemV1.new(ts_infos[:strat_equity], opts)
      results << trade_system.simulate
      trade_system.clear_simulation_fields
    end
    results.sort {|a,b| a[:net] <=> b[:net] }.each do |result|
      puts result
    end
    @matrix_db.close
  end

  def show_ts_trace(tsId, ts_name)
    poss = (@matrix_db.on("trade_systems").find({tsId:tsId, name:ts_name}) || []).to_a.first
    return if poss.nil?

    ts_infos = tradesystem_infos(ts_name)
    start_date = first_day_strat_equity(ts_infos[:strat_equity])
    opts = build_ts_opts(ts_name, start_date, poss)
    trace = TradeSystemV1.new(ts_infos[:strat_equity], opts).fetch_all_simulations

    puts "Showing trace for simulatioin #{tsId} on #{ts_name}"
    net = 0
    trace.each do |result|
      puts result
      net += result[:net]
    end
    puts "Net do periodo: #{net}"
  end
end
