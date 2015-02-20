require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class Setting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string :copy_right
          t.string :other_value
        end
      end
    end

    describe "eval_if_changed" do
      it "変更時に再評価される" do
        count = 0
        Setting.eval_if_changed do
          count += 1
          Setting.copy_right
        end

        assert{count == 1}

        Setting.data.update(copy_right: "answer")

        assert{count == 2}
      end

      it "他の値の変更時には再評価されない" do
        count = 0
        Setting.eval_if_changed do
          count += 1
          Setting.copy_right
        end

        assert{count == 1}

        Setting.data.update(other_value: "value")

        assert{count == 1}
      end
    end
  end
end
