require 'date'
require 'indicators/vwap'

describe VWAP do
  let(:historic) do
    [
      { date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"A", bid:"B", :agressor=>"Comprador"},
      { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"C", bid:"D", :agressor=>"Vendedor"},
      { date:DateTime.strptime("31/01/2017 15:50:00", "%d/%m/%Y %H:%M:%S"), value:3049, qty:5, ask:"E", bid:"F", :agressor=>"Vendedor"},
      { date:DateTime.strptime("31/01/2017 15:50:01", "%d/%m/%Y %H:%M:%S"), value:3050, qty:7, ask:"A", bid:"B", :agressor=>"Comprador"},
      { date:DateTime.strptime("31/01/2017 15:54:02", "%d/%m/%Y %H:%M:%S"), value:3045, qty:8, ask:"C", bid:"D", :agressor=>"Vendedor"},
      { date:DateTime.strptime("31/01/2017 15:58:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:3, ask:"E", bid:"F", :agressor=>"Vendedor"},
      { date:DateTime.strptime("31/01/2017 16:00:00", "%d/%m/%Y %H:%M:%S"), value:3050, qty:4, ask:"A", bid:"B", :agressor=>"Comprador"},
      { date:DateTime.strptime("31/01/2017 16:00:01", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"C", bid:"D", :agressor=>"Vendedor"},
      { date:DateTime.strptime("31/01/2017 16:01:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>"Vendedor"}
    ]
  end
  let(:subject) { VWAP.new }

  describe "#add_data" do
    context "given a nil historic data" do
      it "does nothing" do
        expect(subject.total_contracts).to eq(0.0)
      end
    end
    context "given a historic data" do
      it "should add any kind of data given on a trade period" do
        subject.add_data(historic.first)
        expect(subject.total_contracts).to eq(1.0)

        subject.add_data(historic[1])
        expect(subject.total_contracts).to eq(2.0)
      end
    end
  end

  describe "#current_value" do
    context "given no historic data" do
      it "returns 0 for wvaps current value" do
        expect(subject.current_value).to eq(0.0)
      end
    end
    context "given a set of historic data" do
      it "returns the wvaps current value" do
        historic.each { |data| subject.add_data(data) }
        expect(subject.current_value).to eq(3048.48)
      end
    end
  end
end
