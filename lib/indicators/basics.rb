require './lib/indicators/vwap'
require './lib/indicators/adjustment'

class Basics

  attr_accessor :min, :max, :close, :vwap, :adjustment

  def initialize
    @min = 0.0;
    @max = 0.0;
    @close = 0.0;
    @vwap = VWAP.new
    @adjustment = Adjustment.new
  end

  def add_data(historic_data)
    price = historic_data[:value]
    @close = price
    @min = price if (@min == 0.0 || price < @min)
    @max = price if (@max == 0.0 || price > @max)
    @vwap.add_data(historic_data)
    @adjustment.add_data(historic_data)
  end

  def vwap
    @vwap.current_value
  end

  def adjustment
    @adjustment.current_value
  end

  def var
    @max - @min
  end

  def vwap_dist
    (@vwap.current_value - @close).abs.round(2)
  end

  def adjustment_dist
    value = @adjustment.current_value

    return 0.0 if value.nil?

    (value - @close).abs.round(2)
  end

end
