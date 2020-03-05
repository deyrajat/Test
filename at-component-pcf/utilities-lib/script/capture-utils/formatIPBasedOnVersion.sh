#!/bin/sh

if [ "$1" != "${1#*[0-9].[0-9]}" ]; then
  echo $1
elif [ "$1" != "${1#*:[0-9a-fA-F]}" ]; then
  echo "[$1]"
else
  echo "Unrecognized IP format '$1'"
fi