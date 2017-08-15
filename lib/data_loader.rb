require 'parallel'
require './lib/models/matrix_db'
require './lib/tt'
require './lib/indicators/basics'

class DataLoader

  attr_accessor :matrix_db, :files, :basics

  def initialize
    @matrix_db = MatrixDB.new
  end

  def load(file, opts={})
    @basics = Basics.new
    puts "Loading data for file #{file}"
    dayId = file.gsub(".csv", "")
    historic = []
    close = nil

    trading_day = (@matrix_db.on(:trading_days).find(dayId:dayId) || []).first
    if trading_day
      if opts[:just_check] == true
        puts "Just check - Data already loaded"
        return nil
      end

      historic = @matrix_db.on(:times_trades).find(dayId:dayId)
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
      if ["Comprador", "Vendedor", "Direto"].include?(agressor)
        if agressor == "Comprador"
          agressor = :ask
        elsif agressor == "Vendedor"
          agressor = :bid
        elsif agressor == "Direto"
          agressor = :direct
        end
        close = price if close.nil?
        data = { dayId:dayId, date:date, value:price, qty:qty, ask:ask, bid:bid, agressor:agressor }
        historic << data
        basics.add_data(data)
      end
      if agressor[0..-3] == "Leil"
        if(date.hour == 9 && date.minute < 5)
          openning = price if openning.nil?
          break
        end
      end
    end
    historic.reverse!

    basics.close = close
    trading_day = { dayId:dayId, date:day, openning:openning, vwap:basics.vwap, adjustment:basics.adjustment, var:basics.var, vwap_dist:basics.vwap_dist, adjustment_dist:basics.adjustment_dist, close:basics.close }

    @matrix_db.on(:times_trades).insert_many(historic)
    @matrix_db.on(:trading_days).insert_one(trading_day)

    trading_day[:tt] = historic

    puts "Data loaded for file #{file}"
    trading_day
  end

  def close
    @matrix_db.close
  end

  def self.fetch_trading_days(file_pattern)
    Dir.entries("./csv").select {|f| f =~ /#{file_pattern}/}.sort {|a,b| a <=> b}
  end

end
