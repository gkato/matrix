require 'date'
require 'matrix'
require 'inputs'
require 'data_loader'
require 'data_loader'
require 'strategy'
require 'Reporter'

describe Matrix do

  describe "#start" do
    let(:possibilities) {[{total_loss:-100, total_gain:200, stop:4, start:3, gain_1:4, gain_2:5, net:0, stops:0, gains:0}]}
    let(:strategy) {double}
    let(:tt) { { date:DateTime.new, value:1, qty:1, ask:"A", bid:"B", agressor:"Comprador" } }
    let(:data_loader) { double }
    let(:file_name) { "WDOH17_Trade_31-01-2017.csv" }
    let(:matrix_db) { double }
    let(:matrix_poss_db) { double }

    before do
      allow(Inputs).to receive(:combine_arrays).and_return(possibilities)
      allow(Inputs).to receive(:combine_array_map).and_return(possibilities)
      allow(DataLoader).to receive(:new).and_return(data_loader)
      allow(DataLoader).to receive(:fetch_trading_days).and_return([file_name])
      allow(Strategy).to receive(:new).and_return(strategy)
      allow(strategy).to receive(:run_strategy).and_return(10)
      allow(strategy).to receive(:visual=)
      allow(Reporter).to receive(:by_possibility)
      allow(data_loader).to receive(:load).and_return({tt:[tt]})
      allow(data_loader).to receive(:close)
      allow(MatrixDB).to receive(:new).and_return(matrix_db)
      allow(matrix_db).to receive(:on).with(:results) { matrix_db }
      allow(matrix_db).to receive(:on).with(:possibilities) { matrix_poss_db }
      allow(matrix_poss_db).to receive(:insert_many)
      allow(matrix_poss_db).to receive(:find).with({}).and_return([])
      allow(matrix_db).to receive(:find).with({possId:0}).and_return([{possId:0, net:10}])
      allow(matrix_db).to receive(:insert_one)
      allow(matrix_db).to receive(:close)
    end

    context "given default parameters for possibilities" do
      it "runs the default strategy and print a report" do
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
      end
    end
  end

end
