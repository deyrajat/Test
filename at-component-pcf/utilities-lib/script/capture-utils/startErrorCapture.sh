#!/bin/bash
rm -rf $1 
tail -f /var/log/broadhop/consolidated-qns.log | grep ERROR >> $1 &
