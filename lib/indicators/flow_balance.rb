class FlowBalance

  attr_accessor :balance

  def initialize
    @balance = 0
  end

  def compute(tt)
    if (tt.agressor == :ask)
      @balance = @balance + tt.quantity
    elsif (tt.agressor == :bid)
      @balance = @balance - tt.quantity
    end
  end
end
