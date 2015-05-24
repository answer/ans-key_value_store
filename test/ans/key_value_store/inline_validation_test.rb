require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class TestSetting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string :copy_right, validates: {presence: true}
          t.string :domain,     validates: {presence: true}
        end
      end
    end

    class InlineValidationTest < Minitest::Test
      describe "inline validation" do
        before do
          TestSetting::Data.reload
          TestSetting.find_by!(key: "copy_right").update!(value: "answer")
        end
        it "全体のバリデーションチェックが行われる" do
          data = TestSetting.data
          assert{data.invalid?}
        end
        it "バリデーションチェックが行われる" do
          setting = TestSetting.find_by!(key: "copy_right")
          setting.value = ""
          assert{setting.invalid?}
        end
      end
    end
  end
end
