require 'date'
require 'containers/container_v1'
require 'inputs'
require 'data_loader'
require 'data_loader'
require 'strategies/opening_v1'
require 'Reporter'

describe ContainerV1 do
  let(:matrix_db) { double }
  let(:matrix_poss_db) { double }
  let(:strategy_name) { "opening_v1" }
  let(:strat_equity) { "opening_v1_WDO" }
  let(:possibilities) {[{total_loss:-100, total_gain:200, stop:4, start:3, gain_1:4, gain_2:5, net:0, stops:0, gains:0}]}

  before do
    allow(Reporter).to receive(:by_possibility)
    allow(MatrixDB).to receive(:new).and_return(matrix_db)
    allow(matrix_db).to receive(:on).with(:results) { matrix_db }
    allow(matrix_db).to receive(:on).with(:possibilities) { matrix_poss_db }
    allow(matrix_db).to receive(:find).with({strategy_name:strat_equity, possId:0}).and_return([{possId:0, net:10}])
    allow(matrix_poss_db).to receive(:insert_many)
    allow(matrix_poss_db).to receive(:find).with({"name":strat_equity}).and_return([])
    allow(matrix_db).to receive(:close)
    allow(OpeningV1).to receive(:create_inputs).and_return(possibilities)
  end

  describe "#ticval_discover" do
    context "ginven the equity WDO" do
      it "returns 10 as ticval" do
        ticval = ContainerV1.new.ticval_discover("WDO")
        expect(ticval).to eq(10)
      end
    end
    context "ginven the equity WIN" do
      it "returns 1 as ticval" do
        ticval = ContainerV1.new.ticval_discover("WIN")
        expect(ticval).to eq(1)
      end
    end
    context "ginven no equity" do
      it "returns 10 as ticval" do
        ticval = ContainerV1.new.ticval_discover
        expect(ticval).to eq(10)
      end
    end
    context "ginven nil as equity" do
      it "returns 10 as ticval" do
        ticval = ContainerV1.new.ticval_discover(nil)
        expect(ticval).to eq(10)
      end
    end
  end

  describe "#equity_from_strat" do
    context "given an strat_equity opening_v1_WDO" do
      it "returs WDO as equity" do
        equity = ContainerV1.new.equity_from_strat("opening_v1_WDO")
        expect(equity).to eq("WDO")
      end
    end
    context "given an strat_equity opening_pullback_v1_WIN" do
      it "returs WIN as equity" do
        equity = ContainerV1.new.equity_from_strat("opening_pullback_v1_WIN")
        expect(equity).to eq("WIN")
      end
    end
    context "given an strat_equity opening_v1 (whithout equity)" do
      it "returs nil as equity" do
        equity = ContainerV1.new.equity_from_strat("opening_v1")
        expect(equity).to eq(nil)
      end
    end
  end

  describe "#run_results" do
    context "given a possibilities and all results processed" do
      it "prepare and show results" do
        ContainerV1.new.run_results(strat_equity)

        expect(matrix_poss_db).to have_received(:insert_many).with(possibilities)
        expect(matrix_db).to have_received(:find).with({strategy_name:strat_equity, possId:0})
        expect(Reporter).to have_received(:by_possibility)
        expect(matrix_poss_db).to have_received(:find).with({"name":strat_equity})
        expect(matrix_db).to have_received(:close)
      end
    end

    context "given a possibilities, all results processed and a specific possibility" do
      it "do nothing because the specific possibility was given doesnt exists" do
        ContainerV1.new.run_results(strat_equity, possId:1859)

        expect(matrix_poss_db).to have_received(:insert_many).with(possibilities)
        expect(matrix_db).not_to receive(:find).with({strategy_name:strategy_name, possId:0})
        expect(Reporter).not_to receive(:by_possibility)
        expect(matrix_poss_db).not_to receive(:find).with({"name":strat_equity})
        expect(matrix_db).to have_received(:close)
      end
    end
  end

  describe "#create_posssibilities" do
    context "a matrix_db object with connection to the database" do
      it "returns the strategy possibilities or create another one" do
        results = ContainerV1.new.create_posssibilities(matrix_db, strat_equity)

        expect(matrix_poss_db).to have_received(:find).with({"name":strat_equity})
        expect(matrix_poss_db).to have_received(:insert_many).with(possibilities)

        results.first.delete(:possId)
        expect(results).to eq(possibilities)
      end
    end

    context "a matrix_db object with connection to the database" do
      it "returns the strategy possibilities or create another one, fetched from matrix db" do
        allow(matrix_poss_db).to receive(:find).with({"name":strat_equity}).and_return(possibilities)
        results = ContainerV1.new.create_posssibilities(matrix_db, strat_equity)

        expect(matrix_poss_db).to have_received(:find).with({"name":strat_equity})
        expect(matrix_poss_db).not_to receive(:insert_many)

        results.first.delete(:possId)
        expect(results).to eq(possibilities)
      end
    end
  end

  describe "#prepare_results" do
    context "given a possibilities and all results is processed" do
      it "prepares and report results" do
        possibilities.first[:possId] = 0
        ContainerV1.new.prepare_results(possibilities, matrix_db, strat_equity)

        expect(matrix_db).to have_received(:find).with({strategy_name:strat_equity, possId:0})
        expect(Reporter).to have_received(:by_possibility)
        expect(possibilities.first[:net]).to eq(10)
      end
    end
  end

  describe "#start" do
    let(:strategy) {double}
    let(:tt) { { date:DateTime.new, value:1, qty:1, ask:"A", bid:"B", agressor:"Comprador" } }
    let(:data_loader) { double }
    let(:file_name) { "WDOH17_Trade_31-01-2017.csv" }
    let(:other_file_name) { "WDOJ17_Trade_01-02-2017.csv" }

    before do
      allow(DataLoader).to receive(:new).and_return(data_loader)
      allow(DataLoader).to receive(:fetch_trading_days).and_return([file_name])
      allow(OpeningV1).to receive(:new).and_return(strategy)
      allow(strategy).to receive(:run_strategy).and_return(10)
      allow(strategy).to receive(:visual=)
      allow(data_loader).to receive(:load).and_return({tt:[tt]})
      allow(data_loader).to receive(:close)
      allow(matrix_db).to receive(:insert_one)
      allow(matrix_db).to receive(:delete)
    end

    context "given default parameters for possibilities" do
      it "runs the default strategy by day and print a report" do
        trading_day = DateTime.strptime("31/01/2017" , "%d/%m/%Y")
        allow(matrix_db).to receive(:find).with({strategy_name:strat_equity, date:trading_day}).and_return([])

        ContainerV1.new.start

        #expect(Reporter).to have_received(:by_possibility)
        expect(DataLoader).to have_received(:fetch_trading_days).with("WDO")
        expect(data_loader).to have_received(:load).with(file_name)
        expect(data_loader).to have_received(:close)

        expect(matrix_poss_db).to have_received(:insert_many).with(possibilities)
        expect(matrix_poss_db).to have_received(:find).with({"name":strat_equity})
        #expect(matrix_db).to have_received(:find).with({strategy_name:strat_equity, possId:0})
        expect(matrix_db).to have_received(:insert_one)
        expect(matrix_db).to have_received(:close).twice
        expect(matrix_db).to have_received(:find).with({strategy_name:strat_equity, date:trading_day})
      end
    end

    context "given default parameters for possibilities" do
      it "runs the default strategy, but do nothing because strategy was already ran for the given day. Will just print a report" do
        trading_day = DateTime.strptime("31/01/2017" , "%d/%m/%Y")
        allow(matrix_db).to receive(:find).with({strategy_name:strat_equity, date:trading_day}).and_return([{possId:0, net:10}])

        ContainerV1.new.start

        #expect(Reporter).to have_received(:by_possibility)
        expect(DataLoader).to have_received(:fetch_trading_days).with("WDO")
        expect(data_loader).to have_received(:close)

        expect(matrix_poss_db).to have_received(:insert_many).with(possibilities)
        expect(matrix_poss_db).to have_received(:find).with({"name":strat_equity})
        #expect(matrix_db).to have_received(:find).with({strategy_name:strat_equity, possId:0})
        expect(OpeningV1).not_to receive(:new)
        expect(matrix_db).not_to receive(:insert_one)
        expect(matrix_db).to have_received(:close).twice
        expect(matrix_db).to have_received(:find).with({strategy_name:strat_equity, date:trading_day})
      end
    end

    context "given default parameters for possibilities and specific array os trading days" do
      it "runs the default strategy, but do nothing because the given trading day doesnt exists" do
        trading_day = DateTime.strptime("31/01/2017" , "%d/%m/%Y")

        allow(matrix_db).to receive(:find).with({strategy_name:strat_equity, date:trading_day}).and_return([{possId:0, net:10}])
        ContainerV1.new.start({trading_days:[trading_day]})

        #expect(Reporter).to have_received(:by_possibility)
        expect(DataLoader).to have_received(:fetch_trading_days).with("WDO")
        expect(data_loader).not_to receive(:close)

        expect(matrix_poss_db).to have_received(:find).with({"name":strat_equity})
        expect(matrix_poss_db).to have_received(:insert_many).with(possibilities)
        expect(matrix_db).not_to receive(:find).with({strategy_name:strat_equity, date:trading_day})
        expect(matrix_db).not_to receive(:find).with({strategy_name:strat_equity, possId:0})
        expect(OpeningV1).not_to receive(:new)
        expect(matrix_db).not_to receive(:insert_one)
        expect(matrix_db).to have_received(:close).once
        expect(matrix_db).not_to receive(:find).with({strategy_name:strat_equity, date:trading_day})
      end
    end

    context "given default parameters for possibilities and specific array os trading days" do
      it "runs the default strategy, but only for the allowed day" do
        trading_day = DateTime.strptime("31/01/2017" , "%d/%m/%Y")
        other_day = DateTime.strptime("01/02/2017" , "%d/%m/%Y")

        allow(DataLoader).to receive(:fetch_trading_days).and_return([file_name, other_file_name])
        allow(matrix_db).to receive(:find).with({strategy_name:strat_equity, date:trading_day}).and_return([])
        ContainerV1.new.start({trading_days:[trading_day.strftime("%d/%m/%Y")]})

        #expect(Reporter).to have_received(:by_possibility)
        expect(DataLoader).to have_received(:fetch_trading_days).with("WDO")
        expect(data_loader).to have_received(:load).with(file_name)
        expect(data_loader).to have_received(:close)

        expect(matrix_poss_db).to have_received(:insert_many).with(possibilities)
        expect(matrix_poss_db).to have_received(:find).with({"name":strat_equity})

        expect(matrix_db).to have_received(:find).with({strategy_name:strat_equity, date:trading_day})

        #expect(matrix_db).to have_received(:find).with({strategy_name:strat_equity, possId:0})
        expect(matrix_db).to have_received(:insert_one)
        expect(matrix_db).to have_received(:close).twice

        expect(matrix_db).to have_received(:find).with({strategy_name:strat_equity, date:trading_day})
        expect(matrix_db).not_to receive(:find).with({strategy_name:strat_equity, date:other_day})
      end
    end
  end

end
