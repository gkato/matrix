require './lib/strategies/opening_pullback_v1'
require './lib/inputs'
require './lib/tt'

class InflectionV1 < OpeningPullbackV1
  attr_accessor :pullback_var, :flow_flip, :kick_off, :flow_edge

  def initialize(possibility, tic_value, time, hist, openning)
    super(possibility, tic_value, time, hist, openning)
    @pullback_var = possibility[:pullback_var]
    @kick_off = possibility[:kick_off]
    @flow_flip = possibility[:flow_flip]
    @flow_edge = 0
  end

  def create_tt_and_compute(tt_infos)
    tt = super(tt_infos)
    @flow_edge = @flow_balance if @flow_edge < @flow_balance.balance
    tt
  end

end
