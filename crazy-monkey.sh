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

echo "$(date -u +"%F %T") Running crazy-monkey with parameters: dead-time=$DEADTIME; sleep-time=$SLEEPTIME; parallel=$PARALLEL; regex=$REGEX."

kill () {
  DEADID=$(docker ps -a --format '{{.Names}} {{.ID }}' | grep -P $REGEX | awk '{print $2}' | xargs shuf -n1 -e)
  DEADNAME=$(docker ps -a --format '{{.Names}} {{.ID }}' | grep $DEADID | awk '{print $1}')

  trap 'start $DEADID $DEADNAME; exit 1' INT

  stop $DEADID $DEADNAME
  sleep $DEADTIME
  start $DEADID $DEADNAME
}

start () {
  docker start $1 > /dev/null
  echo "$(date -u +"%F %T") Container $2 is back alive."
}

stop () {
  echo "$(date -u +"%F %T") Killing container $2."
  docker stop $1 > /dev/null
}

while true
do
  for ((i=1; i<=$PARALLEL; i++))
  do 
    kill &
  done
  wait
  echo "$(date -u +"%F %T") Killed containers are back alive."
  sleep $SLEEPTIME
done