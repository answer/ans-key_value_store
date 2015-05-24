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
        it "設定がリロードされる" do
          TestSetting::Data.reload
          assert{TestSetting.copy_right.nil?}
        end
      end
    end
  end
end
