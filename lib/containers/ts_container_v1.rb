class TSContainerV1

  def tradesystem_infos(ts_name)
    infos = ts_name.scan(/^ts_(.*_v\d)_([A-Z]+)$/).flatten
    {name:ts_name, strategy_name:infos[0], strat_equity:"#{infos[0]}_#{infos[1]}", equity:infos[1]}
  end
end
