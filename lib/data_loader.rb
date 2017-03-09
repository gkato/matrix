require 'parallel'
require './lib/models/matrix_db'
require './lib/tt'

class DataLoader

  attr_accessor :matrix_db, :files

  def initialize(confs)
    self.matrix_db = MatrixDB.new(confs[:hosts], database:confs[:database])
  end

  def load(file)
    puts "Loading data for file #{file}"
    dayId = file.gsub(".csv", "")
    historic = []

    trading_day = (matrix_db.on(:trading_days).find(dayId:dayId) || []).first
    if trading_day
      historic = matrix_db.on(:times_trades).find(dayId:dayId)
      trading_day[:tt] = historic.to_a.sort {|a,b| a[:date] <=> b[:date]}
      puts "Data loaded for file #{file}"
      return trading_day
    end

    openning = nil
    day = nil
    File.open("./csv/#{file}", "r").each_with_index do |l, i|
      line = l.unpack("C*").pack("U*")
      info = line.split("\;")

      day = info[1] if day.nil?
      date = DateTime.strptime("#{info[1]} #{info[2]}", "%d/%m/%Y %H:%M:%S")
      agressor = info[7].gsub(/\n/, '').strip
      price  = info[4].gsub(",",".").to_f
      qty = info[5]
      ask = info[3]
      bid = info[6]
      if ["Comprador", "Vendedor"].include?(agressor)
        if agressor == "Comprador"
          agressor = :ask
        elsif agressor == "Vendedor"
          agressor = :bid
        end
        historic << { dayId:dayId, date:date, value:price, qty:qty, ask:ask, bid:bid, agressor:agressor }
      end
      if agressor[0..-3] == "Leil"
        openning = price if openning.nil?
        break
      end
    end
    historic.reverse!

    trading_day = { dayId:dayId, date:day, openning:openning }

    matrix_db.on(:times_trades).insert_many(historic)
    matrix_db.on(:trading_days).insert_one(trading_day)

    trading_day[:tt] = historic

    puts "Data loaded for file #{file}"
    trading_day
  end

  def close
    matrix_db.close
  end

  def self.fetch_trading_days(file_pattern)
    Dir.entries("./csv").select {|f| f =~ /#{file_pattern}/}.sort {|a,b| a <=> b}
  end

end
