require './lib/strategies/opening_pullback_v2'
require './lib/inputs'

class OpeningPullbackV3 < OpeningPullbackV2

  def indicators_filter(await_pb)
    return true if (await_pb == :pb_long && @flow_balance.balance >= @flow)
    return true if (await_pb == :pb_short && @flow_balance.balance <= -(@flow))
    false
  end

  def self.create_inputs(equity="WDO")
    possibilities = []

    if equity == "WDO"
      start = (2..5).to_a
      pullback = (2..4).to_a
      stop = (1..5).to_a
      gain_1 = (2..6).to_a
      #gain_2 = (2..8).to_a
      #gain_3 = (4..12).to_a
      gain_2 = (2..10).to_a
      flow = [100,200,300,400,500,600,700,800.900,1000]
      total_loss = [-10000]
      total_gain = [10000]

      possibilities = Inputs.combine_arrays(gain_1, gain_2, :gain_1, :gain_2)
      #possibilities = Inputs.combine_array_map(gain_3,     possibilities, :gain_3)
      possibilities = Inputs.combine_array_map(start,      possibilities, :start)
      possibilities = Inputs.combine_array_map(stop,       possibilities, :stop)
      possibilities = Inputs.combine_array_map(pullback,   possibilities, :pullback)
      possibilities = Inputs.combine_array_map(total_gain, possibilities, :total_gain)
      possibilities = Inputs.combine_array_map(total_loss, possibilities, :total_loss)
      possibilities = Inputs.combine_array_map(flow, possibilities, :flow)

      possibilities.delete_if do |poss|
        #total_gain = (poss[:gain_1] + poss[:gain_2] + poss[:gain_3]) * 10
        #total_loss = ((poss[:start] - poss[:pullback] + poss[:stop])*3) * 10

        #(total_gain <  (2*total_loss)) || !((poss[:pullback] <= poss[:start]) && (poss[:gain_1] <= poss[:gain_2]) && (poss[:gain_2] <= poss[:gain_3]))
        total_gain = (poss[:gain_1] + poss[:gain_2]) * 10
        total_loss = ((poss[:start] - poss[:pullback] + poss[:stop])*2) * 10

        (total_gain <  (1.3*total_loss)) || !((poss[:pullback] <= poss[:start]) && (poss[:gain_1] <= poss[:gain_2]))
      end
    end
    if equity == "WIN"
      start = [150, 200, 250, 300]
      pullback = [150, 200, 250]
      stop = [100, 150, 200]
      gain_1 = [50, 75, 100]
      gain_2 = [75, 100, 125, 150]
      gain_3 = [100, 150, 200, 250]
      gain_4 = [200, 300, 400, 500, 600, 700, 800]
      total_loss = [-10000]
      total_gain = [10000]
      flow = [500,750,1000,1250,1500,1750]
      mult_1 = [6]
      mult_2 = [2]

      possibilities = Inputs.combine_arrays(gain_1, gain_2, :gain_1, :gain_2)
      possibilities = Inputs.combine_array_map(gain_3,     possibilities, :gain_3)
      possibilities = Inputs.combine_array_map(gain_4,     possibilities, :gain_4)
      possibilities = Inputs.combine_array_map(start,      possibilities, :start)
      possibilities = Inputs.combine_array_map(stop,       possibilities, :stop)
      possibilities = Inputs.combine_array_map(pullback,   possibilities, :pullback)
      possibilities = Inputs.combine_array_map(total_gain, possibilities, :total_gain)
      possibilities = Inputs.combine_array_map(total_loss, possibilities, :total_loss)
      possibilities = Inputs.combine_array_map(mult_1, possibilities, :mult_1)
      possibilities = Inputs.combine_array_map(mult_2, possibilities, :mult_2)
      possibilities = Inputs.combine_array_map(flow, possibilities, :flow)

      possibilities.delete_if do |poss|
        total_gain = (poss[:gain_1]*6 + poss[:gain_2]*2 + poss[:gain_3] + poss[:gain_4]) * 10
        total_loss = ((poss[:start] - poss[:pullback] + poss[:stop])*10) * 10
        (total_gain <  total_loss) || !((poss[:pullback] <= poss[:start]) && (poss[:gain_1] <= poss[:gain_2]) && (poss[:gain_2] <= poss[:gain_3]) && (poss[:gain_3] <= poss[:gain_4]))
      end
    end
    possibilities
  end
end
