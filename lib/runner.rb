require_relative "matrix"

opts={}

if ARGV.first == "results"
  opts[:possId] = ARGV[1].to_i if ARGV[1]
  Matrix.new.run_results("opening_v1_WDO", opts)
elsif
  trading_days = ARGV.first.scan(/trading_days:\[(.*?)\]/).flatten.first.split("\,") rescue []
  visual = ARGV.first.scan(/visual:(true|false)/).flatten.first rescue nil
  opts[:trading_days] = trading_days if !trading_days.empty?
  opts[:visual] = visual if visual
  Matrix.new.start(opts)
end
