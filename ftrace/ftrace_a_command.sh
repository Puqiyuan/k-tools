#!/bin/bash

echo nop > /sys/kernel/debug/tracing/current_tracer
echo > /sys/kernel/debug/tracing/trace
echo 1 > /sys/kernel/debug/tracing/options/function-fork

./while-true-command.sh &

echo "$!" > /sys/kernel/debug/tracing/set_ftrace_pid
echo function > /sys/kernel/debug/tracing/current_tracer
