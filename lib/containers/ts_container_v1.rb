require 'trade_systems/trade_system_v1'

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
    trade_systems = (@matrix_db.find({name:ts_name}) || []).to_a
    return trade_systems if !trade_systems.empty?

    trade_systems = TradeSystemV1.create_inputs
    trade_systems.each_with_index do |ts, i|
      ts[:tsId] = i
      ts[:name] = ts_name
    end
    @matrix_db.on("trade_systems").insert_many(trade_systems)
    trade_systems
  end

  def start
    TradeSystemV1.new.clear_simulation_fields
    @matrix_db.close
  end
end
