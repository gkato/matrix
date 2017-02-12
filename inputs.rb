class Inputs

  def self.generate_inputs

    ### Possibilities
    stops = (1..5).to_a
    start = (1..5).to_a
    gain_1 = (1..5).to_a
    gain_2 = (5..8).to_a
    total_loss = [-100, -150, -200, -250]
    total_gain = [100, 150, 200, 250]

    gain = gain_1.product(gain_2)
    gain = gain.map {|pair| {gain_1:pair[0], gain_2:pair[1]}}

    stops_gain = stops.product(gain)
    stops_gain = stops_gain.map {|x| {stop:x[0]}.merge(x[1]) }

    stops_start = start.product(stops_gain)
    stops_start = stops_start.map {|x| {start:x[0]}.merge(x[1]) }

    with_loss = total_loss.product(stops_start)
    with_loss = with_loss.map {|x| {total_loss:x[0]}.merge(x[1]) }

    with_gain = total_gain.product(with_loss)
    with_gain = with_gain.map {|x| {total_gain:x[0], net:0, stops:0, gains:0, per_day:[]}.merge(x[1]) }
    ### Possibilities

    with_gain

  end

end
