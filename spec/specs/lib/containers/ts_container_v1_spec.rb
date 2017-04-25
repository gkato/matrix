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
  let(:strat_equity) { "opening_pullback_v1_WDO" }
  let(:inputs) { [{index:1, n_days:1, stop:1}, {index:2, n_days:2, stop:2}] }
  let(:inputs_initial) { [{tsId:0, index:1, n_days:1, stop:1, initial_index:1, :name=>"ts_opening_pullback_v1_WDO"}, {tsId:1, index:2, n_days:2, stop:2, initial_index:1, :name=>"ts_opening_pullback_v1_WDO"}] }

  before do
    allow(matrix_db).to receive(:on).with("trade_systems").and_return(matrix_db)
    allow(matrix_db).to receive(:on).with("results").and_return(matrix_results_db)
    allow(matrix_db).to receive(:on).with("possibilities").and_return(matrix_poss_db)
    allow(matrix_db).to receive(:insert_many)
    allow(matrix_db).to receive(:close)
    allow(MatrixDB).to receive(:new).and_return(matrix_db)
    allow(trade_system).to receive(:clear_simulation_fields)
    allow(trade_system_other).to receive(:clear_simulation_fields)
    allow(TradeSystemV1).to receive(:create_inputs).and_return(inputs)
    allow(matrix_db).to receive(:find).with({name:ts_name}).and_return([])
  end

  describe "#tradesystem_infos" do
    before { allow(TradeSystemV1).to receive(:new).and_return(trade_system) }
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
    before { allow(TradeSystemV1).to receive(:new).and_return(trade_system) }
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

  describe "#first_simulation_day_from" do
    context "given a first day of a strat equity" do
      it "returns the first day of the next month from the given date" do
        start_date = DateTime.strptime("01/02/2017", "%d/%m/%Y")
        first_day_next_month = DateTime.strptime("01/03/2017", "%d/%m/%Y")

        result = TSContainerV1.new.first_simulation_day_from(start_date)
        expect(result).to eq(first_day_next_month)
      end
    end
  end

  describe "#create_trade_systems" do
    before { allow(TradeSystemV1).to receive(:new).and_return(trade_system) }
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

  describe "#show_ts_trace" do
    before { allow(TradeSystemV1).to receive(:new).and_return(trade_system) }
    context "given a trade system id" do
      it "prints the trade system trace" do
        date = Time.new(2017, 02, 02, 0, 0, 0)
        start_date = DateTime.strptime("#{date.day}/#{date.month}/#{date.year}", "%d/%m/%Y")
        query = {strategy_name:strat_equity}
        expected = {possId:1, date:date, net:40, strategy_name:strat_equity}
        allow(matrix_results_db).to receive(:find).with(query).and_return(matrix_result)
        allow(matrix_result).to receive(:sort).with({date:1}).and_return(matrix_result)
        allow(matrix_result).to receive(:limit).with(1).and_return(matrix_result)
        allow(matrix_result).to receive(:first).and_return(expected)

        poss = {tsId:1, index:1, n_days:1, stop:1, initial_index:1}
        expected_simulation = [{tsId:1, net:-10, possId:2, date:DateTime.new}]
        opts = {start_date:start_date, index:poss[:index], n_days:poss[:n_days], tsId:poss[:tsId], name:ts_name, stop:poss[:stop], initial_index:poss[:initial_index]}

        allow(matrix_db).to receive(:find).with({tsId:poss[:tsId], name:ts_name}).and_return([poss])
        allow(TradeSystemV1).to receive(:new).with(strat_equity, opts).and_return(trade_system)
        allow(trade_system).to receive(:fetch_all_simulations).and_return(expected_simulation)

        TSContainerV1.new.show_ts_trace(poss[:tsId], ts_name)

        expect(matrix_db).to have_received(:find).with({tsId:poss[:tsId], name:ts_name})
        expect(TradeSystemV1).to have_received(:new).with(strat_equity, opts)
        expect(trade_system).to have_received(:fetch_all_simulations)
      end
    end
    context "given a trade system id" do
      it "does nothing because no trade system was fonund for the given id" do
        poss = {tsId:1, index:1, n_days:1, stop:1, initial_index:1}

        allow(matrix_db).to receive(:find).with({tsId:poss[:tsId], name:ts_name}).and_return([])

        TSContainerV1.new.show_ts_trace(poss[:tsId], ts_name)

        expect(matrix_db).to have_received(:find).with({tsId:poss[:tsId], name:ts_name})
        expect(TradeSystemV1).not_to receive(:new)
        expect(trade_system).not_to receive(:fetch_all_simulations)
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
        start_date = DateTime.strptime("01/01/2017", "%d/%m/%Y")
        query = {strategy_name:strat_equity}
        result_start_date = {possId:1, date:start_date, net:40, strategy_name:strat_equity}
        allow(matrix_results_db).to receive(:find).with(query).and_return(matrix_result)
        allow(matrix_result).to receive(:sort).with({date:1}).and_return(matrix_result)
        allow(matrix_result).to receive(:limit).with(1).and_return(matrix_result)
        allow(matrix_result).to receive(:first).and_return(result_start_date)

        first_simulation_day = TSContainerV1.new.first_simulation_day_from(start_date)

        # Tradesystem opts and expected returns
        opts_ts1 = {start_date:first_simulation_day, index:inputs[0][:index], n_days:inputs[0][:n_days], tsId:inputs[0][:tsId], name:inputs[0][:name], stop:inputs[0][:stop]}
        opts_ts2 = {start_date:first_simulation_day, index:inputs[1][:index], n_days:inputs[1][:n_days], tsId:inputs[1][:tsId], name:inputs[1][:name], stop:inputs[1][:stop]}
        expected_ts1 = {tsId:opts_ts1[:tsId], net:30, next_poss:1, name:ts_name}
        expected_ts2 = {tsId:opts_ts2[:tsId], net:10, next_poss:2, name:ts_name}

        # Allows
        allow(TradeSystemV1).to receive(:new).with(strat_equity, opts_ts1).and_return(trade_system)
        allow(TradeSystemV1).to receive(:new).with(strat_equity, opts_ts2).and_return(trade_system_other)
        allow(trade_system).to receive(:simulate).and_return(expected_ts1)
        allow(trade_system_other).to receive(:simulate).and_return(expected_ts2)

        TSContainerV1.new.start(ts_name)
        expect(matrix_db).to have_received(:close)
        expect(trade_system).to have_received(:clear_simulation_fields).once
        expect(trade_system).to have_received(:simulate).once
        expect(trade_system_other).to have_received(:simulate).once
        expect(trade_system_other).to have_received(:clear_simulation_fields).once
      end
    end

    context "given a trade system with initial index and a strategy" do
      it "runs the trade system simulation for all possibilities and save results" do
        allow(matrix_db).to receive(:find).with({name:ts_name}).and_return(inputs_initial)
        strat_equity = ts_name.gsub("ts_","")

        # First date
        start_date = DateTime.strptime("01/01/2017", "%d/%m/%Y")
        query = {strategy_name:strat_equity}
        result_start_date = {possId:1, date:start_date, net:40, strategy_name:strat_equity}
        allow(matrix_results_db).to receive(:find).with(query).and_return(matrix_result)
        allow(matrix_result).to receive(:sort).with({date:1}).and_return(matrix_result)
        allow(matrix_result).to receive(:limit).with(1).and_return(matrix_result)
        allow(matrix_result).to receive(:first).and_return(result_start_date)

        first_simulation_day = TSContainerV1.new.first_simulation_day_from(start_date)

        # Tradesystem opts and expected returns
        opts_ts1 = {start_date:first_simulation_day, index:inputs_initial[0][:index], n_days:inputs_initial[0][:n_days], tsId:inputs_initial[0][:tsId], name:inputs_initial[0][:name], stop:inputs_initial[0][:stop], initial_index:inputs_initial[0][:initial_index]}
        opts_ts2 = {start_date:first_simulation_day, index:inputs_initial[1][:index], n_days:inputs_initial[1][:n_days], tsId:inputs_initial[1][:tsId], name:inputs_initial[1][:name], stop:inputs_initial[1][:stop], initial_index:inputs_initial[1][:initial_index]}
        expected_ts1 = {tsId:opts_ts1[:tsId], net:30, next_poss:1, name:ts_name}
        expected_ts2 = {tsId:opts_ts2[:tsId], net:10, next_poss:2, name:ts_name}

        # Allows
        allow(TradeSystemV1).to receive(:new).with(strat_equity, opts_ts1).and_return(trade_system)
        allow(TradeSystemV1).to receive(:new).with(strat_equity, opts_ts2).and_return(trade_system_other)
        allow(trade_system).to receive(:simulate).and_return(expected_ts1)
        allow(trade_system_other).to receive(:simulate).and_return(expected_ts2)

        TSContainerV1.new.start(ts_name)
        expect(matrix_db).to have_received(:close)
        expect(trade_system).to have_received(:clear_simulation_fields).once
        expect(trade_system).to have_received(:simulate).once
        expect(trade_system_other).to have_received(:simulate).once
        expect(trade_system_other).to have_received(:clear_simulation_fields).once
      end
    end

    context "given a trade system and a strategy" do
      it "runs the trade system simulation for a specific strategy" do
        inputs[0][:name] = ts_name
        inputs[0][:tsId] = 0
        inputs[1][:name] = ts_name
        inputs[1][:tsId] = 1

        allow(matrix_db).to receive(:find).with({name:ts_name}).and_return(inputs)
        strat_equity = ts_name.gsub("ts_","")

        # First date
        start_date = DateTime.strptime("01/01/2017", "%d/%m/%Y")
        query = {strategy_name:strat_equity}
        result_start_date = {possId:1, date:start_date, net:40, strategy_name:strat_equity}
        allow(matrix_results_db).to receive(:find).with(query).and_return(matrix_result)
        allow(matrix_result).to receive(:sort).with({date:1}).and_return(matrix_result)
        allow(matrix_result).to receive(:limit).with(1).and_return(matrix_result)
        allow(matrix_result).to receive(:first).and_return(result_start_date)

        first_simulation_day = TSContainerV1.new.first_simulation_day_from(start_date)

        # Tradesystem opts and expected returns
        opts_ts1 = {start_date:first_simulation_day, index:inputs[0][:index], n_days:inputs[0][:n_days], tsId:inputs[0][:tsId], name:inputs[0][:name], stop:inputs[0][:stop]}
        opts_ts2 = {start_date:first_simulation_day, index:inputs[1][:index], n_days:inputs[1][:n_days], tsId:inputs[1][:tsId], name:inputs[1][:name], stop:inputs[1][:stop]}
        expected_ts1 = {tsId:opts_ts1[:tsId], net:30, next_poss:1, name:ts_name}
        expected_ts2 = {tsId:opts_ts2[:tsId], net:10, next_poss:2, name:ts_name}

        # Allows
        allow(TradeSystemV1).to receive(:new).with(strat_equity, opts_ts1).and_return(trade_system)
        allow(TradeSystemV1).to receive(:new).with(strat_equity, opts_ts2).and_return(trade_system_other)
        allow(trade_system).to receive(:simulate).and_return(expected_ts1)
        allow(trade_system_other).to receive(:simulate).and_return(expected_ts2)

        TSContainerV1.new.start(ts_name,tsId:0)
        expect(matrix_db).to have_received(:close)
        expect(trade_system).to have_received(:clear_simulation_fields).once
        expect(trade_system).to have_received(:simulate).once
        expect(trade_system_other).not_to have_received(:simulate)
        expect(trade_system_other).not_to have_received(:clear_simulation_fields)
      end
    end
  end
end
