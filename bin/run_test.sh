#!/bin/sh

bundle exec ruby -Ilib:test db/schema.rb

for test_case in test/ans/key_value_store/*_test.rb; do
  bundle exec ruby -Ilib:test $test_case
done


bundle exec ruby -Ilib:test db/drop_table.rb

for test_case in test/ans/key_value_store/no_table/*_test.rb; do
  bundle exec ruby -Ilib:test $test_case
done
