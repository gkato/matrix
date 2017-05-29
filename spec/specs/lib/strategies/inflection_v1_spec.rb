require 'strategies/inflection_v1'
require 'date'

describe InflectionV1 do
  let(:poss) { {stop:1, gain_1:1, gain_2:2, gain_3:3, mult_1:6, mult_2:4, start:8, pullback:3, pullback_var:2, flow:10, flow_flip:20, kick_off:1, total_gain:170, total_loss:-100, net:0, one_shot:true} }
  let(:tic_value) { 10 }
  let(:limit_time) { 10 }
  let(:historic) do
    [{ date:DateTime.strptime("31/01/2017 09:01:01", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1,  ask:"A", bid:"B", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:02:02", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1,  ask:"C", bid:"D", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:03:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:04:03", "%d/%m/%Y %H:%M:%S"), value:3054, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:05:03", "%d/%m/%Y %H:%M:%S"), value:3055, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:06:03", "%d/%m/%Y %H:%M:%S"), value:3056, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:07:03", "%d/%m/%Y %H:%M:%S"), value:3057, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3058, qty:12, ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:09:03", "%d/%m/%Y %H:%M:%S"), value:3057, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:10:03", "%d/%m/%Y %H:%M:%S"), value:3056, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:11:03", "%d/%m/%Y %H:%M:%S"), value:3055, qty:7,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3057, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3058, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3059, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3058, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3057, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3056, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3055, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3054, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1,  ask:"E", bid:"F", :agressor=>:bid}]
  end
  let(:historic_long) do
    [{ date:DateTime.strptime("31/01/2017 09:01:01", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1,  ask:"A", bid:"B", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:02:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1,  ask:"C", bid:"D", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:03:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:04:03", "%d/%m/%Y %H:%M:%S"), value:3046, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:05:03", "%d/%m/%Y %H:%M:%S"), value:3045, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:06:03", "%d/%m/%Y %H:%M:%S"), value:3044, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:07:03", "%d/%m/%Y %H:%M:%S"), value:3043, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3042, qty:12, ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:09:03", "%d/%m/%Y %H:%M:%S"), value:3043, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:10:03", "%d/%m/%Y %H:%M:%S"), value:3044, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:11:03", "%d/%m/%Y %H:%M:%S"), value:3045, qty:7,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3043, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3042, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3041, qty:1,  ask:"E", bid:"F", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3042, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3043, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3044, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3045, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3046, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1,  ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1,  ask:"E", bid:"F", :agressor=>:bid}]
  end
  let(:openning) { 3050 }
  let(:strategy) { InflectionV1.new(poss, tic_value, limit_time, historic, openning) }

  describe "#enter_short_position?" do
    context "given an indicator filter staisfied" do
      before do
        strategy.flow_balance.balance = 8
        strategy.state = :drop_short
        strategy.flow_edge = 12
        strategy.max = 3058
      end
      it "returns true if the price is equal than the max plus kickoff var" do
        strategy.current = TT.new(DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), 3059, 1, "E", "F", :bid)
        expect(strategy.enter_short_position?).to eq (true)
      end
      it "returns true if the price is greater than the max plus kickoff var" do
        strategy.current = TT.new(DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), 3065, 1, "E", "F", :bid)
        expect(strategy.enter_short_position?).to eq (true)
      end
      it "returns true if the price is lower than the max plus kickoff var" do
        strategy.current = TT.new(DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), 3058, 1, "E", "F", :bid)
        expect(strategy.enter_short_position?).to eq (false)
      end
    end
  end

  describe "#enter_long_position?" do
    context "given an indicator filter staisfied" do
      before do
        strategy.flow_balance.balance = -8
        strategy.state = :drop_long
        strategy.flow_edge = -12
        strategy.min = 3042
      end
      it "returns true if the price is equal than the max plus kickoff var" do
        strategy.current = TT.new(DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), 3041, 1, "E", "F", :bid)
        expect(strategy.enter_long_position?).to eq (true)
      end
      it "returns true if the price is greater than the max plus kickoff var" do
        strategy.current = TT.new(DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), 3040, 1, "E", "F", :bid)
        expect(strategy.enter_long_position?).to eq (true)
      end
      it "returns true if the price is lower than the max plus kickoff var" do
        strategy.current = TT.new(DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), 3043, 1, "E", "F", :bid)
        expect(strategy.enter_long_position?).to eq (false)
      end
    end
  end

  describe "#indicators_filter" do
    context "given a positive flow_edge and drop type is short" do
      before do
        strategy.flow_balance.balance = 8
        strategy.state = :drop_short
        strategy.flow_edge = 12
      end
      it "returns true if flow_edge has reached the flow and current flow_balance is lower or equal flow_flip%flow_edge" do
        expect(strategy.indicators_filter(:drop_short)).to eq (true)
      end
      it "returns false if flow_edge has not reached the flow" do
        strategy.flow_balance.balance = 2
        strategy.flow_edge = 8
        expect(strategy.indicators_filter(:drop_short)).to eq (false)
      end
      it "returns false if current flow_balance has not reached flow_flip%" do
        strategy.flow_balance.balance = 10
        expect(strategy.indicators_filter(:drop_short)).to eq (false)
      end
    end
    context "given a negative flow_edge and drop type is long" do
      before do
        strategy.flow_balance.balance = -8
        strategy.state = :drop_long
        strategy.flow_edge = -12
      end
      it "returns true if flow_edge has reached the flow and current flow_balance is lower or equal flow_flip%flow_edge" do
        expect(strategy.indicators_filter(:drop_long)).to eq (true)
      end
      it "returns false if flow_edge has not reached the flow" do
        strategy.flow_balance.balance = -2
        strategy.flow_edge = -8
        expect(strategy.indicators_filter(:drop_long)).to eq (false)
      end
      it "returns false if current flow_balance has not reached flow_flip%" do
        strategy.flow_balance.balance = -10
        expect(strategy.indicators_filter(:drop_long)).to eq (false)
      end
    end
  end

  describe "#check_valid_pb" do
    context "given a pb_short state" do
      before do
        strategy.state = :drop_short
        strategy.max = 3058
      end
      it "returns true when the given pullback parameter range is reached" do
        result = strategy.check_valid_pb(3055)
        expect(result).to eq(true)
      end
      it "returns true when the given pullback_var parameter range is reached" do
        result = strategy.check_valid_pb(3053)
        expect(result).to eq(true)
      end
      it "returns false when pullback is over reached" do
        result = strategy.check_valid_pb(3052)
        expect(result).to eq(false)
      end
    end
    context "given a pb_long state" do
      before do
        strategy.state = :drop_long
        strategy.min = 3042
      end
      it "returns true when the given pullback parameter range is reached" do
        result = strategy.check_valid_pb(3045)
        expect(result).to eq(true)
      end
      it "returns true when the given pullback_var parameter range is reached" do
        result = strategy.check_valid_pb(3047)
        expect(result).to eq(true)
      end
      it "returns false when pullback is over reached" do
        result = strategy.check_valid_pb(3048)
        expect(result).to eq(false)
      end
    end
  end

  describe "#run_strategy" do
    context "given a long inflection historic" do
      before do
        strategy.historic = historic_long
      end
      it "does nothing because start was not reached" do
        strategy.historic = historic.first(2)
        strategy.run_strategy
        expect(strategy.net).to be(0)
      end
      it "does nothing because start was not reached" do
        strategy.historic = historic.first(8)
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "does nothing because pullback was over-reached" do
        strategy.historic = historic.first(10)
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3054, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3055, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3057, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3058, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3059, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3058, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3057, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3056, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3055, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3054, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid}

        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "does nothing because kick-of was not reached" do
        strategy.historic = historic.first(12)
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "does nothing because flow balance was not reached" do
        strategy.historic[7][:qty] = 1
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "does nothing because flow flip was not reached" do
        strategy.historic[7][:qty] = 400
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "returns net profit when all gains were reached" do
        strategy.run_strategy

        expect(strategy.net).to be(170)
      end
    end

    context "given a short inflection historic" do
      it "does nothing because start was not reached" do
        strategy.historic = historic.first(2)
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "does nothing because start was not reached" do
        strategy.historic = historic.first(8)
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "does nothing because pullback was over-reached" do
        strategy.historic = historic.first(10)
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3046, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3045, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3043, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3042, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3041, qty:1, ask:"E", bid:"F", :agressor=>:ask}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3042, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3043, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3044, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3045, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3046, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"E", bid:"F", :agressor=>:bid}
        strategy.historic << { date:DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"E", bid:"F", :agressor=>:bid}

        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "does nothing because kick-of was not reached" do
        strategy.historic = historic.first(12)
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "does nothing because flow balance was not reached" do
        strategy.historic[7][:qty] = 1
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "does nothing because flow flip was not reached" do
        strategy.historic[7][:qty] = 400
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "returns net profit when all gains were reached" do
        strategy.run_strategy

        expect(strategy.net).to be(170)
      end
    end
  end
end
