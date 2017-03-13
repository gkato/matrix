if [ "$1" = "strat" ]; then
  if [ "$2" = "op" ]; then
    if [ "$3" = "run" ]; then
      ruby ./lib/runner.rb
    fi
  fi
fi

