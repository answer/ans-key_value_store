require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class TestSetting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string :copy_right
        end
      end
    end

    class ReloadTest < Minitest::Test
      describe "リロード" do
        it "設定がリロードされ、変更点もクリアされる" do
          TestSetting.data.copy_right = "answer"
          TestSetting.data.reload
          assert{TestSetting.copy_right.nil?}
          assert{!TestSetting.data.changed?}
        end
      end
    end
  end
end
