class VWAP

  attr_accessor :data, :total_contracts, :total_value

  def initialize
    @total_contracts = 0.0
    @total_value = 0.0
  end

  def add_data(historic_data)
    return if historic_data.nil?

    @total_contracts += historic_data[:qty].to_f
    @total_value += historic_data[:value].to_f * historic_data[:qty].to_f
  end

  def current_value
    return 0.0 if @total_contracts == 0.0

    return (@total_value / @total_contracts).round(2)
  end
end

