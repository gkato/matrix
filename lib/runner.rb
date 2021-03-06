require 'yaml'
require_relative "./containers/container_v1"
require_relative "./containers/ts_container_v1"
require_relative "./data_loader"

$conf = YAML::load_file(File.join(__dir__, '../conf.yml'))
opts={}

if ARGV.first == "ts"
  if ARGV[1] && ARGV[2]
    tsId = ARGV[2].scan(/tsId:(\d+)/).flatten.first.to_i rescue nil if ARGV[2] =~ /tsId/
    ts_name = ARGV[2].scan(/ts_name:(ts_\S+WDO|WIN)/).flatten.first rescue nil if ARGV[2] =~ /ts_name/
    trade_systems = ["ts_opening_v1_WDO", "ts_opening_v1_WIN", "ts_opening_pullback_v1_WDO", "ts_opening_pullback_v1_WIN", "ts_opening_pullback_v2_WDO", "ts_opening_pullback_v2_WIN", "ts_opening_pullback_v3_WDO"]

    if ARGV[1].start_with?("run")
      opts[:tsId] = tsId if tsId
      if trade_systems.include?(ts_name)
        TSContainerV1.new.start(ts_name, opts)
      else
        puts "Container inválido"
      end
    elsif ARGV[1].start_with?("trace")
      TSContainerV1.new.show_ts_trace(tsId, ts_name)
    end
  end
elsif ARGV.first == "day"
  if ARGV[1]
    if ARGV[1] == "all"
      if ARGV[2]
        data_loader = DataLoader.new
        DataLoader.fetch_trading_days(ARGV[2]).each do |file|
          data_loader.load(file,just_check:true)
        end
        data_loader.close
      end
    elsif
      data_loader = DataLoader.new
      data_loader.load(ARGV[1])
      data_loader.close
    end
  end
elsif ARGV.first == "results"
  strat_equity = "opening_v1_WDO"
  if ARGV[1]
    opts[:possId] = (ARGV[1].scan(/possId:(\d+)/).flatten.first.to_i rescue nil) if ARGV[1] =~ /possId/
    opts[:index] = (ARGV[1].scan(/index:(\d+)/).flatten.first.to_i rescue nil) if ARGV[1] =~ /index/
    strat_equity = ((ARGV[1].scan(/strat_equity:(.*[A-Z]+)/).flatten.first rescue nil) || strat_equity)
    if ARGV[1] =~ /start_date/
      start_date = (ARGV[1].scan(/start_date:([0-9]{2}\/[0-9]{2}\/[0-9]{4})/).flatten.first rescue nil)
      opts[:start_date] = DateTime.strptime(start_date, "%d/%m/%Y") if start_date
    end
    if ARGV[1] =~ /end_date/
      end_date = (ARGV[1].scan(/end_date:([0-9]{2}\/[0-9]{2}\/[0-9]{4})/).flatten.first rescue nil)
      opts[:end_date] = DateTime.strptime(end_date, "%d/%m/%Y") if end_date
    end
  end
  puts "Running results for #{opts}"
  ContainerV1.new.run_results(strat_equity, opts)
else
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
