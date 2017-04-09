require 'strategies/opening_pullback_v1'
require 'tt'

describe OpeningPullbackV1 do
  let(:poss) { {stop:1, gain_1:1, gain_2:2, gain_3:3, gain_4:4, start:3, pullback:2, total_gain:170, total_loss:-100, net:0, one_shot:true} }
  let(:poss_mult) { {stop:1, gain_1:1, gain_2:2, gain_3:3, gain_4:4, mult_1:6, mult_2:2, start:3, pullback:2, total_gain:170, total_loss:-100, net:0, one_shot:true} }
  let(:tic_value) { 10 }
  let(:limit_time) { 10 }
  let(:historic) do
    [{ date:DateTime.strptime("31/01/2017 09:01:01", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"A", bid:"B", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:02:02", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"C", bid:"D", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:03:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:04:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:05:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:06:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:07:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:09:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:10:03", "%d/%m/%Y %H:%M:%S"), value:3054, qty:1, ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:11:03", "%d/%m/%Y %H:%M:%S"), value:3055, qty:1, ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3056, qty:1, ask:"E", bid:"F", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), value:3057, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
  end
  let(:openning) { 3050 }
  let(:strategy) { OpeningPullbackV1.new(poss, tic_value, limit_time, historic, openning) }
  let(:strategy_mult) { OpeningPullbackV1.new(poss_mult, tic_value, limit_time, historic, openning) }

  describe "#run_strategy" do
    context "given a historic when start is never reached" do
      it "runs the strategy and does nothing" do
        strategy.historic = historic.first(2)
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
    end

    #### BASIC LONG STRATEGIES ####
    context "given a historic (default) with a simple gain (long) sequence" do
      it "runs the strategy and returns net profit" do
        strategy.visual=true
        strategy.run_strategy

        expect(strategy.net).to be(100)
      end
    end

    context "given a historic (default) with a simple gain (long) sequence" do
      it "runs the strategy and returns net profit, with gain 1 multiplied on 6, a gain 2 multiplied on 2" do
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(170)
      end
    end

    context "given a historic with a simple loss sequence" do
      it "runs the strategy and returns net profit" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3048.5, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy.historic = historic
        strategy.run_strategy

        expect(strategy.net).to be(-80)
      end
    end

    context "given a historic with a simple loss sequence" do
      it "runs the strategy and returns net profit, with gain 1 multiplied on 6, a gain 2 multiplied on 2" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3048.5, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy_mult.historic = historic
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(-200)
      end
    end

    context "given a historic with gain for gain_1 then stoped" do
      it "runs the strategy and returns net profit, with gain 1 multiplied on 6, a gain 2 multiplied on 2" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3048.5, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy_mult.historic = historic
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(60)
      end
    end

    context "given a historic with gain for gain_1 and gain_2 then stoped" do
      it "runs the strategy and returns net profit, with gain 1 multiplied on 6, a gain 2 multiplied on 2" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy_mult.historic = historic
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(120)
      end
    end

    context "given a historic with gain for gain_1, gain_2, gain_3 then stoped" do
      it "runs the strategy and returns net profit, with gain 1 multiplied on 6, a gain 2 multiplied on 2" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3054, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy_mult.historic = historic
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(140)
      end
    end
    #### BASIC LONG STRATEGIES ####

    #### BASIC SHORT STRATEGIES ####
    context "given a historic (default) with a simple gain (short) sequence" do
      it "runs the strategy and returns net profit" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3046, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3045, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3044.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3044, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3043.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3042, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3041, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy.historic = historic
        strategy.run_strategy

        expect(strategy.net).to be(100)
      end
    end

    context "given a historic (default) with a simple gain (short) sequence" do
      it "runs the strategy and returns net profit, with gain 1 multiplied on 6, a gain 2 multiplied on 2" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3046, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3045, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3044.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3044, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3043.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3042, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3041, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy_mult.historic = historic
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(170)
      end
    end

    context "given a historic with a simple loss (short) sequence" do
      it "runs the strategy and returns net profit" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy.historic = historic
        strategy.run_strategy

        expect(strategy.net).to be(-80)
      end
    end

    context "given a historic with a simple loss (short) sequence" do
      it "runs the strategy and returns net profit, with gain 1 multiplied on 6, a gain 2 multiplied on 2" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy_mult.historic = historic
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(-200)
      end
    end

    context "given a historic with gain for gain_1 then stoped" do
      it "runs the strategy and returns net profit, with gain 1 multiplied on 6, a gain 2 multiplied on 2" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3048.5, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy_mult.historic = historic
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(60)
      end
    end

    context "given a historic with gain for gain_1 and gain_2 then stoped" do
      it "runs the strategy and returns net profit, with gain 1 multiplied on 6, a gain 2 multiplied on 2" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3048.5, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy_mult.historic = historic
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(120)
      end
    end

    context "given a historic with gain for gain_1, gain_2, gain_3 then stoped" do
      it "runs the strategy and returns net profit, with gain 1 multiplied on 6, a gain 2 multiplied on 2" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3046, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3044, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3048.5, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy_mult.historic = historic
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(140)
      end
    end
    #### BASIC SHORT STRATEGIES ####

    context "given a historic with gain for gain_1 and time limit reached on a short trade" do
      it "runs the stategy and returns net profit  with  gain all over gain_1 price range" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 10:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy_mult.historic = historic
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(100)
      end
    end

    context "given a historic with gain for gain_1 and time limit reached on a long trade" do
      it "runs the stategy and returns net profit  with  gain all over gain_1 price range" do
        historic = [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"A", bid:"B", :agressor=>:ask},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 10:00:02", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"C", bid:"D", :agressor=>:bid},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
        strategy_mult.historic = historic
        strategy_mult.run_strategy

        expect(strategy_mult.net).to be(100)
      end
    end
  end
end
