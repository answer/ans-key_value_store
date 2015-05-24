require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class TestSetting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string   :copy_right, default: "answer"
          t.integer  :retry_limit, default: 3
          t.decimal  :consumption_tax_rate, default: "0.8"
          t.datetime :start_at, default: "2015/01/01 10:00:00"
          t.date     :start_on, default: "2015/01/01"
          t.time     :start, default: "10:00:00"
        end
      end
    end

    class AttributesTest < Minitest::Test
      describe "属性の取得" do
        before do
          TestSetting::Data.reload
          ActiveRecord::Base.default_timezone = :utc
        end
        it "build_data" do
          attributes = {
            "copy_right" => "answer",
            "retry_limit" => 3,
            "consumption_tax_rate" => BigDecimal.new("0.8"),
            "start_at" => Time.utc(2015,1,1,10,0,0),
            "start_on" => Date.parse("2015/01/01"),
            "start" => Time.utc(2000,1,1,10,0,0),
          }
          assert{TestSetting.build_data.attributes == attributes}
        end
      end
    end
  end
end
