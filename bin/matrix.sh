if [ "$1" = "strat" ]; then
  if [ "$2" = "run" ]; then
    ruby ./lib/runner.rb $3
  fi
  if [ "$2" = "results" ]; then
    ruby ./lib/runner.rb $2 $3
  fi
fi
