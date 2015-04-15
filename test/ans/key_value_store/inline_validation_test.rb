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

    class ValidationTest < Minitest::Test
      describe "validation" do
        before do
          TestSetting.create(key: "copy_right", value: "answer")
          TestSetting.create(key: "domain", value: "") # 変更がなければバリデーションエラーを報告しない
          TestSetting.data.reload
        end
        it "バリデーションチェックが行われる" do
          TestSetting.data.copy_right = ""
          assert{TestSetting.data.save === false}
          assert{TestSetting.data.invalid?}
          assert{TestSetting.copy_right == "answer"}
          TestSetting.data.reload
          assert{TestSetting.copy_right == "answer"}
        end
      end
    end
  end
end
