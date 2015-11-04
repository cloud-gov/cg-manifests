#!/bin/sh

spiff merge \
  concourse.yml \
  secrets.yml \
  > manifest.yml
