require 'parallel'
require 'models/matrix_db'
require_relative 'tt'

class DataLoader

  attr_accessor :matrix_db

  def initialize(confs)
    #self.matrix_db = MatrixDB.new(confs[:hosts], database:confs[:database])
  end

  def get_stored(file, hour, minute)
  end

  def from_database(file, hour, minute)
  end

  def from_file(file)
    historic = []
    openning = nil
    File.open("./csv/#{file}", "r").each_with_index do |l, i|
      line = l.unpack("C*").pack("U*")
      info = line.split("\;")

      date = DateTime.strptime("#{info[1]} #{info[2]}", "%d/%m/%Y %H:%M:%S")
      agressor = info[7].gsub(/\n/, '').strip
      price  = info[4].gsub(",",".").to_f
      qty = info[5]
      ask = info[3]
      bid = info[6]
      if ["Comprador", "Vendedor"].include?(agressor)
        historic << TT.new(date, price, qty, ask, bid, agressor.nil? ? nil : agressor)
      end
      if agressor[0..-3] == "Leil"
        openning = price if openning.nil?
        break
      end
    end
    trading_day = {tt:historic.reverse, openning:openning}
    collection = file.gsub("-", "_").gsub(".csv", "")

    #matrix_db.on(collection).insert_many(historic)
    trading_day
  end

  def self.load_data(file_pattern, workers)
    files = Dir.entries("./csv").select {|f| f =~ /#{file_pattern}/}.sort {|a,b| a <=> b}#.first(1)

    full_historic = {}
    Parallel.each(files, in_threads: workers) do |file|
      puts "Loading data for file #{file}"

      full_historic[file] = DataLoader.new({}).from_file(file)
    end
    full_historic
  end

end
