require 'indicators/basics'

describe Basics do
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
  let(:subject) { Basics.new }

  describe "#add_data" do
    context "given a nil historic data" do
      it "does nothing" do
        expect(subject.close).to eq(0.0)
        expect(subject.max).to eq(0.0)
        expect(subject.min).to eq(0.0)
        expect(subject.var).to eq(0.0)
        expect(subject.adjustment).to eq(nil)
        expect(subject.vwap).to eq(0.0)
        expect(subject.vwap_dist).to eq(0.0)
        expect(subject.adjustment_dist).to eq(0.0)
      end
    end
    context "given two historic data" do
      it "should add any kind of data given on a trade period" do
        subject.add_data(historic.first)
        subject.add_data(historic[1])

        expect(subject.close).to eq(3051.0)
        expect(subject.max).to eq(3051.0)
        expect(subject.min).to eq(3050.0)
        expect(subject.var).to eq(1.0)
        expect(subject.adjustment).to eq(nil)
        expect(subject.vwap).to eq(3050.50)
        expect(subject.vwap_dist).to eq(0.50)
        expect(subject.adjustment_dist).to eq(0.0)
      end
    end
    context "given two historic data" do
      it "should add any kind of data given on a trade period" do
        historic.each { |data| subject.add_data(data) }

        expect(subject.close).to eq(3049.0)
        expect(subject.max).to eq(3051.0)
        expect(subject.min).to eq(3045.0)
        expect(subject.var).to eq(6.0)
        expect(subject.adjustment).to eq(3048.22)
        expect(subject.vwap).to eq(3048.48)
        expect(subject.vwap_dist).to eq(0.52)
        expect(subject.adjustment_dist).to eq(0.78)
      end
    end
  end
end
