require './lib/strategy'
require './lib/inputs'

class OpeningPullbackV1 < Strategy

  def run_strategy
    self.allowed = true

    self.historic.each_with_index do |tt, i|
      self.last = self.current

      self.current = TT.new(tt[:date].to_datetime, tt[:value], tt[:qty], tt[:ask], tt[:bid], tt[:agressor])

      if ((self.position == :liquid && self.current.date.hour >= self.limit_time) || risky? || exit_on_one_shot?)
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

        if(self.current.value >= (self.position_val + self.gains[:gain_1]) && self.position_size == 2) #contrato 1
          take_profit
        end

        if(self.current.value >= (self.position_val + self.gains[:gain_2]) && self.position_size == 1) #contrato 2
          take_profit
          close_position
        end

        if(self.current.value <= (self.openning - self.stop))
          take_loss(true)
        end

        if(self.breakeven && self.position_size == 1 && (self.current.value <= self.position_val ))
          ensure_breakeven
        end
      end

      if(self.position == :short)

        if(self.current.value <= (self.position_val - self.gains[:gain_1]) && self.position_size == 2) #contrato 1
          take_profit
        end

        if(self.current.value <= (self.position_val - self.gains[:gain_2]) && self.position_size == 1) #contrato 2
          take_profit
          close_position
        end

        if(self.current.value >= (self.openning + self.stop))
          take_loss(true)
        end

        if(self.breakeven && self.position_size == 1 && (self.current.value >= self.position_val))
          ensure_breakeven
        end
      end

    end

    if(self.position != :liquid)
      if((self.position_val >= self.current.value && self.position == :long) ||
        (self.position_val <= self.current.value && self.position == :short))
        self.position_size.times { take_profit }
        close_position
      else
        take_loss(false)
      end
    end
    debug "Fim da execução Net: #{self.net} - horario #{self.current.date.hour} - position #{self.position} - setup: #{self.poss}"
    print "."

    self.net
  end

  def self.create_inputs
    stops = (1..5).to_a
    start = (1..5).to_a
    gain_1 = (1..5).to_a
    gain_2 = (5..8).to_a
    total_loss = [-100, -150, -200, -250]
    total_gain = [100, 150, 200, 250]
    breakeven = [true, false]
    one_shot = [true, false]

    possibilities = Inputs.combine_arrays(gain_1, gain_2, :gain_1, :gain_2)
    possibilities = Inputs.combine_array_map(stops, possibilities, :start)
    possibilities = Inputs.combine_array_map(start, possibilities, :stop)
    possibilities = Inputs.combine_array_map(total_gain, possibilities, :total_gain)
    possibilities = Inputs.combine_array_map(total_loss, possibilities, :total_loss)
    possibilities = Inputs.combine_array_map(breakeven, possibilities, :breakeven)
    possibilities = Inputs.combine_array_map(one_shot, possibilities, :one_shot)

    possibilities
  end
end
