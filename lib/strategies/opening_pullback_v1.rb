require './lib/strategy'
require './lib/inputs'

class OpeningPullbackV1 < Strategy

  attr_accessor :pullback, :await_pullback, :mults, :done_gains

  PULLBACK_STATUS = [:await, :pb_long, :pb_short].freeze

  def initialize(possibility, tic_value, time, hist, openning)
    super(possibility, tic_value, time, hist, openning)
    @pullback = possibility[:pullback]
    @await_pullback = :await

    @mults = possibility.select {|k,v| k.to_s =~ /^mult_\d+$/ }.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    @gains.each { |k,v| @mults[k.to_s.gsub("gain","mult").to_sym] = get_gain_factor(k) }
    @done_gains = []
    @one_shot = true
  end

  def reached_start?(position, current_value, openning, start, allowed)
  end

  def flip_allowed?
    (@current.value >= @openning && @last.value < @openning) || (@current.value <= @openning && @last.value > @openning)
  end

  def get_gain_index(gain_sym)
    gain_sym.to_s.scan(/^gain_(\d+)/).flatten.first
  end

  def get_gain_factor(gain_sym)
    index = get_gain_index(gain_sym)
    multi_sym = "mult_#{index}".to_sym
    @mults[multi_sym] || 1
  end

  def do_take_profit(gain_sym)
    factor = get_gain_factor(gain_sym)
    take_profit(factor)
    @mults.delete("mult_#{get_gain_index(gain_sym)}".to_sym)

    @done_gains << gain_sym
    close_position if @position_size == 0
  end

  def run_strategy
    @allowed = true

    @historic.each_with_index do |tt, i|
      @last = @current

      @current = TT.new(tt[:date].to_datetime, tt[:value], tt[:qty], tt[:ask], tt[:bid], tt[:agressor])

      break if was_last_tt?

      if(@position == :liquid && !@allowed)
        @allowed = true if flip_allowed?
      end

      if(@position == :liquid)
        if @await_pullback.nil? || @await_pullback == :await
          if (@position == :liquid && @current.value >= (@openning + @start) && @allowed)
            @await_pullback = :pb_long
          end
          if (@position == :liquid && @current.value <= (@openning - @start) && @allowed)
            @await_pullback = :pb_short
          end
        else
          if(@await_pullback == :pb_long && @current.value <= ((@openning + @start) - @pullback))
            enter_position :long
          end
          if(@await_pullback == :pb_short && @current.value >= ((@openning - @start) + @pullback))
            enter_position :short
          end
        end
        next
      end

      if(@position == :long)
        @gains.each do |key, value|
          next if @done_gains.include?(key)
          if @current.value >= (@position_val + value)
            do_take_profit(key)
          end
        end

        next if @position_size == 0

        if @current.value <= (@openning - @stop)
          take_loss(false, @mults)
          next
        end

        if @position_size != @gains.size && (@current.value <= @position_val)
          take_loss(false, @mults)
        end
      end

      if(@position == :short)
        @gains.each do |key, value|
          next if @done_gains.include?(key)
          if @current.value <= (@position_val - value)
            do_take_profit(key)
          end
        end

        next if @position_size == 0

        if @current.value >= (@openning + @stop)
          take_loss(false, @mults)
          next
        end

        if @position_size != @gains.size && (@current.value >= @position_val)
          take_loss(false, @mults)
        end
      end

    end

    if(@position != :liquid)
      if((@current.value >= @position_val && @position == :long) ||
        (@current.value <= @position_val && @position == :short))

        @gains.each do |key, value|
          if !@done_gains.include?(key)
            do_take_profit(key)
          end
        end
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
