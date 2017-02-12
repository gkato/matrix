class Strategy

  attr_accessor :stop, :gain_1, :gain_2, :start, :current, :openning, :position, :position_size, :tic_val, :net, :limit_time, :historic, :poss, :position_val, :allowed, :total_loss, :total_gain, :last, :formated_date

  def initialize(po, tic_value, time, hist, openning, formated_date)
    self.stop = po[:stop]
    self.gain_1 = po[:gain_1]
    self.gain_2 = po[:gain_2]
    self.start = po[:start]
    self.total_loss = po[:total_loss]
    self.total_gain = po[:total_gain]
    self.current = nil
    self.last = nil
    self.openning = openning
    self.position = :liquid
    self.position_size = 2
    self.tic_val = tic_value
    self.net = 0
    self.limit_time = time
    self.poss = po
    self.historic = hist
    self.formated_date = formated_date
  end

  def risky?
    return self.net >= self.total_gain || self.net <= self.total_loss
  end

  def enter_position(position_type)
    return if risky?

    self.position = position_type
    self.position_val = self.current.value
    self.position_size = 2

    #puts "ENTROU na posição lado: #{self.position} - preco #{self.position_val} - horario #{self.current.date.hour}:#{self.current.date.minute}"
  end

  def close_position
    self.position_size = 0
    self.position = :liquid
    self.allowed = false
  end

  def take_profit
    self.net += (self.current.value - self.position_val).abs * self.tic_val
    #puts "   Take profit net #{self.net} - preco #{self.current.value} - horario #{self.current.date.hour}:#{self.current.date.minute}"
  end

  def take_loss
    last_position = self.position
    self.net -= ((self.stop + self.start) * self.tic_val * self.position_size).abs
    close_position

    #puts "   STOP net #{self.net} - preco #{self.current.value} - horario #{self.current.date.hour}:#{self.current.date.minute}"
    if(self.current.date.hour < self.limit_time)
      enter_position(:long) if(last_position == :short)
      enter_position(:short) if(last_position == :long)
    end
  end

  def run_stategy
    self.allowed = true

    self.historic.each_with_index do |tt, i|
      self.last = self.current
      self.current = tt

      if ((self.position == :liquid && self.current.date.hour >= self.limit_time) || risky?)
        break
      end

      if(self.position == :liquid && !self.allowed)
        if (self.current.value >= self.openning && self.last.value < self.openning) ||
           (self.current.value <= self.openning && self.last.value > self.openning)

          self.allowed = true
        end
      end

      if (self.position == :liquid && self.current.value >= (self.openning + self.start) && self.allowed)
        enter_position :long
        next
      end

      if (self.position == :liquid && self.current.value <= (self.openning - self.start) && self.allowed)
        enter_position :short
        next
      end

      if(self.position == :long)

        if(self.current.value >= (self.position_val + self.gain_1) && self.position_size == 2) #contrato 1
          take_profit
          self.position_size = 1
        end

        if(self.current.value >= (self.position_val + self.gain_2) && self.position_size == 1) #contrato 2
          take_profit
          close_position
        end

        if(self.current.value <= (self.openning - self.stop))
          take_loss
        end
      end

      if(self.position == :short)

        if(self.current.value <= (self.position_val - self.gain_1) && self.position_size == 2) #contrato 1
          take_profit
          self.position_size = 1
        end

        if(self.current.value <= (self.position_val - self.gain_2) && self.position_size == 1) #contrato 2
          take_profit
          close_position
        end

        if(self.current.value >= (self.openning + self.stop))
          take_loss
        end
      end

    end
    #puts "Fim da execução Net: #{self.net} - horario #{self.current.date.hour} - position #{self.position} - setup: #{self.poss}"
    print "."
    result = {}

    self.poss[:net] += self.net
    self.poss[:per_day] << {date:self.formated_date, net:self.net}

    result[:net] = self.net
    result[:poss] = self.poss
    result
  end
end
