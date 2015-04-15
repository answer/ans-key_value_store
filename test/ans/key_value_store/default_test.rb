require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class TestSetting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string   :copy_right,           default: "answer"
          t.integer  :retry_limit,          default: 3
          t.decimal  :consumption_tax_rate, default: 0.8
          t.datetime :start_at,             default: "2015-01-01 10:00:00"
          t.date     :start_on,             default: "2015-01-01"
          t.time     :start,                default: "10:00:00"

          t.string :no_default_value
        end
      end
    end

    class DefaultTest < Minitest::Test
      describe "デフォルトの永続化" do
        before do
          TestSetting.data.reload
        end
        it "copy_right" do
          assert{TestSetting.find_by(key: "copy_right").value == "answer"}
        end
        it "retry_limit" do
          assert{TestSetting.find_by(key: "retry_limit").value == "3"}
        end
        it "consumption_tax_rate" do
          assert{TestSetting.find_by(key: "consumption_tax_rate").value == "0.8"}
        end
        it "start_at" do
          assert{TestSetting.find_by(key: "start_at").value == "2015-01-01 10:00:00"}
        end
        it "start_on" do
          assert{TestSetting.find_by(key: "start_on").value == "2015-01-01"}
        end
        it "start" do
          assert{TestSetting.find_by(key: "start").value == "10:00:00"}
        end

        it "no_default_value" do
          assert{TestSetting.find_by(key: "no_default_value").value.nil?}
        end
      end
    end
  end
end
