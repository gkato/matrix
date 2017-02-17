require 'strategy'
require 'tt'

describe Strategy do
  let(:poss) { {stop:1, gain_1:1, gain_2:2, start:1, total_gain:100, total_loss:-100, net:0, per_day:[]} }
  let(:tic_value) { 10 }
  let(:limit_time) { 10 }
  let(:historic) do
    [TT.new(DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), 3050, 1, "A", "B", :ask),
    TT.new(DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), 3051, 1, "C", "D", :bid),
    TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3049, 1, "E", "F", :bid)]
  end
  let(:openning) { 3052 }
  let(:formated_date) { "31/01/2017" }
  let(:strategy) { Strategy.new(poss, tic_value, limit_time, historic, openning, formated_date) }

  describe "#risky?" do
    context "given a strategy possibility and 0 for net" do
      it "returns false when net is 0 and is not risky" do
        expect(strategy.risky?).to be(false)
      end
    end

    context "given a strategy possibility and 100 for net" do
      it "returns true when net is equal than total_gain and is risky" do
        strategy.net = poss[:total_gain]
        expect(strategy.risky?).to be(true)
      end
    end

    context "given a strategy possibility and 120 for net" do
      it "returns true when net is greater than total_gain and is risky" do
        strategy.net = poss[:total_gain] + 20
        expect(strategy.risky?).to be(true)
      end
    end

    context "given a strategy possibility and -100 for net" do
      it "returns true when net is equal than total_loss and is risky" do
        strategy.net = poss[:total_loss]
        expect(strategy.risky?).to be(true)
      end
    end

    context "given a strategy possibility and -120 for net" do
      it "returns true when net is equal than total_loss and is risky" do
        strategy.net = poss[:total_loss] - 20
        expect(strategy.risky?).to be(true)
      end
    end

    describe "#enter_position" do
      before do
        strategy.net = 0
        strategy.current = nil
      end

      context "Not enter position if risky (loss)" do
        it "do nothing when is risky because of loss limit" do
          strategy.net = poss[:total_loss]

          strategy.enter_position :long
          expect(strategy.position).to be(:liquid)
        end
      end
      context "Not enter position if risky (gain)" do
        it "do nothing when is risky because of gain limit" do
          strategy.net = poss[:total_gain]

          strategy.enter_position :short
          expect(strategy.position).to be(:liquid)
        end
      end
      context "Not risky goes long" do
        it "enter in a long position when not risky" do
          strategy.current = historic.first
          strategy.enter_position :short

          expect(strategy.position).to be(:short)
          expect(strategy.position_val).to be(historic.first.value)
          expect(strategy.position_size).to be(2)
          expect(strategy.allowed).to be(false)
        end
      end
    end
  end

  describe "#close" do
    context "when close position is requested" do
      it "closes the postion" do
        strategy.position_size = 2
        strategy.position = :liquid

        strategy.close_position

        expect(strategy.position_size).to be(0)
        expect(strategy.position).to be(:liquid)
        expect(strategy.position_val).to be(nil)
      end
    end
  end

  describe "#take_profit" do
    before do
      strategy.net = 0
      strategy.current = historic.first
      strategy.position_size = 2
    end
    context "given a price to take profit on long" do
      it "increases net by the diference between entrance and current tic position" do
        strategy.position_val = historic.first.value - 1
        strategy.take_profit
        expect(strategy.net).to be(10)
        expect(strategy.position_size).to be(1)
      end
    end
    context "given a price to take profit on short" do
      it "increases net by the diference between entrance and current tic position" do
        strategy.position_val = historic.first.value + 1
        strategy.take_profit
        expect(strategy.net).to be(10)
        expect(strategy.position_size).to be(1)
      end
    end
  end

  describe "#take_loss" do
    let(:flip_flag) { false }
    before do
      strategy.net = 0
      strategy.current = historic.first
      strategy.position = :long
      strategy.position_val = strategy.current.value - 1
    end

    context "given a price reached by stop parameter" do
      it "takes loss on profit and closes position when flip flag is false" do
        strategy.take_loss(flip_flag)
        expect(strategy.net).to be(-20) #stop if start+stop range size
        expect(strategy.position).to be(:liquid)
        expect(strategy.position_size).to be(0)
        expect(strategy.position_val).to be(nil)
      end
    end

    context "given a price reached by stop parameter" do
      it "takes loss on profit and flips position when flip flag is true" do
        flip_flag = true

        strategy.take_loss(flip_flag)
        expect(strategy.net).to be(-20) #stop if start+stop range size
        expect(strategy.position).to be(:short)
        expect(strategy.position_size).to be(2)
        expect(strategy.position_val).to be(strategy.current.value)
      end
    end

    context "given a price reached by stop parameter" do
      it "takes loss on profit and closes position when flip flag is true but reached the time limit" do
        flip_flag = true
        strategy.current.date = DateTime.strptime("31/01/2017 11:00:01", "%d/%m/%Y %H:%M:%S")

        strategy.take_loss(flip_flag)
        expect(strategy.net).to be(-20) #stop if start+stop range size
        expect(strategy.position).to be(:liquid)
        expect(strategy.position_size).to be(0)
        expect(strategy.position_val).to be(nil)
      end
    end
  end

  describe "#run_strategy" do
    before do
      strategy.historic =
      [TT.new(DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), 3050, 1, "A", "B", :ask),
      TT.new(DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), 3051, 1, "C", "D", :bid),
      TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3049, 1, "E", "F", :bid)]
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
          [TT.new(DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), 3050, 1, "A", "B", :ask),
          TT.new(DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), 3051, 1, "C", "D", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3053, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3053.5, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3051, 1, "E", "F", :bid)]

          strategy.run_strategy

          expect(strategy.net).to be(-100)
      end
    end

    context "given a historic with one take loss and one take profit" do
      it "runs the strategy and set results, onte stop a one gain with an up gap" do
        strategy.historic =
          [TT.new(DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), 3050, 1, "A", "B", :ask),
          TT.new(DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), 3051, 1, "C", "D", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3053, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3054, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3056, 1, "E", "F", :bid)]

          strategy.run_strategy

          expect(strategy.net).to be(-20)
      end
    end

    context "given a historic with one take loss and one take profit" do
      it "runs the strategy and set results, onte stop a one gain with an up gap (hugher)" do
        strategy.historic =
          [TT.new(DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), 3050, 1, "A", "B", :ask),
          TT.new(DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), 3051, 1, "C", "D", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3053, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3054, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3059, 1, "E", "F", :bid)]

          strategy.run_strategy

          expect(strategy.net).to be(10)
      end
    end

    context "given a historic with one take profit for first contract an break even for second (short)" do
      it "runs the strategy, takes profit for the first contract and breakeven the second contract" do
        strategy.historic =
          [TT.new(DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), 3050, 1, "A", "B", :ask),
          TT.new(DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), 3049, 1, "C", "D", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3050, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3053, 1, "E", "F", :bid)]

          strategy.breakeven = true
          strategy.run_strategy

          expect(strategy.net).to be(10)
      end
    end

    context "given a historic with one take profit for first contract an break even for second (long)" do
      it "runs the strategy, takes profit for the first contract and breakeven the second contract" do
        strategy.historic =
          [TT.new(DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), 3053, 1, "A", "B", :ask),
          TT.new(DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), 3054, 1, "C", "D", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3053, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3052, 1, "E", "F", :bid)]

          strategy.breakeven = true
          strategy.run_strategy

          expect(strategy.net).to be(10)
      end

    end
    context "given a historic with two gains on short" do
      it "runs the strategy and set results, two gains (no gaps)" do
        strategy.historic =
          [TT.new(DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), 3050, 1, "A", "B", :ask),
          TT.new(DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), 3049, 1, "C", "D", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3048, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3047, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3052.5, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3051, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3050, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3049, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3051, 1, "E", "F", :bid)]

          strategy.run_strategy

          expect(strategy.net).to be(60)
      end
    end

    context "given a historic with two gains on long" do
      it "runs the strategy and set results, two gains (no gaps), then time limit" do
        strategy.historic =
          [TT.new(DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), 3053, 1, "A", "B", :ask),
          TT.new(DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), 3054, 1, "C", "D", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3055, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3051.5, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3055, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3056, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), 3057, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 11:00:03", "%d/%m/%Y %H:%M:%S"), 3048, 1, "E", "F", :bid),
          TT.new(DateTime.strptime("31/01/2017 11:00:03", "%d/%m/%Y %H:%M:%S"), 3047, 1, "E", "F", :bid)]

          strategy.run_strategy

          expect(strategy.net).to be(60)
      end
    end
  end
end
