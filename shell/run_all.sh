#!/bin/bash

./shell/kill_all.sh

FLAG=$1
if [ ! $FLAG ] ; then
    FLAG=undefine
fi

./build/skynet ./config/gs_config.lua $FLAG > gs_nohup.out 2>&1 &
