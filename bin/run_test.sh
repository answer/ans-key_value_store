#!/bin/sh
for test_case in test/ans/key_value_store/*_test.rb; do
  bundle exec ruby -Ilib:test -r ./db/connection.rb $test_case
done
