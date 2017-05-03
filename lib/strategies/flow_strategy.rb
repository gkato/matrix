require './lib/strategy'
require './lib/tt'
require './lib/indicators/flow_balance'

class FlowStrategy < Strategy
  attr_accessor :flow_balance, :flow

  def initialize(possibility, tic_value, time, hist, openning)
    super(possibility, tic_value, time, hist, openning)
    @flow = possibility[:flow]
    @flow_balance = FlowBalance.new
  end

  def create_tt_and_compute(tt_infos)
    tt = TT.new(tt_infos[:date].to_datetime, tt_infos[:value], tt_infos[:qty], tt_infos[:ask], tt_infos[:bid], tt_infos[:agressor])
    @flow_balance.compute(tt)
    tt
  end
end

