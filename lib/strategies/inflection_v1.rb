require './lib/strategies/opening_pullback_v1'
require './lib/inputs'
require './lib/tt'

class InflectionV1 < OpeningPullbackV1
  attr_accessor :pullback_var, :flow_flip, :kick_off, :flow_edge, :state, :max, :min

  LONG_STATES = [:await, :pb_long, :drop_long]
  SHORT_STATES = [:await, :pb_short, :drop_short]

  def initialize(possibility, tic_value, time, hist, openning)
    super(possibility, tic_value, time, hist, openning)
    @pullback_var = possibility[:pullback_var]
    @kick_off = possibility[:kick_off]
    @flow_flip = possibility[:flow_flip].to_f
    @flow_edge = 0
    @state = :await
  end

  def stop_price_reference
    @position_val
  end

  def create_tt_and_compute(tt_infos)
    tt = super(tt_infos)
    return tt if @current.nil?

    if @current.value > @openning
      @flow_edge = @flow_balance.balance if @flow_edge < @flow_balance.balance
    elsif @current.value < @openning
      @flow_edge = @flow_balance.balance if @flow_edge > @flow_balance.balance
    end
    tt
  end

  def check_valid_pb(value)
    return true if @state == :drop_short && (@max - value) <= (@pullback + @pullback_var)
    return true if @state == :drop_long && (value - @min) <= (@pullback + @pullback_var)
    return false
  end

  def apply_strategy_rule
    if @position == :liquid && (@state.nil? || @state == :await)
      if (@current.value >= (@openning + @start) && @allowed)
        @state = :pb_short
        @max = @current.value
      end
      if (@current.value <= (@openning - @start) && @allowed)
        @state = :pb_long
        @min = @current.value
      end
    elsif @position == :liquid && [:pb_long, :pb_short].include?(@state)
      if @state == :pb_short
        if @max <= @current.value
          @max = @current.value
        elsif (@max - @current.value) >= @pullback
          @state = :drop_short
          @state = :await if !check_valid_pb(@current.value)
        end
      end
      if @state == :pb_long
        if @min >= @current.value
          @min = @current.value
        elsif (@current.value - @min) >= @pullback
          @state = :drop_long
          @state = :await if !check_valid_pb(@current.value)
        end
      end
    elsif @position == :liquid && [:drop_long, :drop_short].include?(@state)
      if !check_valid_pb(@current.value)
        @state = :await
      else
        if enter_long_position?
          enter_position(:long)
          return
        end
        if enter_short_position?
          enter_position(:short)
          return
        end
      end
    else
      @state = :await if flip_allowed?
    end
  end

  def enter_long_position?
    @state == :drop_long && @current.value <= (@min - @kick_off) && indicators_filter(@state)
  end

  def enter_short_position?
    @state == :drop_short && @current.value >= (@max + @kick_off) && indicators_filter(@state)
  end

  def indicators_filter(drop)
    if drop == :drop_short && @flow_edge >= @flow && @flow_balance.balance <= (@flow_edge*(1-(@flow_flip/100)))
      return true
    end
    if drop == :drop_long && @flow_edge <= -(@flow) && @flow_balance.balance >= (@flow_edge*(1-(@flow_flip/100)))
      return true
    end
    return false
  end
end
