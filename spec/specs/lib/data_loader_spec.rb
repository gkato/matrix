require 'data_loader'
require 'indicators/basics'

describe DataLoader do
  let(:file_name) { "WDOH17_Trade_31-01-2017.csv" }
  let(:file_pattern) { "WDOH" }
  let(:matrix_db) { double("matrix_db") }
  let(:basics) { double("basics") }
  let(:close) { double("close") }

  before do
    allow(Dir).to receive(:entries).with("./csv").and_return([".teste", file_name])
    allow(MatrixDB).to receive(:new).and_return(matrix_db)
    allow(Basics).to receive(:new).and_return(basics)
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
    let(:matrix_tt_db) { double("matrix_tt") }
    let(:foo_historic) { {} }
    let(:foo_tt) { double("foo_tt") }

    before do
      allow(matrix_db).to receive(:on).with(:trading_days) { matrix_db }
      allow(matrix_db).to receive(:on).with(:times_trades) { matrix_tt_db }
      allow(matrix_db).to receive(:insert_one)
      allow(basics).to receive(:add_data)
      allow(basics).to receive(:vwap)
      allow(basics).to receive(:adjustment)
      allow(basics).to receive(:var)
      allow(basics).to receive(:close=)
      allow(basics).to receive(:close)
      allow(basics).to receive(:vwap_dist)
      allow(basics).to receive(:adjustment_dist)
      allow(matrix_tt_db).to receive(:insert_many)
      allow(File).to receive(:open).with("./csv/#{file_name}", "r").and_return(File.open("./spec/fixturies/#{file_name}", "r"))
    end

    context "given data is not stored in database" do
      it "returns a historical data from file, sliced by time and the openning price, and saves into database" do
        allow(matrix_db).to receive(:find).with(dayId:"WDOH17_Trade_31-01-2017").and_return([])

        result = DataLoader.new.load(file_name)
        expect(result[:openning]).to eq(3152)

        expect(result[:tt].first[:value]).to eq(3151.5)
        expect(result[:tt].first[:agressor]).to eq(:bid)

        expect(result[:tt].last[:value]).to eq(3151.0)
        expect(result[:tt].last[:agressor]).to eq(:ask)

        expect(basics).to have_received(:add_data).exactly(99).times
        expect(matrix_db).to have_received(:on).twice.with(:trading_days)
        expect(matrix_db).to have_received(:insert_one).with(result)
        expect(matrix_tt_db).to have_received(:insert_many).with(result[:tt])
        expect(basics).to have_received(:vwap)
        expect(basics).to have_received(:adjustment)
        expect(basics).to have_received(:var)
        expect(basics).to have_received(:vwap_dist)
        expect(basics).to have_received(:adjustment_dist)
      end
    end

    context "given data is stored in database" do
      it "returns a historical data from datbase" do
        allow(matrix_db).to receive(:find).with(dayId:"WDOH17_Trade_31-01-2017").and_return([foo_historic])
        allow(matrix_tt_db).to receive(:find).with(dayId:"WDOH17_Trade_31-01-2017").and_return([foo_tt])

        result = DataLoader.new.load(file_name)
        expect(matrix_db).to have_received(:on).with(:trading_days)
        expect(matrix_db).to have_received(:find).with(dayId:"WDOH17_Trade_31-01-2017")
        expect(result).to eq(foo_historic)
      end
    end

    context "given data is stored in database and its just to check if exists" do
      it "returns nil if exists" do
        allow(matrix_db).to receive(:find).with(dayId:"WDOH17_Trade_31-01-2017").and_return([foo_historic])
        allow(matrix_tt_db).to receive(:find).with(dayId:"WDOH17_Trade_31-01-2017").and_return([foo_tt])

        result = DataLoader.new.load(file_name,just_check:true)
        expect(matrix_db).to have_received(:on).with(:trading_days)
        expect(matrix_db).to have_received(:find).with(dayId:"WDOH17_Trade_31-01-2017")
        expect(matrix_tt_db).not_to have_received(:find).with(dayId:"WDOH17_Trade_31-01-2017")

        expect(result).to eq(nil)
      end
    end
  end

  describe "#close" do

    before do
      allow(matrix_db).to receive(:close)
    end

    context "Given an instance of DataLoader with a matrix DB connection" do
      it "closes DB connection" do
        DataLoader.new.close
        expect(matrix_db).to have_received(:close)
      end
    end
  end
end
