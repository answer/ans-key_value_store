#!/bin/sh

bundle exec ruby -Ilib:test -r ./db/connection.rb db/schema.rb

for test_case in test/ans/key_value_store/*_test.rb; do
  bundle exec ruby -Ilib:test -r ./db/connection.rb $test_case
done


bundle exec ruby -Ilib:test -r ./db/connection.rb db/drop_table.rb

for test_case in test/ans/key_value_store/no_table/*_test.rb; do
  bundle exec ruby -Ilib:test -r ./db/connection.rb $test_case
done
