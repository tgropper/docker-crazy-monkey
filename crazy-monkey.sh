#!/bin/bash

USAGE='Usage: ./crazy-monkey.sh [OPTIONS]
\n\nOptions:
\n\t --dead-time \t Sets the time the dead container should remain stopped (default 1)
\n\t --sleep-time \t Sets the time between each kill (default 5)
\n\t --parallel \t Defines the number of parallel kill executions (default 3)
\n\t --containers-regex \t Regex to define the list of containers to use (default all)
\n\nRuns a crazy-monkey that randomly kills running docker containers.'

DEADTIME=1
SLEEPTIME=5
PARALLEL=3
REGEX="."

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
--containers-regex=*)
  REGEX="${i#*=}"
  ;;
esac
done

echo "Running crazy-monkey with parameters: dead-time=$DEADTIME; sleep-time=$SLEEPTIME; parallel=$PARALLEL; regex=$REGEX."

CONTAINERS=docker ps -a --format '{{.Names}} {{.ID }}' | grep $REGEX

kill () {
  # DEADID=$(docker ps -q | xargs shuf -n1 -e)
  DEADID=$CONTAINERS | awk '{print $ 2}' | xargs shuf -n1 -e
  DEADNAME=$CONTAINERS | grep $DEADID | awk '{print $1}'

  trap 'start $DEADID $DEADNAME; exit 1' INT

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