require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    module NoTable
      class NoTableTest < Minitest::Test
        describe "テーブルがない場合" do
          it "モデルアクセスがエラーにならない" do
            class TestSetting < ActiveRecord::Base
              include Ans::KeyValueStore

              key_value_store do
                schema do |t|
                  t.string   :copy_right
                end
              end
            end

            assert{TestSetting.copy_right == nil}
          end
        end
      end
    end
  end
end
