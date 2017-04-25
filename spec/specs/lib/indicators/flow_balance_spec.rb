require 'indicators/flow_balance'
require 'tt'

describe FlowBalance do
  let(:indicator) { FlowBalance.new }

  describe "#compute" do
    context "given a times and trade cenario 1" do
      it "computes the flow balance" do
        indicator.compute(TT.new(DateTime.new, 3040, 1, "A", "B", "Comprador"))
        expect(indicator.balance).to eq(1)
      end
    end
    context "given a times and trade cenario 2" do
      it "computes the flow balance" do
        indicator.compute(TT.new(DateTime.new, 3040, 1, "A", "B", "Comprador"))
        indicator.compute(TT.new(DateTime.new, 3040, 10, "A", "B", "Vendedor"))
        indicator.compute(TT.new(DateTime.new, 3040, 15, "A", "B", "Comprador"))
        indicator.compute(TT.new(DateTime.new, 3040, 5, "A", "B", "Vendedor"))
        indicator.compute(TT.new(DateTime.new, 3040, 3, "A", "B", "Comprador"))
        expect(indicator.balance).to eq(4)
      end
    end
    context "given a times and trade cenario 3" do
      it "computes the flow balance" do
        indicator.compute(TT.new(DateTime.new, 3040, 100, "A", "B", "Vendedor"))
        indicator.compute(TT.new(DateTime.new, 3040, 230, "A", "B", "Vendedor"))
        indicator.compute(TT.new(DateTime.new, 3040, 300, "A", "B", "Vendedor"))
        indicator.compute(TT.new(DateTime.new, 3040, 50, "A", "B", "Comprador"))
        indicator.compute(TT.new(DateTime.new, 3040, 10, "A", "B", "Vendedor"))
        indicator.compute(TT.new(DateTime.new, 3040, 30, "A", "B", "Comprador"))
        indicator.compute(TT.new(DateTime.new, 3040, 10, "A", "B", "Vendedor"))
        indicator.compute(TT.new(DateTime.new, 3040, 5, "A", "B", "Comprador"))
        expect(indicator.balance).to eq(-565)
      end
    end
  end

end
