#!/usr/bin/env bash

for x in base client{1..3} consul{1..3} nomad{1..3} vault1 ; do
  lxc delete ${x} --force
done
