require 'yaml'
require_relative "./containers/container_v1"

$conf = YAML::load_file(File.join(__dir__, '../conf.yml'))
opts={}

require 'debug'
if ARGV.first == "results"
  strat_equity = "opening_v1_WDO"
  if ARGV[1]
    opts[:possId] = (ARGV[1].scan(/possId:(\d+)/).flatten.first.to_i rescue nil) if ARGV[1] =~ /possId/
    strat_equity = ((ARGV[1].scan(/strat_equity:(.*[A-Z]+)/).flatten.first rescue nil) || strat_equity)
  end
  ContainerV1.new.run_results(strat_equity, opts)
elsif
  trading_days = ARGV.first.scan(/trading_days:\[(.*?)\]/).flatten.first.split("\,") rescue []
  visual = ARGV.first.scan(/visual:(true|false)/).flatten.first rescue nil
  strategy_name = ARGV.first.scan(/strategy_name:(([a-z]+_)+v\d+)/).flatten.first rescue nil
  equity = ARGV.first.scan(/equity:([A-Z]+)/).flatten.first rescue nil

  opts[:trading_days] = trading_days if !trading_days.empty?
  opts[:visual] = visual if visual
  opts[:equity] = equity if equity
  opts[:strategy_name] = strategy_name if strategy_name

  ContainerV1.new.start(opts)
end
