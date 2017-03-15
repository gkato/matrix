class Strategy

  attr_accessor :stop, :gains, :start, :current, :openning, :position,
                :position_size, :tic_val, :net, :limit_time, :historic, :poss,
                :position_val, :allowed, :total_loss, :total_gain, :last,
                :formated_date, :visual, :breakeven, :one_shot, :qty_trades

  def initialize(possibility, tic_value, time, hist, openning, formated_date)

    self.stop = possibility[:stop]
    self.gains = possibility.select {|k,v| k.to_s =~ /^gain_\d+$/ }.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    self.start = possibility[:start]
    self.total_loss = possibility[:total_loss]
    self.total_gain = possibility[:total_gain]
    self.breakeven = possibility[:breakeven]
    self.one_shot = possibility[:one_shot]
    self.position_size = 0
    self.current = nil
    self.last = nil
    self.openning = openning
    self.position = :liquid
    self.tic_val = tic_value
    self.net = 0
    self.qty_trades = 0
    self.limit_time = time
    self.historic = hist
    self.formated_date = formated_date
    self.visual = false
    self.allowed = true
  end

  def debug(line)
    puts line if visual
  end

  def risky?
    return self.net >= self.total_gain || self.net <= self.total_loss
  end

  def exit_on_one_shot?
    return self.one_shot && qty_trades > 0 && self.position == :liquid
  end

  def enter_position(position_type)
    return if risky?

    self.position = position_type
    self.position_val = self.current.value
    self.position_size = gains.size
    self.allowed = false
    self.qty_trades += 1
    debug "ENTROU na posição lado: #{self.position} - preco #{self.position_val} - horario #{self.current.date.hour}:#{self.current.date.minute}"
  end

  def close_position
    self.position_size = 0
    self.position_val = nil
    self.position = :liquid
  end

  def take_profit
    self.net += (self.current.value - self.position_val).abs * self.tic_val
    self.position_size -= 1 if self.position_size > 0
    debug  "   Take profit net #{self.net} - preco #{self.current.value} - horario #{self.current.date.hour}:#{self.current.date.minute}"
  end

  def take_loss(flip=false)
    last_position = self.position
    self.net -= ((self.position_val - self.current.value).abs * self.tic_val * self.position_size).abs
    close_position

    debug "   STOP net #{self.net} - preco #{self.current.value} - horario #{self.current.date.hour}:#{self.current.date.minute}"
    return if !flip
    if(self.current.date.hour < self.limit_time)
      debug "   Fliping"
      enter_position(:long) if(last_position == :short)
      enter_position(:short) if(last_position == :long)
    end
  end

  def ensure_breakeven
    debug "   Breakeven second contract on #{self.position_val}"
    take_loss(false)
  end

  def run_strategy
    #implement strategy
  end
end
