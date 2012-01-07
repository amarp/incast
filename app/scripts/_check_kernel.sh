#!/bin/bash -x

#rsh -f $1 "uname -a";
ssh -n $1 "uname -a";