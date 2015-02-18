#!/bin/sh

spiff merge \
  main.yml \
  secrets.yml \
  > manifest.yml
