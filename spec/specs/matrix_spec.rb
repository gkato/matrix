require 'date'
require 'matrix'
require 'inputs'
require 'data_loader'
require 'data_loader'
require 'strategy'
require 'Reporter'

describe Matrix do
  let(:matrix_db) { double }
  let(:matrix_poss_db) { double }
  let(:possibilities) {[{total_loss:-100, total_gain:200, stop:4, start:3, gain_1:4, gain_2:5, net:0, stops:0, gains:0}]}

  before do
    allow(Reporter).to receive(:by_possibility)
    allow(MatrixDB).to receive(:new).and_return(matrix_db)
    allow(matrix_db).to receive(:on).with(:results) { matrix_db }
    allow(matrix_db).to receive(:on).with(:possibilities) { matrix_poss_db }
    allow(matrix_db).to receive(:find).with({possId:0}).and_return([{possId:0, net:10}])
    allow(matrix_poss_db).to receive(:insert_many)
    allow(matrix_poss_db).to receive(:find).with({}).and_return([])
    allow(Inputs).to receive(:combine_arrays).and_return(possibilities)
    allow(Inputs).to receive(:combine_array_map).and_return(possibilities)
    allow(matrix_db).to receive(:close)
  end

  describe "#run_results" do
    context "given a possibilities and all results processed" do
      it "prepare and show results" do
        Matrix.new.run_results

        expect(matrix_poss_db).to have_received(:insert_many).with(possibilities)
        expect(matrix_db).to have_received(:find).with({possId:0})
        expect(Reporter).to have_received(:by_possibility)
        expect(matrix_poss_db).to have_received(:find).with({})
        expect(matrix_db).to have_received(:close)
      end
    end
  end

  describe "#create_posssibilities" do
    context "a matrix_db object with connection to the database" do
      it "returns the strategy possibilities or create another one" do
        results = Matrix.new.create_posssibilities(matrix_db)

        expect(matrix_poss_db).to have_received(:insert_many).with(possibilities)
        expect(matrix_poss_db).to have_received(:find).with({})

        results.first.delete(:possId)
        expect(results).to eq(possibilities)
      end
    end
  end

  describe "#prepare_results" do
    context "given a possibilities and all results is processed" do
      it "prepares and report results" do
        possibilities.first[:possId] = 0
        Matrix.new.prepare_results(possibilities, matrix_db)

        expect(matrix_db).to have_received(:find).with({possId:0})
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

    before do
      allow(DataLoader).to receive(:new).and_return(data_loader)
      allow(DataLoader).to receive(:fetch_trading_days).and_return([file_name])
      allow(Strategy).to receive(:new).and_return(strategy)
      allow(strategy).to receive(:run_strategy).and_return(10)
      allow(strategy).to receive(:visual=)
      allow(data_loader).to receive(:load).and_return({tt:[tt]})
      allow(data_loader).to receive(:close)
      allow(matrix_db).to receive(:insert_one)
      allow(matrix_db).to receive(:delete)
    end

    context "given default parameters for possibilities" do
      it "runs the default strategy by day and print a report" do
        allow(matrix_db).to receive(:find).with({date:"31/01/2017"}).and_return([])

        Matrix.new.start

        expect(Reporter).to have_received(:by_possibility)
        expect(DataLoader).to have_received(:fetch_trading_days).with("WDO")
        expect(data_loader).to have_received(:load).with(file_name)
        expect(data_loader).to have_received(:close)

        expect(matrix_poss_db).to have_received(:insert_many).with(possibilities)
        expect(matrix_poss_db).to have_received(:find).with({})
        expect(matrix_db).to have_received(:find).with({possId:0})
        expect(matrix_db).to have_received(:insert_one)
        expect(matrix_db).to have_received(:close).twice
        expect(matrix_db).to have_received(:find).with({date:"31/01/2017"})
      end
    end

    context "given default parameters for possibilities" do
      it "runs the default strategy, but do nothing because strategy was already ran for the given day. Will just print a report" do
        allow(matrix_db).to receive(:find).with({date:"31/01/2017"}).and_return([{possId:0, net:10}])

        Matrix.new.start

        expect(Reporter).to have_received(:by_possibility)
        expect(DataLoader).to have_received(:fetch_trading_days).with("WDO")
        expect(data_loader).to have_received(:close)

        expect(matrix_poss_db).to have_received(:insert_many).with(possibilities)
        expect(matrix_poss_db).to have_received(:find).with({})
        expect(matrix_db).to have_received(:find).with({possId:0})
        expect(Strategy).not_to receive(:new)
        expect(matrix_db).not_to receive(:insert_one)
        expect(matrix_db).to have_received(:close).twice
        expect(matrix_db).to have_received(:find).with({date:"31/01/2017"})
      end
    end
  end

end
