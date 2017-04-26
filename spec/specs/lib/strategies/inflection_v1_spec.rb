require 'strategies/inflection_v1'

describe InflectionV1 do
  let(:poss_mult) { {stop:1, gain_1:1, gain_2:2, gain_3:3, gain_4:4, mult_1:6, mult_2:2, start:3, pullback:2, total_gain:170, total_loss:-100, net:0, one_shot:true, flow:800} }
  let(:tic_value) { 10 }
  let(:limit_time) { 10 }
  let(:openning) { 3050 }
  let(:historic) { [] }
  let(:strategy) { InflectionV1.new(poss_mult, tic_value, limit_time, historic, openning) }

  describe "#create_tt_and_compute" do
    context "given and times and trade info" do
      it "create a TT object and compute flow balance quantity" do
        result = strategy.create_tt_and_compute({date:DateTime.new, value:3040, qty:10, ask:"A", bid:"B", agressor:"Vendedor"})
        expect(result.value).to eq(3040)
        expect(strategy.flow_balance.balance).to eq(-10)
      end
    end
  end
end
