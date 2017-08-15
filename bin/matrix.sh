if [ "$1" = "strat" ]; then
  if [ "$2" = "run" ]; then
    ruby ./lib/runner.rb $3
  fi
  if [ "$2" = "results" ]; then
    ruby ./lib/runner.rb $2 $3
  fi
fi
if [ "$1" = "ts" ]; then
  ruby ./lib/runner.rb $1 $2 $3
fi
if [ "$1" = "day" ]; then
  ruby ./lib/runner.rb $1 $2 $3
fi

