#!/bin/bash -x

#rsh -f $1 "killall -9 a.out; ~/src/incast/app/server/a.out > /tmp/$1.out";
ssh -n $1 "killall -9 a.out; ~/src/incast/app/server/a.out > /tmp/$1.out" &

