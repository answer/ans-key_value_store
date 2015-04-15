require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class TestSetting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string :copy_right
          t.string :other_value
        end
      end
    end

    class EvalIfChangedTest < Minitest::Test
      describe "eval_if_changed" do
        it "変更時に再評価される" do
          count = 0
          TestSetting.eval_if_changed do
            count += 1
            TestSetting.copy_right
          end

          assert{count == 1}

          TestSetting.data.update(copy_right: "answer")

          assert{count == 2}
        end

        it "他の値の変更時には再評価されない" do
          count = 0
          TestSetting.eval_if_changed do
            count += 1
            TestSetting.copy_right
          end

          assert{count == 1}

          TestSetting.data.update(other_value: "value")

          assert{count == 1}
        end
      end
    end
  end
end
