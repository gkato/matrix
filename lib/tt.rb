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

  def is_uptic?(tt)
    self.value > tt.value
  end

  def is_downtic?(tt)
    self.value < tt.value
  end

  def is_equal_tic?(tt)
    self.value == tt.value
  end

end
