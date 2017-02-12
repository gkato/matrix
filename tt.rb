class TT
  attr_accessor :date, :value, :quantity, :ask, :bid, :agressor

  def initialize(date, value, quantity, ask, bid, agressor)
    self.date = date
    self.value = value
    self.quantity = quantity
    self.ask = ask
    self.bid = bid

    if agressor == "Comprador"
      self.agressor = :ask
    elsif agressor == "Vendedor"
      self.agressor = :bid
    end
  end

  def is_uptick?(tt)
    self.value > tt.value
  end

  def is_downtick?(tt)
    self.value < tt.value
  end

  def is_equal_or_uptick?(tt)
    self.value >= tt.value
  end

  def is_equal_or_downtick?(tt)
    self.value <= tt.value
  end

  def is_equal_tick?(tt)
    self.value == tt.value
  end

  def is_progressive_tick?(current_movement, last)
    (current_movement == :ask && self.is_equal_or_uptick?(last)) || (current_movement == :bid && self.is_equal_or_downtick?(last))
  end

  def is_just_a_swing?(swing_factor, price_sequence, swing_min_size)
    sequence_size = price_sequence.size

    return false if sequence_size < swing_min_size

    last_price = price_sequence[sequence_size - 1]
    early_last = price_sequence[sequence_size - 2]

    diff = last_price > self.value ? last_price - self.value : self.value - last_price

    if diff > swing_factor
      return false
    end

    if (self.value < last_price && last_price > early_last) || (self.value > last_price && last_price < early_last)
      return true
    end

    return false
  end
end
