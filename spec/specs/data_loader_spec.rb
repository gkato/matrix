require 'data_loader'

describe DataLoader do

  describe ".load_data" do
    let(:file_pattern) { "WDOH" }
    let(:file_name) { "WDOH17_Trade_31-01-2017.csv" }
    let(:hour) { 9 }
    let(:minute) { 00 }
    let(:workers) { 1 }

    context "given an hour and minute to set time limit and having ./csv as the times and trades csv directory" do
      it "returns a historical data, sliced by time and the openning price" do
        allow(Dir).to receive(:entries).with("./csv").and_return([".teste", file_name])
        allow(File).to receive(:open).with("./csv/#{file_name}", "r").and_return(File.open("./spec/fixturies/#{file_name}", "r"))

        result = DataLoader.load_data(hour, minute, file_pattern, workers)
        expect(result[file_name][:openning]).to eq(3152)

        expect(result[file_name][:tt].first.value).to eq(3151.5)
        expect(result[file_name][:tt].first.agressor).to eq(:bid)

        expect(result[file_name][:tt].last.value).to eq(3150.0)
        expect(result[file_name][:tt].last.agressor).to eq(:bid)

        limit = DateTime.strptime("31/01/2017 #{hour}:#{minute}:59", "%d/%m/%Y %H:%M:%S")
        expect(result[file_name][:tt].last.date).to be <= limit
      end
    end
  end

end
