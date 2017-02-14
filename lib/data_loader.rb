require 'parallel'
require_relative 'tt'

class DataLoader

  def self.load_data(hour, minute, file_pattern, workers)
    files = Dir.entries("./csv").select {|f| f =~ /#{file_pattern}/}.sort {|a,b| a <=> b}

    full_historic = {}
    Parallel.each(files, in_threads: workers) do |file|
      puts "Loading data for file #{file}"
      historic = []
      openning = nil
      File.open("./csv/#{file}", "r").each_with_index do |l, i|
        line = l.unpack("C*").pack("U*")
        info = line.split("\;")

        date = DateTime.strptime("#{info[1]} #{info[2]}", "%d/%m/%Y %H:%M:%S")
        limit = DateTime.strptime("#{info[1]} #{hour}:#{minute}:59", "%d/%m/%Y %H:%M:%S")
        if(date <= limit)
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
      end
      full_historic[file] = {tt:historic.reverse, openning:openning}
    end
    return full_historic
  end

end
