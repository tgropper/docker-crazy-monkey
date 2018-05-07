#!/bin/bash

USAGE='Usage: ./crazy-monkey.sh [OPTIONS]
\n\nOptions:
\n\t --dead-time \t Sets the time the dead container should remain stopped (default 1)
\n\t --sleep-time \t Sets the time between each kill (default 5)
\n\t --parallel \t Defines the number of parallel kill executions (default 3)
\n\nRuns a crazy-monkey that randomly kills running docker containers.'

DEADTIME=1
SLEEPTIME=5
PARALLEL=3

for i in "$@"
do
case $i in
-h|--help)
  echo -e $USAGE
  exit 1
  ;;
--dead-time=*)
  DEADTIME="${i#*=}"
  ;;
--sleep-time=*)
  SLEEPTIME="${i#*=}"
  ;;
--parallel=*)
  PARALLEL="${i#*=}"
  ;;
esac
done

echo "Running crazy-monkey with parameters: dead-time=$DEADTIME; sleep-time=$SLEEPTIME; parallel=$PARALLEL."

kill () {
  DEADID=$(docker ps -q | xargs shuf -n1 -e)
  DEADNAME=$(docker ps --format '{{.ID}} {{.Names}}' | grep $DEADID | awk '{print $2}')

  trap start $DEADID $DEADNAME SIGINT

  stop $DEADID $DEADNAME
  sleep $DEADTIME
  start $DEADID $DEADNAME
}

start () {
  docker start $1 > /dev/null
  echo "Container $2 is back alive."
}

stop () {
  echo "Killing container $2."
  docker stop $1 > /dev/null
}

while true
do
  for ((i=1; i<=$PARALLEL; i++))
  do 
    kill &
  done
  wait
  echo "Killed containers are back alive. Now it's safe to exit crazy-monkey."
  sleep $SLEEPTIME
done