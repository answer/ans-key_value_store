require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class Setting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string :copy_right
        end

        validates :copy_right, presence: true
      end
    end

    describe "validation" do
      it "バリデーションチェックが行われる" do
        Setting.data.copy_right = ""
        assert{!Setting.data.save}
        assert{Setting.data.invalid?}
        Setting.data.reload
        assert{Setting.copy_right.nil?}
      end
    end
  end
end
