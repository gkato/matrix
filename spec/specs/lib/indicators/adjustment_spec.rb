require 'indicators/ajustment'

describe Ajustment do
 let(:historic) do
   [
     { date:DateTime.strptime("31/01/2017 09:00:01", "%d/%m/%Y %H:%M:%S"), value:3050, qty:1, ask:"A", bid:"B", :agressor=>"Comprador"},
     { date:DateTime.strptime("31/01/2017 09:00:02", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"C", bid:"D", :agressor=>"Vendedor"},
     { date:DateTime.strptime("31/01/2017 15:50:00", "%d/%m/%Y %H:%M:%S"), value:3049, qty:5, ask:"E", bid:"F", :agressor=>"Vendedor"},
     { date:DateTime.strptime("31/01/2017 15:50:01", "%d/%m/%Y %H:%M:%S"), value:3050, qty:7, ask:"A", bid:"B", :agressor=>"Comprador"},
     { date:DateTime.strptime("31/01/2017 15:54:02", "%d/%m/%Y %H:%M:%S"), value:3051, qty:8, ask:"C", bid:"D", :agressor=>"Vendedor"},
     { date:DateTime.strptime("31/01/2017 15:58:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:3, ask:"E", bid:"F", :agressor=>"Vendedor"},
     { date:DateTime.strptime("31/01/2017 16:00:00", "%d/%m/%Y %H:%M:%S"), value:3050, qty:4, ask:"A", bid:"B", :agressor=>"Comprador"},
     { date:DateTime.strptime("31/01/2017 16:00:01", "%d/%m/%Y %H:%M:%S"), value:3051, qty:1, ask:"C", bid:"D", :agressor=>"Vendedor"},
     { date:DateTime.strptime("31/01/2017 16:01:03", "%d/%m/%Y %H:%M:%S"), value:3049, qty:1, ask:"E", bid:"F", :agressor=>"Vendedor"}
   ]
 end
 let(:subject) { Ajustment.new }

 describe "#add_data" do
   context "given nil historic data" do
     it "ignores data" do
       subject.add_data(historic.first)
       expect(subject.data.size).to eq(0)
     end
   end
   context "given a historic data with data lower than 15:50:00" do
     it "ignores data" do
       subject.add_data(historic.first)
       expect(subject.data.size).to eq(0)
     end
   end
   context "given a historic data with data greather than 16:00:00" do
     it "ignores data" do
       subject.add_data(historic.last)
       expect(subject.data.size).to eq(0)
     end
   end
   context "given a historic data with data between 15:50:00 and 16:00:00" do
     it "adds data" do
       subject.add_data(historic[3])
       expect(subject.data.size).to eq(1)
     end
   end
 end

 describe "#current_value" do
   describe "given a set of histoirc data containing data between 15:50:00 and 16:00:00" do
     it "returns the current value" do
       historic.each do |data|
         subject.add_data(data)
       end
       expect(subject.current_value).to eq(3050)
     end
   end
 end
end
