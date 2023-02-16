#!/usr/bin/env bash

amixer -q sset Master toggle
pkill -RTMIN+5 dwmblocks
