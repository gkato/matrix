if [ "$1" = "strat" ]; then
  if [ "$2" = "op" ]; then
    if [ "$3" = "run" ]; then
      ruby ./lib/runner.rb $4
    fi
    if [ "$3" = "results" ]; then
      ruby ./lib/runner.rb
    fi
  fi
fi
