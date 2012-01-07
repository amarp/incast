#!/bin/bash -x

#rsh -f $1 "killall -9 a.out;";
ssh -n $1 "killall -9 a.out;";
