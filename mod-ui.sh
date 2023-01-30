#!/bin/bash

# Copy this to your .bash_profile and amend JACKD_ARGS for your setup
# /bin/uname -r | grep -q rt
# if [ $? -eq 0 ]
# then
#   # Start jackd under RT kernel
#   export JACKD_ARGS="-R -d alsa -p 128 -n 1 -r 48000 -d hw:0"
# else
#   # Start jackd under non-RT kernel
#   export JACKD_ARGS="-r -d alsa -p 128 -n 2 -r 48000 -d hw:0"
# fi

kill_daemons () {
  if [ -n "$MODUI_PID" ]
  then
    echo -n "Stopping mod-ui ... "
    kill $MODUI_PID 2>/dev/null
    echo "DONE"
  fi
  if [ -n "$LOADED" ]
  then
    echo -n "Stopping mod-monitor ... "
    jack_unload mod-monitor >/dev/null 2>&1
    echo "DONE"
  fi
  if [ -n "$MODHOST_PID" ]
  then
    echo -n "Stopping mod-host ... "
    kill $MODHOST_PID 2>/dev/null
    echo "DONE"
  fi
  if [ -n "$JACKD_PID" ]
  then
    echo -n "Stopping jackd ... "
    kill $JACKD_PID 2>/dev/null
    echo "DONE"
  fi
}

# Register a trap to stop the daemons.
trap kill_daemons EXIT

# Set a sane LV2 plugin folder
# ( N.B. mod-ui is picky about duplicates )
if [ -z "$LV2_PATH" ]
then
  export LV2_PATH="$HOME/.lv2"
fi

# Start jackd if not running already
PID=$(ps -o pid= -C jackd)
if [ -z "$PID" ]
then
  if [ -z "$JACKD_ARGS" ]
  then
    JACKD_ARGS="-R -d alsa -p 128 -n 1 -r 48000 -D"
  fi
  echo -n "Starting jackd ... "
  jackd $JACKD_ARGS -D -n mod >/dev/null 2>&1 &
  PID=$!
  sleep 5
  kill -0 $PID 2>/dev/null
  if [ $? -ne 0 ]
  then
    echo "FAILED"
    exit 1
  fi
  echo "DONE"
  JACKD_PID=$PID
fi

# Start mod-host if not started already
PID=$(ps -o pid= -C mod-host)
if [ -z "$PID" ]
then
  echo -n "Starting mod-host ... "
  mod-host -n -p 5555 -f 5556 >/dev/null 2>&1 &
  PID=$!
  sleep 3
  kill -0 $PID 2>/dev/null
  if [ $? -ne 0 ]
  then
    echo "FAILED"
    exit 1
  fi
  echo "DONE"
  MODHOST_PID=$PID
fi

echo -n "Loading mod-monitor ... "
jack_load mod-monitor >/dev/null 2>&1
echo "DONE"
LOADED="y"

echo -n "Starting modui ... "
export MOD_DEV_ENVIRONMENT=0
export MOD_LOG=0
python3 /opt/mod-ui/server.py >/dev/null 2>&1 &
PID=$!
sleep 3
kill -0 $PID 2>/dev/null
if [ $? -ne 0 ]
then
  echo "FAILED"
  exit 1
fi
echo "DONE"
MODUI_PID=$!
echo "Now point your web browser to http://localhost:8888"
wait
