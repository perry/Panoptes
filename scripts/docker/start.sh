#!/bin/bash -ex

cd /rails_app

if [ -d "/rails_conf/" ]
then
    ln -sf /rails_conf/* ./config/
fi

if [ "$RAILS_ENV" == "development" ]; then
  exec foreman start
else
  USER_DATA=$(curl --fail http://169.254.169.254/latest/user-data || echo "")

  if [ "$USER_DATA" == "EMERGENCY_MODE" ]
  then
    git pull
  fi

  TERM=xterm git log --format="%H" -n 1 > public/commit_id.txt
  mkdir -p tmp/pids/
  rm -f tmp/pids/*.pid
  bundle exec sidekiq &
  exec bundle exec rails s puma -p 80 $*
fi
