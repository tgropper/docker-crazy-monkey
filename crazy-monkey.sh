#!/bin/bash

USAGE='Usage: ./crazy-monkey.sh [OPTIONS]
\n\nOptions:
\n\t --dead-time \t Sets the time the dead container should remain stopped (default 1)
\n\t --sleep-time \t Sets the time between each kill (default 5)
\n\nRuns a crazy-monkey that randomly kills a running docker container.'

DEADTIME=1
SLEEPTIME=5

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
esac
done

echo "Running crazy-monkey with parameters: dead-time=$DEADTIME; sleep-time=$SLEEPTIME"

while true
do
  DEAD=$(docker ps -q | xargs shuf -n1 -e)
  echo "Killing container $DEAD for $DEADTIME seconds"
  docker stop $DEAD
  sleep $DEADTIME
  docker start $DEAD
  sleep $SLEEPTIME
done