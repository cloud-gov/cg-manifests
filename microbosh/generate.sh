#!/bin/sh

spiff merge \
  main.yml \
  secrets.yml \
  > microbosh-manifest.yml
