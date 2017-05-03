require './lib/strategies/flow_strategy'
require './lib/inputs'

class OpeningPullbackV1 < FlowStrategy

  attr_accessor :pullback, :await_pullback

  PULLBACK_STATUS = [:await, :pb_long, :pb_short].freeze

  def initialize(possibility, tic_value, time, hist, openning)
    super(possibility, tic_value, time, hist, openning)
    @pullback = possibility[:pullback]
    @await_pullback = :await

    @one_shot = true
  end

  def flip_allowed?
    (@current.value >= @openning && @last.value < @openning) || (@current.value <= @openning && @last.value > @openning)
  end

  def apply_strategy_rule
    if @await_pullback.nil? || @await_pullback == :await
      if (@position == :liquid && @current.value >= (@openning + @start) && @allowed)
        @await_pullback = :pb_long
      end
      if (@position == :liquid && @current.value <= (@openning - @start) && @allowed)
        @await_pullback = :pb_short
      end
    else
      if enter_long_position?
        enter_position(:long)
        return
      end
      if enter_short_position?
        enter_position(:short)
        return
      end
      @await_pullback = :await if flip_allowed?
    end
  end

  def enter_long_position?
    @await_pullback == :pb_long && @current.value <= ((@openning + @start) - @pullback) && indicators_filter(@await_pullback)
  end

  def enter_short_position?
    @await_pullback == :pb_short && @current.value >= ((@openning - @start) + @pullback) && indicators_filter(@await_pullback)
  end

  def indicators_filter(await_pb)
    return true if await_pb == :pb_long
    return true if await_pb == :pb_short
  end

  def run_strategy
    @allowed = true

    @historic.each_with_index do |tt, i|
      @last = @current

      @current = create_tt_and_compute(tt)

      break if was_last_tt?

      if(@position == :liquid && !@allowed)
        @allowed = true if flip_allowed?
      end

      if(@position == :liquid)
        apply_strategy_rule
        next
      end

      take_profit_all_if do |target|
        if @position == :long
          @current.value >= (@position_val + target)
        elsif @position == :short
          @current.value <= (@position_val - target)
        end
      end

      next if @position_size == 0


      if (@current.value <= (@openning - @stop) && @position == :long) ||
         (@current.value >= (@openning + @stop) && @position == :short)
        take_loss(false, @mults)
        next
      end

      do_break_even

    end

    if(@position != :liquid)
      if((@current.value >= @position_val && @position == :long) ||
        (@current.value <= @position_val && @position == :short))
        take_profit_all_if { true }
      else
        take_loss(false, @mults)
      end
    end
    debug "Fim da execução Net: #{@net} - horario #{@current.date.hour} - position #{@position} - setup: #{@poss}"
    print "."

    @net
  end

  def self.create_inputs(equity="WDO")
    possibilities = []

    if equity == "WDO"
      start = (2..5).to_a
      pullback = (2..4).to_a
      stop = (1..5).to_a
      gain_1 = (2..4).to_a
      gain_2 = (2..6).to_a
      gain_3 = (4..8).to_a
      gain_4 = (4..10).to_a
      total_loss = [-10000]
      total_gain = [10000]
      mult_1 = [6]
      mult_2 = [2]

      possibilities = Inputs.combine_arrays(gain_1, gain_2, :gain_1, :gain_2)
      #possibilities = Inputs.combine_array_map(gain_3,     possibilities, :gain_3)
      #possibilities = Inputs.combine_array_map(gain_4,     possibilities, :gain_4)
      possibilities = Inputs.combine_array_map(start,      possibilities, :start)
      possibilities = Inputs.combine_array_map(stop,       possibilities, :stop)
      possibilities = Inputs.combine_array_map(pullback,   possibilities, :pullback)
      possibilities = Inputs.combine_array_map(total_gain, possibilities, :total_gain)
      possibilities = Inputs.combine_array_map(total_loss, possibilities, :total_loss)
      #possibilities = Inputs.combine_array_map(mult_1, possibilities, :mult_1)
      #possibilities = Inputs.combine_array_map(mult_2, possibilities, :mult_2)

      possibilities.delete_if do |poss|
        #total_gain = (poss[:gain_1] + poss[:gain_2] + poss[:gain_3] + poss[:gain_4]) * 10
        #total_loss = ((poss[:start] - poss[:pullback]) + (poss[:stop]*4)) * 10

        total_gain = (poss[:gain_1] + poss[:gain_2]) * 10
        total_loss = ((poss[:start] - poss[:pullback] + poss[:stop])*2) * 10

        #(total_gain <  total_loss) || !((poss[:pullback] <= poss[:start]) && (poss[:gain_1] <= poss[:gain_2]) && (poss[:gain_2] <= poss[:gain_3]) && (poss[:gain_3] <= poss[:gain_4]))
        (total_gain <  total_loss) || !((poss[:pullback] <= poss[:start]) && (poss[:gain_1] <= poss[:gain_2]))
      end
    end
    if equity == "WIN"
      start = [150, 200, 250, 300]
      pullback = [150, 200, 250]
      stop = [100, 150, 200]
      gain_1 = [50, 75, 100]
      gain_2 = [75, 100, 125, 150]
      gain_3 = [100, 150, 200, 250]
      gain_4 = [200, 300, 400, 500, 600, 700, 800]
      total_loss = [-10000]
      total_gain = [10000]
      mult_1 = [6]
      mult_2 = [2]

      possibilities = Inputs.combine_arrays(gain_1, gain_2, :gain_1, :gain_2)
      possibilities = Inputs.combine_array_map(gain_3,     possibilities, :gain_3)
      possibilities = Inputs.combine_array_map(gain_4,     possibilities, :gain_4)
      possibilities = Inputs.combine_array_map(start,      possibilities, :start)
      possibilities = Inputs.combine_array_map(stop,       possibilities, :stop)
      possibilities = Inputs.combine_array_map(pullback,   possibilities, :pullback)
      possibilities = Inputs.combine_array_map(total_gain, possibilities, :total_gain)
      possibilities = Inputs.combine_array_map(total_loss, possibilities, :total_loss)
      possibilities = Inputs.combine_array_map(mult_1, possibilities, :mult_1)
      possibilities = Inputs.combine_array_map(mult_2, possibilities, :mult_2)

      possibilities.delete_if do |poss|
        total_gain = (poss[:gain_1]*6 + poss[:gain_2]*2 + poss[:gain_3] + poss[:gain_4]) * 10
        total_loss = ((poss[:start] - poss[:pullback] + poss[:stop])*10) * 10
        (total_gain <  total_loss) || !((poss[:pullback] <= poss[:start]) && (poss[:gain_1] <= poss[:gain_2]) && (poss[:gain_2] <= poss[:gain_3]) && (poss[:gain_3] <= poss[:gain_4]))
      end
    end
    possibilities
  end
end
