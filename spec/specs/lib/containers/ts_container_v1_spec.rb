require 'containers/ts_container_v1'

describe TSContainerV1 do

  describe "#tradesystem_infos" do
    context "given a tradesystem ts_opening_v1_WDO" do
      it "returns tradesystem infos ina hash" do
        result = TSContainerV1.new.tradesystem_infos("ts_opening_v1_WDO")
        expect(result).to eq({name:"ts_opening_v1_WDO", strategy_name:"opening_v1", strat_equity:"opening_v1_WDO", equity:"WDO" })
      end
    end
    context "given a tradesystem ts_opening_pullback_v1_WIN" do
      it "returns tradesystem infos ina hash" do
        result = TSContainerV1.new.tradesystem_infos("ts_opening_pullback_v1_WIN")
        expect(result).to eq({name:"ts_opening_pullback_v1_WIN", strategy_name:"opening_pullback_v1", strat_equity:"opening_pullback_v1_WIN", equity:"WIN" })
      end
    end
  end

  describe "#start" do
  end
end
