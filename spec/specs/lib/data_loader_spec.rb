require 'data_loader'

describe DataLoader do
  let(:file_name) { "WDOH17_Trade_31-01-2017.csv" }
  let(:file_pattern) { "WDOH" }
  let(:matrix_db) { double }

  before do
    allow(Dir).to receive(:entries).with("./csv").and_return([".teste", file_name])
    allow(MatrixDB).to receive(:new).and_return(matrix_db)
  end

  describe ".fetch_trading_days" do
    context "given a directory and a file pattern" do
      it "get all csv files" do
        result = DataLoader.fetch_trading_days(file_pattern)

        expect(result.size).to eq(1)
        expect(result.include?(file_name)).to eq(true)
      end
    end
  end

  describe "#load" do
    let(:matrix_tt_db) { double }
    let(:foo_historic) { {} }
    let(:foo_tt) { double }

    before do
      allow(matrix_db).to receive(:on).with(:trading_days) { matrix_db }
      allow(matrix_db).to receive(:on).with(:times_trades) { matrix_tt_db }
      allow(matrix_db).to receive(:insert_one)
      allow(matrix_tt_db).to receive(:insert_many)
      allow(File).to receive(:open).with("./csv/#{file_name}", "r").and_return(File.open("./spec/fixturies/#{file_name}", "r"))
    end

    context "given data is not stored in database" do
      it "returns a historical data from file, sliced by time and the openning price, and saves into database" do
        allow(matrix_db).to receive(:find).with(dayId:"WDOH17_Trade_31-01-2017").and_return([])

        result = DataLoader.new({}).load(file_name)
        expect(result[:openning]).to eq(3152)

        expect(result[:tt].first[:value]).to eq(3151.5)
        expect(result[:tt].first[:agressor]).to eq(:bid)

        expect(result[:tt].last[:value]).to eq(3151.0)
        expect(result[:tt].last[:agressor]).to eq(:ask)

        expect(matrix_db).to have_received(:on).twice.with(:trading_days)
        expect(matrix_db).to have_received(:insert_one).with(result)
        expect(matrix_tt_db).to have_received(:insert_many).with(result[:tt])
      end
    end

    context "given data is stored in database" do
      it "returns a historical data from datbase" do
        allow(matrix_db).to receive(:find).with(dayId:"WDOH17_Trade_31-01-2017").and_return([foo_historic])
        allow(matrix_tt_db).to receive(:find).with(dayId:"WDOH17_Trade_31-01-2017").and_return([foo_tt])

        result = DataLoader.new({}).load(file_name)
        expect(matrix_db).to have_received(:on).with(:trading_days)
        expect(matrix_db).to have_received(:find).with(dayId:"WDOH17_Trade_31-01-2017")
        expect(result).to eq(foo_historic)
      end
    end
  end

  describe "#close" do

    before do
      allow(matrix_db).to receive(:close)
    end

    context "Given an instance of DataLoader with a matrix DB connection" do
      it "closes DB connection" do
        DataLoader.new({}).close
        expect(matrix_db).to have_received(:close)
      end
    end
  end
end
