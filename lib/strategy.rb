class Strategy

  attr_accessor :stop, :gains, :start, :current, :openning, :position,
                :position_size, :tic_val, :net, :limit_time, :historic, :poss,
                :position_val, :allowed, :total_loss, :total_gain, :last,
                :formated_date, :visual, :breakeven, :one_shot, :qty_trades

  def initialize(possibility, tic_value, time, hist, openning, formated_date)

    @stop = possibility[:stop]
    @gains = possibility.select {|k,v| k.to_s =~ /^gain_\d+$/ }.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    @start = possibility[:start]
    @total_loss = possibility[:total_loss]
    @total_gain = possibility[:total_gain]
    @breakeven = possibility[:breakeven]
    @one_shot = possibility[:one_shot]
    @position_size = 0
    @current = nil
    @last = nil
    @openning = openning
    @position = :liquid
    @tic_val = tic_value
    @net = 0
    @qty_trades = 0
    @limit_time = time
    @historic = hist
    @formated_date = formated_date
    @visual = false
    @allowed = true
  end

  def debug(line)
    puts line if visual
  end

  def was_last_tt?
    (@position == :liquid && @current.date.hour >= @limit_time) || risky? || exit_on_one_shot?
  end

  def risky?
    return @net >= @total_gain || @net <= @total_loss
  end

  def exit_on_one_shot?
    return @one_shot && qty_trades > 0 && @position == :liquid
  end

  def enter_position(position_type)
    return if risky?

    @position = position_type
    @position_val = @current.value
    @position_size = gains.size
    @allowed = false
    @qty_trades += 1
    debug "ENTROU na posição lado: #{@position} - preco #{@position_val} - horario #{@current.date.hour}:#{@current.date.minute}"
  end

  def close_position
    @position_size = 0
    @position_val = nil
    @position = :liquid
  end

  def take_profit(factor=nil)
    profit = (@current.value - @position_val).abs * @tic_val
    profit = profit * factor if factor

    @net += profit
    @position_size -= 1 if @position_size > 0
    debug  "   Take profit net #{@net} - preco #{@current.value} - horario #{@current.date.hour}:#{@current.date.minute}"
  end

  def take_loss(flip=false,factor=nil)
    last_position = @position

    spread = (@position_val - @current.value).abs * @tic_val
    loss = (spread * @position_size).abs
    if factor
      loss = 0
      factor.each do |key, mult|
        loss += spread * mult
      end
    end

    @net -= loss
    close_position

    debug "   STOP net #{@net} - preco #{@current.value} - horario #{@current.date.hour}:#{@current.date.minute}"
    return if !flip
    if(@current.date.hour < @limit_time && !@one_shot)
      debug "   Fliping"
      enter_position(:long) if(last_position == :short)
      enter_position(:short) if(last_position == :long)
    end
  end

  def ensure_breakeven
    debug "   Breakeven activated contract on #{@position_val}"
    take_loss(false)
  end

  def run_strategy
    #implement strategy
  end

  def self.create_inputs
    []
  end
end
