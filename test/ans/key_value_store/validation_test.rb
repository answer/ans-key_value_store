require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class TestSetting < ActiveRecord::Base
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

    class ValidationTest < Minitest::Test
      describe "validation" do
        before do
          TestSetting::Data.reload
          TestSetting.find_by!(key: "copy_right").update!(value: "answer")
        end
        it "バリデーションチェックが行われる" do
          data = TestSetting.data
          assert{data.invalid?}
          assert{data.errors.has_key?(:domain)}
        end
      end
    end
  end
end
