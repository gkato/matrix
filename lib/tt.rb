class TT
  attr_accessor :date, :value, :quantity, :ask, :bid, :agressor

  def initialize(date, value, quantity, ask, bid, agressor)
    self.date = date
    self.value = value
    self.quantity = quantity.to_i
    self.ask = ask
    self.bid = bid

    if ["Comprador",:ask].include?(agressor)
      self.agressor = :ask
    elsif ["Vendedor",:bid].include?(agressor)
      self.agressor = :bid
    elsif ["Direto",:direct].include?(agressor)
      self.agressor = :direct
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
