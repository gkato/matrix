require 'strategies/opening_pullback_v3'

describe OpeningPullbackV3 do
  let(:poss_mult) { {stop:1, gain_1:1, gain_2:2, gain_3:3, gain_4:4, mult_1:6, mult_2:2, start:3, pullback:2, total_gain:170, total_loss:-100, net:0, one_shot:true, flow:10} }
  let(:tic_value) { 10 }
  let(:limit_time) { 10 }
  let(:openning) { 3050 }
  let(:historic) do
    [{ date:DateTime.strptime("31/01/2017 09:01:01", "%d/%m/%Y %H:%M:%S"), value:3051, qty:10, ask:"A", bid:"B", agressor:"Comprador"},
     { date:DateTime.strptime("31/01/2017 09:02:02", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"C", bid:"D",  agressor:"Comprador"},
     { date:DateTime.strptime("31/01/2017 09:03:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F",  agressor:"Comprador"},
     { date:DateTime.strptime("31/01/2017 09:04:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F",  agressor:"Comprador"},
     { date:DateTime.strptime("31/01/2017 09:05:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F",  agressor:"Comprador"},
     { date:DateTime.strptime("31/01/2017 09:06:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F",  agressor:"Vendedor"},
     { date:DateTime.strptime("31/01/2017 09:07:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F",  agressor:"Vendedor"},
     { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F",  agressor:"Vendedor"},
     { date:DateTime.strptime("31/01/2017 09:09:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F",  agressor:"Comprador"},
     { date:DateTime.strptime("31/01/2017 09:10:03", "%d/%m/%Y %H:%M:%S"), value:3054, qty:1, ask:"E", bid:"F",  agressor:"Comprador"},
     { date:DateTime.strptime("31/01/2017 09:11:03", "%d/%m/%Y %H:%M:%S"), value:3055, qty:1, ask:"E", bid:"F",  agressor:"Comprador"},
     { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3056, qty:1, ask:"E", bid:"F",  agressor:"Comprador"},
     { date:DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), value:3057, qty:1, ask:"E", bid:"F",  agressor:"Comprador"}]
  end
  let(:strategy) { OpeningPullbackV3.new(poss_mult, tic_value, limit_time, historic, openning) }

  describe "#indicators_filter" do
    context "given an long await_pullback" do
      it "filters by flow indicator and return true if flow balance greater equal than 10" do
        strategy.flow_balance.balance = 10
        result = strategy.indicators_filter(:pb_long)
        expect(result).to eq(true)
      end
      it "filters by flow indicator and return false if flow balance less than 10" do
        strategy.flow_balance.balance = 9
        result = strategy.indicators_filter(:pb_long)
        expect(result).to eq(false)
      end
    end
    context "given an short await_pullback" do
      it "filters by flow indicator and return true if flow less equal than -10" do
        strategy.flow_balance.balance = -10
        result = strategy.indicators_filter(:pb_short)
        expect(result).to eq(true)
      end
      it "filters by flow indicator and return false if flow balance greater than -9" do
        strategy.flow_balance.balance = -9
        result = strategy.indicators_filter(:pb_short)
        expect(result).to eq(false)
      end
    end
  end

  describe "#run_strategy" do
    context "given a historic (default) with a simple gain (long) sequence, and a flow balance greater than 10" do
      it "runs the strategy and returns net profit, flow filter was reached" do
        strategy.run_strategy

        expect(strategy.net).to be(170)
      end
    end
    context "given a historic (default) with a simple gain (long) sequence, and a flow balance less than 10" do
      it "runs the strategy and returns net profit, flow filter was not reached" do
        historic.first[:qty] = 1
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
    end
    context "given a historic (default) with a simple gain (short) sequence" do
      let(:short_historic) do
        [{ date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3049, qty:10, ask:"A", bid:"B",   agressor:"Vendedor"},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D",   agressor:"Vendedor"},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"E", bid:"F",   agressor:"Vendedor"},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D",   agressor:"Comprador"},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"C", bid:"D",   agressor:"Comprador"},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3048, qty:1, ask:"C", bid:"D",   agressor:"Vendedor"},
         { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3047, qty:1, ask:"C", bid:"D",   agressor:"Vendedor"},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3046, qty:1, ask:"E", bid:"F",   agressor:"Vendedor"},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3045, qty:1, ask:"E", bid:"F",   agressor:"Vendedor"},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3044.5, qty:1, ask:"E", bid:"F", agressor:"Vendedor"},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3044, qty:1, ask:"E", bid:"F",   agressor:"Vendedor"},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3043.5, qty:1, ask:"E", bid:"F", agressor:"Vendedor"},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3042, qty:1, ask:"E", bid:"F",   agressor:"Vendedor"},
         { date:DateTime.strptime("31/01/2017 09:00:03", "%d/%m/%Y %H:%M:%S"), value:3041, qty:1, ask:"E", bid:"F",   agressor:"Vendedor"}]
      end
      it "runs the strategy and returns 170 for net profit when flow filter was reached" do
        strategy.historic = short_historic
        strategy.run_strategy

        expect(strategy.net).to be(170)
      end
      it "runs the strategy and returns 0 for net profit when flow filter was not reached" do
        short_historic.first[:qty] = 1
        strategy.historic = short_historic
        strategy.run_strategy

        expect(strategy.net).to be(0)
      end
      it "runs the strategy, flow filter was not reached o ther short movement, then fliped to long moventen and flow been reached" do
        short_historic.first[:qty] = 1
        short_historic << { date:DateTime.strptime("31/01/2017 09:01:01", "%d/%m/%Y %H:%M:%S"), value:3042, qty:1, ask:"A", bid:"B", agressor:"Comprador"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:02:02", "%d/%m/%Y %H:%M:%S"), value:3045, qty:1, ask:"C", bid:"D",  agressor:"Comprador"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:03:03", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"E", bid:"F",  agressor:"Comprador"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:04:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F",  agressor:"Comprador"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:05:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:40, ask:"E", bid:"F",  agressor:"Comprador"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:06:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F",  agressor:"Vendedor"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:07:03", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"E", bid:"F",  agressor:"Vendedor"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:08:03", "%d/%m/%Y %H:%M:%S"), value:3052, qty:1, ask:"E", bid:"F",  agressor:"Vendedor"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:09:03", "%d/%m/%Y %H:%M:%S"), value:3053, qty:1, ask:"E", bid:"F",  agressor:"Comprador"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:10:03", "%d/%m/%Y %H:%M:%S"), value:3054, qty:1, ask:"E", bid:"F",  agressor:"Comprador"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:11:03", "%d/%m/%Y %H:%M:%S"), value:3055, qty:1, ask:"E", bid:"F",  agressor:"Comprador"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:12:03", "%d/%m/%Y %H:%M:%S"), value:3056, qty:1, ask:"E", bid:"F",  agressor:"Comprador"}
        short_historic << { date:DateTime.strptime("31/01/2017 09:13:03", "%d/%m/%Y %H:%M:%S"), value:3057, qty:1, ask:"E", bid:"F",  agressor:"Comprador"}
        strategy.historic = short_historic
        strategy.run_strategy

        expect(strategy.net).to be(170)
      end
    end
  end
end
