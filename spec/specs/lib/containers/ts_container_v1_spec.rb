require 'containers/ts_container_v1'
require 'trade_systems/trade_system_v1'

describe TSContainerV1 do
  let(:trade_system) { double }
  let(:matrix_db) { double }
  let(:ts_name) { "ts_opening_pullback_v1_WDO" }
  let(:inputs) { [{index:1, n_days:1}, {index:2, n_days:2}] }

  before do
    allow(matrix_db).to receive(:on).with("trade_systems").and_return(matrix_db)
    allow(matrix_db).to receive(:insert_many)
    allow(matrix_db).to receive(:close)
    allow(TradeSystemV1).to receive(:new).and_return(trade_system)
    allow(MatrixDB).to receive(:new).and_return(matrix_db)
    allow(trade_system).to receive(:clear_simulation_fields)
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

  describe "#create_trade_systems" do
    before do
      allow(TradeSystemV1).to receive(:create_inputs).and_return(inputs)
    end
    context "given a set of possibilities" do
      it "combine possibilities, create tradesystems and store on database" do
        allow(matrix_db).to receive(:find).with({name:ts_name}).and_return([])

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
        TSContainerV1.new.start
        expect(matrix_db).to have_received(:close)
        expect(trade_system).to have_received(:clear_simulation_fields)
      end
    end
  end
end
