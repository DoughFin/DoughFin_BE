#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
./bin/rails db:{create,migrate}
./bin/rails db:seed