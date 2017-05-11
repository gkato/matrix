require 'strategies/inflection_v1'

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
     { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3042, qty:12, ask:"E", bid:"F", :agressor=>:ask},
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
     { date:DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1,  ask:"E", bid:"F", :agressor=>:bid}]
  end
  let(:openning) { 3050 }
  let(:strategy) { OpeningPullbackV1.new(poss, tic_value, limit_time, historic, openning) }

  xdescribe "#run_strategy" do
    context "given a long inflection hitoric" do
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
        strategy.hitoric[7][:qty] = 1
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "does nothing because flow flip was not reached" do
        strategy.hitoric[7][:qty] = 400
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "returns net profit when all gains were reached" do
        strategy.run_strategy

        expect(strategy.net).to be(170)
      end
    end

    context "given a short inflection hitoric" do
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
        strategy.hitoric[7][:qty] = 1
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "does nothing because flow flip was not reached" do
        strategy.hitoric[7][:qty] = 400
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
