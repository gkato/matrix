require 'data_loader'

describe DataLoader do

  describe ".load_data" do
    let(:file_pattern) { "WDOH" }
    let(:file_name) { "WDOH17_Trade_31-01-2017.csv" }
    let(:hour) { 9 }
    let(:minute) { 00 }
    let(:workers) { 1 }
    let(:matrix_db) { double }
    let(:matrix_tt_db) { double }
    let(:foo_historic) { {} }
    let(:foo_tt) { double }

    before do
      allow(MatrixDB).to receive(:new).and_return(matrix_db)
      allow(matrix_db).to receive(:on).with(:trading_days) { matrix_db }
      allow(matrix_db).to receive(:on).with(:times_trades) { matrix_tt_db }
      allow(matrix_db).to receive(:insert_one)
      allow(matrix_tt_db).to receive(:insert_many)
      allow(Dir).to receive(:entries).with("./csv").and_return([".teste", file_name])
      allow(File).to receive(:open).with("./csv/#{file_name}", "r").and_return(File.open("./spec/fixturies/#{file_name}", "r"))
    end

    context "given data is not stored in database" do
      it "returns a historical data from file, sliced by time and the openning price, and saves into database" do
        allow(matrix_db).to receive(:find).with(dayId:"WDOH17_Trade_31-01-2017").and_return([])

        result = DataLoader.load_data(file_pattern, workers)
        expect(result[file_name][:openning]).to eq(3152)

        expect(result[file_name][:tt].first[:value]).to eq(3151.5)
        expect(result[file_name][:tt].first[:agressor]).to eq(:bid)

        expect(result[file_name][:tt].last[:value]).to eq(3151.0)
        expect(result[file_name][:tt].last[:agressor]).to eq(:ask)

        expect(matrix_db).to have_received(:on).twice.with(:trading_days)
        expect(matrix_db).to have_received(:insert_one).with(result.values.first)
        expect(matrix_tt_db).to have_received(:insert_many).with(result.values.first[:tt])
      end
    end

    context "given data is stored in database" do
      it "returns a historical data from datbase" do
        allow(matrix_db).to receive(:find).with(dayId:"WDOH17_Trade_31-01-2017").and_return([foo_historic])
        allow(matrix_tt_db).to receive(:find).with(dayId:"WDOH17_Trade_31-01-2017").and_return([foo_tt])

        result = DataLoader.load_data(file_pattern, workers)
        expect(matrix_db).to have_received(:on).with(:trading_days)
        expect(matrix_db).to have_received(:find).with(dayId:"WDOH17_Trade_31-01-2017")
        expect(result.values.first).to eq(foo_historic)
      end
    end
  end

end
