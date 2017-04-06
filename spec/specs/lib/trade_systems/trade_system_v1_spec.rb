require 'trade_systems/trade_system_v1'

describe TradeSystemV1 do
  let(:matrix_db) { double }
  let(:strat_equity) { "opening_pullback_v1_WDO" }
  let(:trade_system_params) { { index:2, n_days:3} }
  let(:trade_system) { TradeSystemV1.new(strat_equity, trade_system_params) }

  before do
    allow(MatrixDB).to receive(:new).and_return(matrix_db)
    allow(matrix_db).to receive(:on).with(:results) { matrix_db }
  end

  describe "#get_possibility_by_rule" do
    context "given the rule pick INDEX best possibility from N days" do
      it "returns the best result/possibility for index 2 and 3 days range, starting from 31/01/2017" do
        start_date = DateTime.strptime("31/01/2017","%d/%m/%Y")
        end_date = start_date + trade_system_params[:n_days]
        poss_expected = [{strategy_name:"opening_pullback_v1_WDO", possId:1, net:10, date:DateTime.strptime("2017-01-31","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-10, date:DateTime.strptime("2017-01-31","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:3, net:30, date:DateTime.strptime("2017-01-31","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:4, net:20, date:DateTime.strptime("2017-01-31","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:1, net:-10, date:DateTime.strptime("2017-02-01","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:2, net:50, date:DateTime.strptime("2017-02-01","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:3, net:10, date:DateTime.strptime("2017-02-01","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:4, net:10, date:DateTime.strptime("2017-02-01","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:1, net:-30, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:2, net:30, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:3, net:10, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:4, net:0, date:DateTime.strptime("2017-02-02","%Y-%m-%d")}]

        query = {strategy_name:strat_equity, date: {"$gte":start_date, "$lte":end_date}}
        allow(matrix_db).to receive(:find).with(query).and_return(poss_expected)

        result = trade_system.get_possibility_by_rule(start_date:start_date)

        expect(matrix_db).to have_received(:find).with(query)
        expect(result).to eq({possId:4, net:30})
      end
    end
  end
end
