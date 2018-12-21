#!/bin/bash

FLAG=$1
if [ ! $FLAG ] ; then
    FLAG=undefine
fi

ps aux|grep $FLAG|grep -v 'grep'|awk '{print $2}'|xargs kill -9
