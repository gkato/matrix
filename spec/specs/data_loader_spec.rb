require 'data_loader'

describe DataLoader do

  describe ".load_data" do
    let(:file_pattern) { "WDOH" }
    let(:file_name) { "WDOH17_Trade_31-01-2017.csv" }
    let(:hour) { 9 }
    let(:minute) { 00 }
    let(:workers) { 1 }
    let(:mongo) { double }
    let(:collection_name) { file_name.gsub("-", "_").gsub(".csv", "") }
    let(:collection) { double(database:[collection_name]).as_null_object }

    before do
      allow(MatrixDB).to receive(:new).and_return(:mongo)
      allow(mongo).to receive(:on).with(collection_name).and_return(mongo)
      allow(mongo).to receive(:insert_many)
    end

    context "given data is not stored in database" do
      it "returns a historical data from file, sliced by time and the openning price" do
        allow(Dir).to receive(:entries).with("./csv").and_return([".teste", file_name])
        allow(File).to receive(:open).with("./csv/#{file_name}", "r").and_return(File.open("./spec/fixturies/#{file_name}", "r"))

        result = DataLoader.load_data(file_pattern, workers)
        expect(result[file_name][:openning]).to eq(3152)

        expect(result[file_name][:tt].first.value).to eq(3151.5)
        expect(result[file_name][:tt].first.agressor).to eq(:bid)

        expect(result[file_name][:tt].last.value).to eq(3151.0)
        expect(result[file_name][:tt].last.agressor).to eq(:ask)

        collection = file_name.gsub("-", "_").gsub(".csv", "")
        #expect(mongo).to receive(:on)
        #expect(mongo).to receive(:insert_many)
      end
    end

  end

end
