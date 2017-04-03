require './lib/strategy'

class OpeningV1 < Strategy

  def run_strategy
    @allowed = true

    @historic.each_with_index do |tt, i|
      @last = @current

      @current = TT.new(tt[:date].to_datetime, tt[:value], tt[:qty], tt[:ask], tt[:bid], tt[:agressor])

      break if was_last_tt?

      if(@position == :liquid && !@allowed)
        if (@current.value >= @openning && @last.value < @openning) ||
           (@current.value <= @openning && @last.value > @openning)

          @allowed = true
        end
      end

      if (@position == :liquid && @current.value >= (@openning + @start) && @allowed)
        enter_position :long
        next
      end

      if (@position == :liquid && @current.value <= (@openning - @start) && @allowed)
        enter_position :short
        next
      end

      if(@position == :long)

        if(@current.value >= (@position_val + @gains[:gain_1]) && @position_size == 2) #contrato 1
          take_profit
        end

        if(@current.value >= (@position_val + @gains[:gain_2]) && @position_size == 1) #contrato 2
          take_profit
          close_position
        end

        if(@current.value <= (@openning - @stop))
          take_loss(true)
        end

        if(@breakeven && @position_size == 1 && (@current.value <= @position_val ))
          ensure_breakeven
        end
      end

      if(@position == :short)

        if(@current.value <= (@position_val - @gains[:gain_1]) && @position_size == 2) #contrato 1
          take_profit
        end

        if(@current.value <= (@position_val - @gains[:gain_2]) && @position_size == 1) #contrato 2
          take_profit
          close_position
        end

        if(@current.value >= (@openning + @stop))
          take_loss(true)
        end

        if(@breakeven && @position_size == 1 && (@current.value >= @position_val))
          ensure_breakeven
        end
      end

    end

    if(@position != :liquid)
      if((@current.value >= @position_val && @position == :long) ||
        (@current.value <= @position_val && @position == :short))
        @position_size.times { take_profit }
        close_position
      else
        take_loss(false)
      end
    end
    debug "Fim da execução Net: #{@net} - horario #{@current.date.hour} - position #{@position} - setup: #{@poss}"
    print "."

    @net
  end

  def self.create_inputs(equity="WDO")
    possibilities = []

    if equity == "WDO"
      stops = (2..5).to_a
      start = (2..5).to_a
      gain_1 = (1..5).to_a
      gain_2 = (5..8).to_a
      total_loss = [-100, -150, -200]
      total_gain = [100, 150, 200]
      breakeven = [true, false]
      one_shot = [true, false]

      possibilities = Inputs.combine_arrays(gain_1, gain_2, :gain_1, :gain_2)
      possibilities = Inputs.combine_array_map(stops, possibilities, :start)
      possibilities = Inputs.combine_array_map(start, possibilities, :stop)
      possibilities = Inputs.combine_array_map(total_gain, possibilities, :total_gain)
      possibilities = Inputs.combine_array_map(total_loss, possibilities, :total_loss)
      possibilities = Inputs.combine_array_map(breakeven, possibilities, :breakeven)
      possibilities = Inputs.combine_array_map(one_shot, possibilities, :one_shot)

      possibilities.delete_if do |poss|
        total_gain = (poss[:gain_1] + poss[:gain_2]) * 10
        total_loss = ((poss[:start] + poss[:stop])*2) * 10

        (total_gain <  total_loss) || !(poss[:gain_1] <= poss[:gain_2])
      end
    end

    possibilities
  end
end
