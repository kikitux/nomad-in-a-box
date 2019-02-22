#!/usr/bin/env bash

for x in base base-client client{1..5}-dc{1..2} consul{1..3}-dc{1..2} nomad{1..3}-dc{1..2} vault1-dc1 ; do
  lxc delete ${x} --force &
done
wait
