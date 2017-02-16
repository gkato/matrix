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
    let(:tt) { TT.new(DateTime.new, 1, 1, "A", "B", "Comprador") }

    before do
      allow(Inputs).to receive(:combine_arrays).and_return(possibilities)
      allow(Inputs).to receive(:combine_array_map).and_return(possibilities)
      allow(DataLoader).to receive(:load_data).and_return({"1" => {tt:[tt]}})
      allow(Strategy).to receive(:new).and_return(strategy)
      allow(strategy).to receive(:run_strategy).and_return(10)
      allow(strategy).to receive(:visual=)
      allow(Reporter).to receive(:by_possibility)
    end

    context "given default parameters for possibilities" do
      it "runs the default strategy and print a report" do
        Matrix.new.start

        expect(Reporter).to have_received(:by_possibility)
      end
    end
  end

end
