#!/bin/sh

if [ -z "$1" ]
  then
    export PORT=3000
    echo Default port:3000
  else
    export PORT=$1
fi

export RAILS_ENV=development
export RACK_ENV=development
export SYSTEM_NODE=Common
bundle exec rails server mongrel -p $PORT

