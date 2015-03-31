require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class Setting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string :copy_right
          t.string :domain
        end

        validates :copy_right, presence: true
        validates :domain, presence: true
      end
    end

    describe "validation" do
      before do
        Setting.create(key: "copy_right", value: "answer")
        Setting.create(key: "domain", value: "") # 変更がなければバリデーションエラーを報告しない
        Setting.data.reload
      end
      it "バリデーションチェックが行われる" do
        Setting.data.copy_right = ""
        assert{Setting.data.save === false}
        assert{Setting.data.invalid?}
        assert{Setting.copy_right == "answer"}
        Setting.data.reload
        assert{Setting.copy_right == "answer"}
      end
    end
  end
end
