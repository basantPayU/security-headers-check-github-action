#! /usr/local/bin/bash

GRADE=6
# if the grade count is less than the length of the REQUIRED_HEADERS array
if [ $GRADE -lt 7 ]; then
  echo "rating=failure" 
  exit 1
else 
  echo "rating=success" 
  exit 0
fi