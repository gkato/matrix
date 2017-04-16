require 'containers/ts_container_v1'
require 'trade_systems/trade_system_v1'

describe TSContainerV1 do
  let(:trade_system) { double }
  let(:trade_system_other) { double }
  let(:matrix_db) { double }
  let(:matrix_results_db) { double }
  let(:matrix_poss_db) { double }
  let(:matrix_result) { double }
  let(:ts_name) { "ts_opening_pullback_v1_WDO" }
  let(:inputs) { [{index:1, n_days:1, stop:1}, {index:2, n_days:2, stop:2}] }

  before do
    allow(matrix_db).to receive(:on).with("trade_systems").and_return(matrix_db)
    allow(matrix_db).to receive(:on).with("results").and_return(matrix_results_db)
    allow(matrix_db).to receive(:on).with("possibilities").and_return(matrix_poss_db)
    allow(matrix_db).to receive(:insert_many)
    allow(matrix_db).to receive(:close)
    allow(TradeSystemV1).to receive(:new).and_return(trade_system)
    allow(MatrixDB).to receive(:new).and_return(matrix_db)
    allow(trade_system).to receive(:clear_simulation_fields)
    allow(trade_system_other).to receive(:clear_simulation_fields)
    allow(TradeSystemV1).to receive(:create_inputs).and_return(inputs)
    allow(matrix_db).to receive(:find).with({name:ts_name}).and_return([])
  end

  describe "#tradesystem_infos" do
    context "given a tradesystem ts_opening_v1_WDO" do
      it "returns tradesystem infos in a hash" do
        result = TSContainerV1.new.tradesystem_infos("ts_opening_v1_WDO")
        expect(result).to eq({name:"ts_opening_v1_WDO", strategy_name:"opening_v1", strat_equity:"opening_v1_WDO", equity:"WDO" })
      end
    end

    context "given a tradesystem ts_opening_pullback_v1_WIN" do
      it "returns tradesystem infos in a hash" do
        result = TSContainerV1.new.tradesystem_infos("ts_opening_pullback_v1_WIN")
        expect(result).to eq({name:"ts_opening_pullback_v1_WIN", strategy_name:"opening_pullback_v1", strat_equity:"opening_pullback_v1_WIN", equity:"WIN" })
      end
    end
  end

  describe "#first_day_strat_equity" do
    context "given an strat equity" do
      it "fetchs the first processed date" do
          possId = 1
          strat_equity = "opening_pullback_v1_WDO"
          #date = DateTime.strptime("02/02/2018","%d/%m/%Y")
          date = Time.new(2017, 02, 02, 0, 0, 0)
          query = {strategy_name:strat_equity}
          expected = {possId:possId, date:date, net:40, strategy_name:strat_equity}
          matrix_result = double

          allow(matrix_results_db).to receive(:find).with(query).and_return(matrix_result)
          allow(matrix_result).to receive(:sort).with({date:1}).and_return(matrix_result)
          allow(matrix_result).to receive(:limit).with(1).and_return(matrix_result)
          allow(matrix_result).to receive(:first).and_return(expected)

          result = TSContainerV1.new.first_day_strat_equity(strat_equity)
          expect(matrix_results_db).to have_received(:find).with(query)
          expect(result).to eq(DateTime.strptime("#{date.day}/#{date.month}/#{date.year}", "%d/%m/%Y"))
      end
    end
  end

  describe "#create_trade_systems" do
    context "given a set of possibilities" do
      it "combine possibilities, create tradesystems and store on database" do
        ts = TSContainerV1.new.create_trade_systems(ts_name)

        expect(TradeSystemV1).to have_received(:create_inputs)
        expect(matrix_db).to have_received(:insert_many)
        expect(matrix_db).to have_received(:find).with({name:ts_name})

        expect(ts.size).to eq(2)
        expect(ts[0][:tsId]).to eq(0)
        expect(ts[0][:index]).to eq(1)
        expect(ts[0][:n_days]).to eq(1)
        expect(ts[0][:name]).to eq(ts_name)
        expect(ts[1][:tsId]).to eq(1)
        expect(ts[1][:index]).to eq(2)
        expect(ts[1][:n_days]).to eq(2)
        expect(ts[1][:name]).to eq(ts_name)
      end
    end

    context "given a set of possibilities" do
      it "returns possibilities from DB" do
        inputs[0][:name] = ts_name
        inputs[0][:tsId] = 0
        inputs[1][:name] = ts_name
        inputs[1][:tsId] = 1

        allow(matrix_db).to receive(:find).with({name:ts_name}).and_return(inputs)

        ts = TSContainerV1.new.create_trade_systems(ts_name)

        expect(TradeSystemV1).not_to receive(:create_inputs)
        expect(matrix_db).not_to receive(:insert_many)
        expect(matrix_db).to have_received(:find).with({name:ts_name})

        expect(ts.size).to eq(2)
        expect(ts[0][:tsId]).to eq(0)
        expect(ts[0][:index]).to eq(1)
        expect(ts[0][:n_days]).to eq(1)
        expect(ts[0][:name]).to eq(ts_name)
        expect(ts[1][:tsId]).to eq(1)
        expect(ts[1][:index]).to eq(2)
        expect(ts[1][:n_days]).to eq(2)
        expect(ts[1][:name]).to eq(ts_name)
      end
    end
  end

  describe "#start" do
    context "given a trade system and a strategy" do
      it "runs the trade system simulation for all possibilities and save results" do
        inputs[0][:name] = ts_name
        inputs[0][:tsId] = 0
        inputs[1][:name] = ts_name
        inputs[1][:tsId] = 1

        allow(matrix_db).to receive(:find).with({name:ts_name}).and_return(inputs)
        strat_equity = ts_name.gsub("ts_","")

        # First date
        start_date = DateTime.strptime("01/02/2017", "%d/%m/%Y")
        query = {strategy_name:strat_equity}
        result_start_date = {possId:1, date:start_date, net:40, strategy_name:strat_equity}
        allow(matrix_results_db).to receive(:find).with(query).and_return(matrix_result)
        allow(matrix_result).to receive(:sort).with({date:1}).and_return(matrix_result)
        allow(matrix_result).to receive(:limit).with(1).and_return(matrix_result)
        allow(matrix_result).to receive(:first).and_return(result_start_date)

        # Tradesystem opts and expected returns
        opts_ts1 = {start_date:start_date, index:inputs[0][:index], n_days:inputs[0][:n_days], tsId:inputs[0][:tsId], name:inputs[0][:name], stop:inputs[0][:stop]}
        opts_ts2 = {start_date:start_date, index:inputs[1][:index], n_days:inputs[1][:n_days], tsId:inputs[1][:tsId], name:inputs[1][:name], stop:inputs[1][:stop]}
        expected_ts1 = {tsId:opts_ts1[:tsId], net:30, next_poss:1, name:ts_name}
        expected_ts2 = {tsId:opts_ts2[:tsId], net:10, next_poss:2, name:ts_name}

        # Allows
        allow(TradeSystemV1).to receive(:new).with(strat_equity, opts_ts1).and_return(trade_system)
        allow(TradeSystemV1).to receive(:new).with(strat_equity, opts_ts2).and_return(trade_system_other)
        allow(trade_system).to receive(:simulate).and_return(expected_ts1)
        allow(trade_system_other).to receive(:simulate).and_return(expected_ts2)

        TSContainerV1.new.start(ts_name)
        expect(matrix_db).to have_received(:close)
        expect(trade_system).to have_received(:clear_simulation_fields)
        expect(trade_system).to have_received(:simulate)
        expect(trade_system_other).to have_received(:simulate)
        expect(trade_system_other).to have_received(:clear_simulation_fields)
      end
    end
  end
end
