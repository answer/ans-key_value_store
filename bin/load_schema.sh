#!/bin/sh
bundle exec ruby -Ilib:test -r ./db/connection.rb db/schema.rb
