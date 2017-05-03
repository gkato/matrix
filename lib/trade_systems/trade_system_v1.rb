require './lib/models/matrix_db'

class TradeSystemV1
  attr_accessor :strat_equity, :index, :n_days, :start_date, :matrix_db, :tsId, :visual, :name, :first_date

  def initialize(strat_equity, opts)
    @strat_equity = strat_equity
    @index = opts[:index]
    @n_days = opts[:n_days]
    @stop = opts[:stop]
    @start_date = opts[:start_date]
    @tsId = opts[:tsId]
    @matrix_db = MatrixDB.new
    @name = opts[:name]
    @visual = opts[:visual] || true
    @initial_index = opts[:initial_index]
  end

  def log(msg)
    return if !@visual
    puts "[tsId:#{@tsId}] #{msg}"
  end

  def get_index(previous_date)
    return @initial_index if (@initial_index && previous_date < @start_date && @initial_index < @index)
    return @index
  end

  def get_possibility_by_rule(opt={})
    start_date = opt[:start_date]
    start_date = @start_date if strat_equity.nil?
    previous_date = start_date - @n_days
    results = @matrix_db.on(:results).find({strategy_name:@strat_equity, date: {"$gte":previous_date, "$lte":start_date}}).to_a
    index = get_index(previous_date)

    result_net = {}
    (results.to_a || []).each do |result|
      possId = result[:possId]
      if result_net[possId].nil?
        result_net[possId] = {possId:possId, net:0, win_days:0, loss_days:0, total_win:0, total_loss:0, even_days:0}
      end
      if result[:net] > 0
        result_net[possId][:win_days] += 1
        result_net[possId][:total_win] += result[:net]
      elsif result[:net] < 0
        result_net[possId][:loss_days] += 1
        result_net[possId][:total_loss] += result[:net]
      elsif result[:net] < 0
      else
        result_net[possId][:even_days] += 1
      end
      result_net[possId][:net] += result[:net]
    end

    result_net.values.sort do |a,b|
      profit_factor_a = a[:win_days] > 0 ? a[:total_win]/a[:win_days] : 0
      profit_factor_b = b[:win_days] > 0 ? b[:total_win]/b[:win_days] : 0

      if a[:net] != b[:net]
        a[:net] <=> b[:net]
      elsif profit_factor_a != 0 && profit_factor_b != 0
        profit_factor_a <=> profit_factor_b
      else
        a[:total_win] <=> b[:total_win]
      end
    end.last(index).first
  end

  def next_result_for(possId, date)
    query = {strategy_name:@strat_equity, date: date , possId:possId}
    (@matrix_db.on(:results).find(query) || []).to_a.first
  end

  def get_last_date
    result = @matrix_db.on(:results).find({strategy_name:strat_equity}).sort({date:-1}).limit(1).first()
    if result
      d = result[:date]
      return DateTime.strptime("#{d.day}/#{d.month}/#{d.year}", "%d/%m/%Y")
    end
  end

  def fetch_all_simulations
    (@matrix_db.on(:ts_results).find({tsId:@tsId,name:@name}) || []).to_a
  end

  def possibility_discover(stop_limit, poss, date)
    return poss if stop_limit
    get_possibility_by_rule(start_date:date)
  end

  def simulate
    current_date = @start_date
    last_date = get_last_date
    log "INICIO simulação, data início #{@start_date.strftime("%d/%m/%Y")}, data fim #{last_date.strftime("%d/%m/%Y")} - index: #{@index}, n_days: #{@n_days}, stop: #{@stop}, initial_index: #{@initial_index}"

    net = 0
    result = nil
    poss = nil
    stop_sequence = 0

    (fetch_all_simulations || []).sort {|a,b| a[:date]<=>b[:date]}.each do |simulation|
      result = {net:simulation[:net]}
      poss = {possId:simulation[:possId]}
      net += simulation[:net]
      d = simulation[:date]
      date = DateTime.strptime("#{d.day}/#{d.month}/#{d.year}", "%d/%m/%Y")

      if simulation[:net] < 0
        stop_sequence += 1
        if stop_sequence > @stop
          stop_sequence = 0
          poss = nil
        end
      else
        stop_sequence = 0
      end

      current_date = date if date > current_date
    end

    while current_date < last_date
      keep_poss = stop_sequence <= @stop && !poss.nil?
      poss = possibility_discover(keep_poss, poss, current_date)
      stop_sequence = 0 if stop_sequence > @stop

      if poss
        result = next_result_for(poss[:possId], current_date+1)
        if result
          if result[:net] < 0
            stop_sequence += 1
          else
            stop_sequence = 0
          end
          net += result[:net]

          log "  - Para o dia #{current_date.strftime("%d/%m/%Y")} - Melhor poss: #{poss[:possId]}, Resultado D+1: #{result[:net]} - Net periodo: #{net}"

          matrix_db.on(:ts_results).insert_one({tsId:@tsId, net:result[:net], possId:poss[:possId], date:current_date+1, name:@name})
        end
      end

      current_date = current_date + 1
    end
    next_poss= possibility_discover(stop_sequence <= @stop, poss, current_date)

    clear_simulation_fields

    log "FIM simulaçao - Net total:#{net} - poss recomendada: #{next_poss[:possId]}"
    {tsId:@tsId, net:net, next_poss:next_poss[:possId], name:@name}
  end

  def clear_simulation_fields
    @matrix_db.close if @matrix_db
  end

  def self.create_inputs
    index = (1..10).to_a
    n_days = (3..30).to_a
    stop = (1..4).to_a
    #initial_index = (1..5).to_a
    #initial_index << nil

    possibilities = Inputs.combine_arrays(index, n_days, :index, :n_days)
    possibilities = Inputs.combine_array_map(stop,     possibilities, :stop)
    #possibilities = Inputs.combine_array_map(initial_index, possibilities, :initial_index)
    possibilities.delete_if do |poss|
      if poss[:initial_index]
        poss[:initial_index] >= poss[:index]
      end
    end
    possibilities
  end
end
