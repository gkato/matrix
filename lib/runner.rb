require_relative "matrix"

opts={}
trading_days = ARGV.first.scan(/trading_days:\[(.*?)\]/).flatten.first.split("\,") rescue []
opts[:trading_days] = trading_days if !trading_days.empty?
Matrix.new.start(opts)
