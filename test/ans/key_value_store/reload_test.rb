require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class Setting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string :copy_right
        end
      end
    end

    describe "リロード" do
      it "設定がリロードされ、変更点もクリアされる" do
        Setting.data.copy_right = "answer"
        Setting.data.reload
        assert{Setting.copy_right.nil?}
        assert{!Setting.data.changed?}
      end
    end
  end
end
