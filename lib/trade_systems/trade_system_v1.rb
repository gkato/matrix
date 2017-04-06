require './lib/models/matrix_db'

class TradeSystemV1
  attr_accessor :strat_equity, :index, :n_days, :start_date, :matrix_db

  def initialize(strat_equity, opts)
    @strat_equity = strat_equity
    @index = opts[:index]
    @n_days = opts[:n_days]
    @start_date = opts[:start_date]
    @matrix_db = MatrixDB.new
  end

  def get_possibility_by_rule(opt={})
    start_date = opt[:start_date]
    start_date = @start_date if strat_equity.nil?
    end_date = start_date + @n_days
    results = @matrix_db.on(:results).find({strategy_name:@strat_equity, date: {"$gte":start_date, "$lte":end_date}}).to_a

    result_net = {}
    (results.to_a || []).each do |result|
      possId = result[:possId]
      if result_net[possId].nil?
        result_net[possId] = {possId:possId, net:0}
      end
      result_net[possId][:net] += result[:net]
    end

    result_net.values.sort { |a,b| a[:net] <=> b[:net] }.last(@n_days).first
  end
end
