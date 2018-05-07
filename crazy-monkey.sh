#!/bin/bash

USAGE='Usage: ./crazy-monkey.sh [OPTIONS]
\n\nOptions:
\n\t --dead-time \t Sets the time the dead container should remain stopped
\n\t --sleep-time \t Sets the time between each kill
\n\nRuns a crazy-monkey that randomly kills a running docker container.'

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

if [[ -z $DEADTIME ]];
then
  echo "crazy-monkey requires argument '--dead-time'."
  echo "See './crazy-monkey.sh --help'."
  echo -e $USAGE
  exit 1
fi

if [[ -z $SLEEPTIME ]];
then
  echo "crazy-monkey requires argument '--sleep-time'."
  echo "See './crazy-monkey.sh --help'."
  echo -e $USAGE
  exit 1
fi

while true
do
  DEAD=$(docker ps -q | xargs shuf -n1 -e)
  echo "Killing container $DEAD for $DEADTIME seconds"
  docker stop $DEAD
  sleep $DEADTIME
  docker start $DEAD
  sleep $SLEEPTIME
done