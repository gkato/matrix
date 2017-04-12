require 'trade_systems/trade_system_v1'

describe TradeSystemV1 do
  let(:matrix_db) { double }
  let(:matrix_result) { double }
  let(:matrix_result_other) { double }
  let(:strat_equity) { "opening_pullback_v1_WDO" }
  let(:ts_name) { "ts_opening_pullback_v1_WDO" }
  let(:trade_system_params) { { index:2, n_days:3, tsId:1, name:ts_name} }
  let(:trade_system) { TradeSystemV1.new(strat_equity, trade_system_params) }

  before do
    allow(MatrixDB).to receive(:new).and_return(matrix_db)
    allow(matrix_db).to receive(:on).with(:ts_results).and_return(matrix_db)
    allow(matrix_db).to receive(:on).with(:results) { matrix_db }
  end

  describe "#get_possibility_by_rule" do
    context "given the rule pick INDEX best possibility from N days" do
      it "returns the best result/possibility for index 3 and 3 days range, starting from 31/01/2017" do
        start_date = DateTime.strptime("02/02/2017","%d/%m/%Y")
        previous_date = start_date - trade_system_params[:n_days]
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

        query = {strategy_name:strat_equity, date: {"$gte":previous_date, "$lte":start_date}}
        allow(matrix_db).to receive(:find).with(query).and_return(poss_expected)

        result = trade_system.get_possibility_by_rule(start_date:start_date)

        expect(matrix_db).to have_received(:find).with(query)
        expect(result).to eq({possId:3, net:50, win_days:3, loss_days:0, total_win:50, total_loss:0, even_days:0})
      end
    end
    context "given the rule pick INDEX best possibility from N days" do
      it "returns the best result/possibility for index 2 and 4 days range, starting from 31/01/2017, having a tie rule when a tie exists" do
        trade_system_params = { index:2, n_days:4, tsId:1}
        trade_system = TradeSystemV1.new(strat_equity, trade_system_params)

        start_date = DateTime.strptime("02/02/2017","%d/%m/%Y")
        previous_date = start_date - trade_system_params[:n_days]
        poss_expected = [{strategy_name:"opening_pullback_v1_WDO", possId:1, net:10, date:DateTime.strptime("2017-01-31","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-10, date:DateTime.strptime("2017-01-31","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:3, net:60, date:DateTime.strptime("2017-01-31","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:4, net:20, date:DateTime.strptime("2017-01-31","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:1, net:-10, date:DateTime.strptime("2017-02-01","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:2, net:50, date:DateTime.strptime("2017-02-01","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:3, net:-10, date:DateTime.strptime("2017-02-01","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:4, net:20, date:DateTime.strptime("2017-02-01","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:1, net:-30, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:2, net:30, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:3, net:10, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:4, net:-20, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:1, net:20, date:DateTime.strptime("2017-02-03","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:2, net:10, date:DateTime.strptime("2017-02-03","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:3, net:-20, date:DateTime.strptime("2017-02-03","%Y-%m-%d")},
                         {strategy_name:"opening_pullback_v1_WDO", possId:4, net:20, date:DateTime.strptime("2017-02-03","%Y-%m-%d")}]

        query = {strategy_name:strat_equity, date: {"$gte":previous_date, "$lte":start_date}}
        allow(matrix_db).to receive(:find).with(query).and_return(poss_expected)

        result = trade_system.get_possibility_by_rule(start_date:start_date)

        expect(matrix_db).to have_received(:find).with(query)
        expect(result).to eq({possId:3, net:40, win_days:2, loss_days:2, total_win:70, total_loss:-30, even_days:0})
      end
    end
  end

  describe "#next_result_for" do
    context "given a possId for a strat_equity" do
      it "return the result for next trading day" do
        possId = 1
        date = DateTime.strptime("02/02/2017","%d/%m/%Y")
        query = {strategy_name:strat_equity, date:date, possId:possId}
        expected = {possId:possId, date:date, net:40, strategy_name:strat_equity}

        allow(matrix_db).to receive(:find).with(query).and_return([expected])

        result = trade_system.next_result_for(possId, date)

        expect(matrix_db).to have_received(:find).with(query)
        expect(result).to eq(expected)
      end
    end

    describe "#get_last_date" do
      context "given a strat_equity" do
        it "return last date if exists" do
          possId = 1
          date = DateTime.strptime("02/02/2018","%d/%m/%Y")
          query = {strat_equity:strat_equity}
          expected = {possId:possId, date:date, net:40, strategy_name:strat_equity}
          matrix_result = double

          allow(matrix_db).to receive(:find).with(query).and_return(matrix_result)
          allow(matrix_result).to receive(:sort).with({date:-1}).and_return(matrix_result)
          allow(matrix_result).to receive(:limit).with(1).and_return(matrix_result)
          allow(matrix_result).to receive(:first).and_return(expected)

          result = trade_system.get_last_date
          expect(matrix_db).to have_received(:find).with(query)
          expect(result).to eq(expected[:date])
        end
      end
      context "given a strat_equity but no results on db" do
        it "return last date if exists" do
          possId = 1
          date = DateTime.strptime("02/02/2018","%d/%m/%Y")
          query = {strat_equity:strat_equity}

          allow(matrix_db).to receive(:find).with(query).and_return(matrix_result)
          allow(matrix_result).to receive(:sort).with({date:-1}).and_return(matrix_result)
          allow(matrix_result).to receive(:limit).with(1).and_return(matrix_result)
          allow(matrix_result).to receive(:first).and_return(nil)

          result = trade_system.get_last_date
          expect(matrix_db).to have_received(:find).with(query)
          expect(result).to eq(nil)
        end
      end
    end

    describe "#fetch_all_simulations" do
      context "given a set o simulation data" do
        it "returns all data" do
          expected = [{tsId:1, net:-10, possId:2, date:DateTime.new}]
          allow(matrix_db).to receive(:find).with({tsId:1}).and_return(expected)

          result = trade_system.fetch_all_simulations
          expect(result).to eq(expected)
        end
      end
      context "given a set o simulation data" do
        it "returns nil when no simultion exists" do
          allow(matrix_db).to receive(:find).with({tsId:1}).and_return(nil)

          result = trade_system.fetch_all_simulations
          expect(result).to eq([])
        end
      end
    end

    describe "#simulate" do
      context "given a strat_equity, start date, index best and n_days" do
        it "returns a trade system simulation for a given strategy on an equity" do
          allow(matrix_db).to receive(:close)
          start_date = DateTime.strptime("02/02/2018","%d/%m/%Y")
          current_date = start_date
          last_date = DateTime.strptime("05/02/2018","%d/%m/%Y")

          params = {index:1, n_days:1, start_date:start_date, tsId:1, name:ts_name}
          ts = TradeSystemV1.new(strat_equity, params)

          last_result = {possId:100, date:last_date, net:40, strategy_name:strat_equity}

          #last day allows
          allow(matrix_db).to receive(:find).with({strat_equity:strat_equity}).and_return(matrix_result)
          allow(matrix_result).to receive(:sort).with({date:-1}).and_return(matrix_result)
          allow(matrix_result).to receive(:limit).with(1).and_return(matrix_result)
          allow(matrix_result).to receive(:first).and_return(last_result)

          #last simulation allows
          allow(matrix_db).to receive(:find).with({tsId:params[:tsId]}).and_return([])

          # starting results mocks and allows - day 02/02
          previous_date = start_date - params[:n_days]
          poss_start = [{strategy_name:"opening_pullback_v1_WDO", possId:1, net:10, date:DateTime.strptime("2017-02-01","%Y-%m-%d")},
                        {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-10, date:DateTime.strptime("2017-02-01","%Y-%m-%d")},
                        {strategy_name:"opening_pullback_v1_WDO", possId:3, net:30, date:DateTime.strptime("2017-02-01","%Y-%m-%d")},
                        {strategy_name:"opening_pullback_v1_WDO", possId:1, net:-10, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                        {strategy_name:"opening_pullback_v1_WDO", possId:2, net:60, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                        {strategy_name:"opening_pullback_v1_WDO", possId:3, net:10, date:DateTime.strptime("2017-02-02","%Y-%m-%d")}]

          query = {strategy_name:strat_equity, date: {"$gte":previous_date, "$lte":start_date}}
          allow(matrix_db).to receive(:find).with(query).and_return(poss_start)
          allow(matrix_db).to receive(:find).with({strategy_name:strat_equity, date: start_date+1, possId:2})
                                            .and_return([{possId:2, net:-10, strategy_name:strat_equity, date:start_date+1}])
          allow(matrix_db).to receive(:insert_one).with({tsId:params[:tsId], net:-10, possId:2, date:start_date+1, name:params[:name]})

          # results mocks and allows for day 03/02
          current_date = current_date + 1
          previous_date = current_date - params[:n_days]
          poss_03 = [{strategy_name:"opening_pullback_v1_WDO", possId:1, net:-10, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:2, net:50, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:3, net:10, date:DateTime.strptime("2017-02-02","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:1, net:-20, date:DateTime.strptime("2017-02-03","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-10, date:DateTime.strptime("2017-02-03","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:3, net:10, date:DateTime.strptime("2017-02-03","%Y-%m-%d")}]

          query = {strategy_name:strat_equity, date: {"$gte":previous_date, "$lte":current_date}}
          allow(matrix_db).to receive(:find).with(query).and_return(poss_03)
          allow(matrix_db).to receive(:find).with({strategy_name:strat_equity, date: current_date+1, possId:2})
                                            .and_return([{possId:2, net:-30, strategy_name:strat_equity, date:current_date+1}])
          allow(matrix_db).to receive(:insert_one).with({tsId:params[:tsId], net:-30, possId:2, date:current_date+1, name:params[:name]})

          # results mocks and allows for day 04/02
          current_date = current_date + 1
          previous_date = current_date - params[:n_days]
          poss_04 = [{strategy_name:"opening_pullback_v1_WDO", possId:1, net:-20, date:DateTime.strptime("2017-02-03","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-10, date:DateTime.strptime("2017-02-03","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:3, net:10, date:DateTime.strptime("2017-02-03","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:1, net:-10, date:DateTime.strptime("2017-02-04","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-40, date:DateTime.strptime("2017-02-04","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:3, net:-50, date:DateTime.strptime("2017-02-04","%Y-%m-%d")}]


          query = {strategy_name:strat_equity, date: {"$gte":previous_date, "$lte":current_date}}
          allow(matrix_db).to receive(:find).with(query).and_return(poss_04)
          allow(matrix_db).to receive(:find).with({strategy_name:strat_equity, date: current_date+1, possId:1})
                                            .and_return([{possId:1, net:10, strategy_name:strat_equity, date:current_date+1}])
          allow(matrix_db).to receive(:insert_one).with({tsId:params[:tsId], net:10, possId:1, date:current_date+1, name:params[:name]})

          # results mocks and allows for day 05/02
          current_date = current_date + 1
          previous_date = current_date - params[:n_days]
          poss_05 = [{strategy_name:"opening_pullback_v1_WDO", possId:1, net:10, date:DateTime.strptime("2017-02-04","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-30, date:DateTime.strptime("2017-02-04","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:3, net:-50, date:DateTime.strptime("2017-02-04","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:1, net:-20, date:DateTime.strptime("2017-02-05","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-100, date:DateTime.strptime("2017-02-05","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:3, net:-30, date:DateTime.strptime("2017-02-05","%Y-%m-%d")}]



          query = {strategy_name:strat_equity, date: {"$gte":previous_date, "$lte":current_date}}
          allow(matrix_db).to receive(:find).with(query).and_return(poss_05)

          result = ts.simulate
          expect(result).to eq({tsId:params[:tsId], net:-30, next_poss:1, name:ts_name})
          expect(matrix_db).to have_received(:close)
        end
      end

      context "given a strat_equity, start date, index best and n_days" do
        it "returns a trade system simulation for a given strategy on an equity, but only do the full job on the last day, others was already processed" do
          allow(matrix_db).to receive(:close)
          start_date = DateTime.strptime("02/02/2018","%d/%m/%Y")
          current_date = start_date + 2
          last_date = DateTime.strptime("05/02/2018","%d/%m/%Y")

          params = {index:1, n_days:1, start_date:start_date, tsId:1, name:ts_name}
          ts = TradeSystemV1.new(strat_equity, params)

          last_result = {possId:100, date:last_date, net:40, strategy_name:strat_equity}

          #last day allows
          allow(matrix_db).to receive(:find).with({strat_equity:strat_equity}).and_return(matrix_result)
          allow(matrix_result).to receive(:sort).with({date:-1}).and_return(matrix_result)
          allow(matrix_result).to receive(:limit).with(1).and_return(matrix_result)
          allow(matrix_result).to receive(:first).and_return(last_result)

          #last simulation allows
          allow(matrix_db).to receive(:find).with({tsId:params[:tsId]}).and_return([
            {tsId:params[:tsId], net:-10, possId:2, date:start_date+1},
            {tsId:params[:tsId], net:-30, possId:2, date:start_date+2}
          ])

          # results mocks and allows for day 04/02
          #current_date = current_date + 1
          previous_date = current_date - params[:n_days]
          poss_04 = [{strategy_name:"opening_pullback_v1_WDO", possId:1, net:-20, date:DateTime.strptime("2017-02-03","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-10, date:DateTime.strptime("2017-02-03","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:3, net:10, date:DateTime.strptime("2017-02-03","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:1, net:-10, date:DateTime.strptime("2017-02-04","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-40, date:DateTime.strptime("2017-02-04","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:3, net:-50, date:DateTime.strptime("2017-02-04","%Y-%m-%d")}]


          query = {strategy_name:strat_equity, date: {"$gte":previous_date, "$lte":current_date}}
          allow(matrix_db).to receive(:find).with(query).and_return(poss_04)
          allow(matrix_db).to receive(:find).with({strategy_name:strat_equity, date: current_date+1, possId:1})
                                            .and_return([{possId:1, net:10, strategy_name:strat_equity, date:current_date+1}])
          allow(matrix_db).to receive(:insert_one).with({tsId:params[:tsId], net:10, possId:1, date:current_date+1, name:params[:name]})

          # results mocks and allows for day 05/02
          current_date = current_date + 1
          previous_date = current_date - params[:n_days]
          poss_05 = [{strategy_name:"opening_pullback_v1_WDO", possId:1, net:10, date:DateTime.strptime("2017-02-04","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-30, date:DateTime.strptime("2017-02-04","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:3, net:-50, date:DateTime.strptime("2017-02-04","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:1, net:-20, date:DateTime.strptime("2017-02-05","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:2, net:-100, date:DateTime.strptime("2017-02-05","%Y-%m-%d")},
                     {strategy_name:"opening_pullback_v1_WDO", possId:3, net:-30, date:DateTime.strptime("2017-02-05","%Y-%m-%d")}]



          query = {strategy_name:strat_equity, date: {"$gte":previous_date, "$lte":current_date}}
          allow(matrix_db).to receive(:find).with(query).and_return(poss_05)

          result = ts.simulate
          expect(result).to eq({tsId:params[:tsId], net:-30, next_poss:1, name:ts_name})
          expect(matrix_db).to have_received(:close)
        end
      end
    end
  end
end
