#!/usr/bin/env bash

NOTIFICATION=$(calcurse -n | awk 'NR==2 {$1=$1;printf $0}')
# If notification returns nothing (-z tests for empty var)
[[ -z $NOTIFICATION ]] && exit || \
  TIME=$(echo "$NOTIFICATION" | awk '{printf $1}')
  DESC=$(echo "$NOTIFICATION" | cut -d' ' -f2-)
  SOON=$(echo "$TIME" \
    | sed -e 's/\[/\ /g' -e 's/\]/\ /g' \
    | awk 'BEGIN {FS=":"} {printf $1}')
  [ $SOON = 00 ] \
    && notify-send -i /usr/share/icons/Adwaita/48x48/status/alarm-symbolic.symbolic.png \
      "Apointment in $TIME" \
      "\-\-> $DESC" "$@" \
    || exit

