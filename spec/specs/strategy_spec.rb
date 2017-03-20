require 'strategy'
require 'tt'

describe Strategy do
  let(:poss) { {stop:1, gain_1:1, gain_2:2, start:1, total_gain:100, total_loss:-100, net:0, per_day:[]} }
  let(:tic_value) { 10 }
  let(:limit_time) { 10 }
  let(:historic) do
    [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"A", bid:"B", :agressor=>:ask},
     { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"C", bid:"D", :agressor=>:bid},
     { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>:bid}]
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
      context "Not risky goes short" do
        it "enter in a long position when not risky" do
          tt = historic.first
          strategy.current = TT.new(tt[:date], tt[:value], tt[:qty], tt[:ask], tt[:bid], tt[:agressor])
          #strategy.current = historic.first
          strategy.enter_position :short

          expect(strategy.position).to be(:short)
          expect(strategy.position_val).to be(historic.first[:value])
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
      tt = historic.first
      strategy.current = TT.new(tt[:date], tt[:value], tt[:qty], tt[:ask], tt[:bid], tt[:agressor])
      strategy.position_size = 2
    end
    context "given a price to take profit on long" do
      it "increases net by the diference between entrance and current tic position" do
        strategy.position_val = historic.first[:value] - 1
        strategy.take_profit
        expect(strategy.net).to be(10)
        expect(strategy.position_size).to be(1)
      end
    end
    context "given a price to take profit on short" do
      it "increases net by the diference between entrance and current tic position" do
        strategy.position_val = historic.first[:value] + 1
        strategy.take_profit
        expect(strategy.net).to be(10)
        expect(strategy.position_size).to be(1)
      end
    end
  end

  describe "#take_loss" do
    let(:flip_flag) { false }
    before do
      strategy.position_size = 2
      strategy.net = 0
      tt = historic.first
      strategy.current = TT.new(tt[:date], tt[:value], tt[:qty], tt[:ask], tt[:bid], tt[:agressor])
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

end
