require 'date'

class Adjustment

  attr_accessor :data

  def initialize
    @data = []
  end

  def add_data(historic_data)
    return if historic_data.nil?

    start_date = DateTime.strptime("15/10/2016 15:50:00", "%d/%m/%Y %H:%M:%S")
    end_date = DateTime.strptime("15/10/2016 16:00:00", "%d/%m/%Y %H:%M:%S")

    if historic_data[:date].strftime("%H:%M:%S") < start_date.strftime("%H:%M:%S")
      return
    end
    if historic_data[:date].strftime("%H:%M:%S") > end_date.strftime("%H:%M:%S")
      return
    end

    @data << historic_data
  end

  def current_value
    return if data.empty?

    total_contracts = 0.0
    total_value = 0.0
    data.each do |historic|
      total_contracts += historic[:qty].to_f
      total_value += historic[:value].to_f * historic[:qty].to_f
    end
    return (total_value / total_contracts).round(2)
  end
end
