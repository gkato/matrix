require 'strategies/opening_v1'
require 'tt'

describe OpeningV1 do
  let(:poss) { {stop:1, gain_1:1, gain_2:2, start:1, total_gain:100, total_loss:-100, net:0, per_day:[]} }
  let(:tic_value) { 10 }
  let(:limit_time) { 10 }
  let(:historic) do
    [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"A", bid:"B", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"C", bid:"D", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
  end
  let(:openning) { 3052 }
  let(:strategy) { OpeningV1.new(poss, tic_value, limit_time, historic, openning) }

  describe "#run_strategy" do
    before do
      strategy.historic =
      [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"A", bid:"B", :agressor=>:ask},
       { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"C", bid:"D", :agressor=>:bid},
       { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
    end

    context "given a historic (default - a take profit and close position)" do
      it "runs the strategy and set results - (take profit 1 contract, take loss 1 contract)" do
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
    end

    context "given a historic with two take loss" do
      it "runs the strategy and set results - (take loss 2 contracts, 2 times)" do
        strategy.historic =
          [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3050,   qty:1, ask:"A", bid:"B", :agressor=>:ask},
           { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3051,   qty:1, ask:"C", bid:"D", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051,   qty:1, ask:"E", bid:"F", :agressor=>:bid}]

          strategy.run_strategy

          expect(strategy.net).to be(-100)
      end
    end

    context "given a historic with one take loss and one take profit" do
      it "runs the strategy and set results, onte stop a one gain with an up gap" do
        strategy.historic =
          [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"A", bid:"B", :agressor=>:ask},
           { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"C", bid:"D", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3054, qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3056, qty:1, ask:"E", bid:"F", :agressor=>:bid}]

          strategy.run_strategy

          expect(strategy.net).to be(-20)
      end
    end

    context "given a historic with one take loss and one take profit" do
      it "runs the strategy and set results, onte stop a one gain with an up gap (hugher)" do
        strategy.historic =
          [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"A", bid:"B", :agressor=>:ask},
           { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"C", bid:"D", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3054, qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3059, qty:1, ask:"E", bid:"F", :agressor=>:bid}]

          strategy.run_strategy

          expect(strategy.net).to be(10)
      end
    end

    context "given a historic with one take profit for first contract an break even for second (short)" do
      it "runs the strategy, takes profit for the first contract and breakeven the second contract" do
        strategy.historic =
          [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"A", bid:"B", :agressor=>:ask},
           { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"C", bid:"D", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid}]

          strategy.breakeven = true
          strategy.run_strategy

          expect(strategy.net).to be(10)
      end
    end

    context "given a historic with one take profit for first contract an break even for second (long)" do
      it "runs the strategy, takes profit for the first contract and breakeven the second contract" do
        strategy.historic =
          [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"A", bid:"B", :agressor=>:ask},
           { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3054, qty:1, ask:"C", bid:"D", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F", :agressor=>:bid}]

          strategy.breakeven = true
          strategy.run_strategy

          expect(strategy.net).to be(10)
      end

    end

    context "given a historic with two gains on short" do
      it "runs the strategy and set results, two gains (no gaps)" do
        strategy.historic =
          [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3050,   qty:1, ask:"A", bid:"B", :agressor=>:ask},
           { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049,   qty:1, ask:"C", bid:"D", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3048,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3047,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051,   qty:1, ask:"E", bid:"F", :agressor=>:bid}]

          strategy.run_strategy

          expect(strategy.net).to be(60)
      end
    end

    context "given a historic with two gains on long" do
      it "runs the strategy and set results, two gains (no gaps), then time limit" do
        strategy.historic =
          [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3053,   qty:1, ask:"A", bid:"B", :agressor=>:ask},
           { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3054,   qty:1, ask:"C", bid:"D", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3055,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3055,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3056,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3057,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 11:00:03", "%d/%m/%Y %H:%M:%S"), value:3048,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 11:00:03", "%d/%m/%Y %H:%M:%S"), value:3047,   qty:1, ask:"E", bid:"F", :agressor=>:bid}]

          strategy.run_strategy

          expect(strategy.net).to be(60)
      end
    end

    context "given a historic with two gains on short, but with one_shot flag" do
      it "runs the strategy and set results, one gain" do
        strategy.historic =
          [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3050,   qty:1, ask:"A", bid:"B", :agressor=>:ask},
           { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049,   qty:1, ask:"C", bid:"D", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3048,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3047,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3052.5, qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3051,   qty:1, ask:"E", bid:"F", :agressor=>:bid}]

          strategy.one_shot = true
          strategy.run_strategy

          expect(strategy.net).to be(30)
      end
    end

    context "given a historic with one gain on short then time limit reached" do
      it "runs the strategy and set results, when second gain in same first contract price range" do
        strategy.historic =
          [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3051,   qty:1, ask:"A", bid:"B", :agressor=>:ask},
           { date:DateTime.strptime("31/01/2017 10:00:02", "%d/%m/%Y %H:%M:%S"), value:3050,   qty:1, ask:"C", bid:"D", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 10:00:03", "%d/%m/%Y %H:%M:%S"), value:3050,   qty:1, ask:"E", bid:"F", :agressor=>:bid},
           { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3050,   qty:1, ask:"E", bid:"F", :agressor=>:bid}]

          strategy.run_strategy

          expect(strategy.net).to be(20)
      end
    end

  end
end
