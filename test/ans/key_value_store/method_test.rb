require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class TestSetting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string   :copy_right
          t.integer  :retry_limit
          t.decimal  :consumption_tax_rate
          t.datetime :start_at
          t.date     :start_on
          t.time     :start
        end
      end
    end

    class MethodTest < Minitest::Test
      describe "クラスメソッド" do
        it "data" do
          assert{TestSetting.respond_to?(:data)}
        end
      end

      describe "インスタンスメソッド" do
        it "persisted?" do
          assert{TestSetting.data.persisted? == true}
        end
        it "new_record?" do
          assert{TestSetting.data.new_record? == false}
        end

        it "copy_right" do
          assert{TestSetting.data.respond_to?(:copy_right)}
        end
        it "retry_limit" do
          assert{TestSetting.data.respond_to?(:retry_limit)}
        end
        it "consumption_tax_rate" do
          assert{TestSetting.data.respond_to?(:consumption_tax_rate)}
        end
        it "start_at" do
          assert{TestSetting.data.respond_to?(:start_at)}
        end
        it "start_on" do
          assert{TestSetting.data.respond_to?(:start_on)}
        end
        it "start" do
          assert{TestSetting.data.respond_to?(:start)}
        end

        it "copy_right=" do
          assert{TestSetting.data.respond_to?(:copy_right=)}
        end
        it "retry_limit=" do
          assert{TestSetting.data.respond_to?(:retry_limit=)}
        end
        it "consumption_tax_rate=" do
          assert{TestSetting.data.respond_to?(:consumption_tax_rate=)}
        end
        it "start_at=" do
          assert{TestSetting.data.respond_to?(:start_at=)}
        end
        it "start_on=" do
          assert{TestSetting.data.respond_to?(:start_on=)}
        end
        it "start=" do
          assert{TestSetting.data.respond_to?(:start=)}
        end

        it "copy_right_record" do
          assert{TestSetting.data.respond_to?(:copy_right_record)}
        end
        it "retry_limit_record" do
          assert{TestSetting.data.respond_to?(:retry_limit_record)}
        end
        it "consumption_tax_rate_record" do
          assert{TestSetting.data.respond_to?(:consumption_tax_rate_record)}
        end
        it "start_at_record" do
          assert{TestSetting.data.respond_to?(:start_at_record)}
        end
        it "start_on_record" do
          assert{TestSetting.data.respond_to?(:start_on_record)}
        end
        it "start_record" do
          assert{TestSetting.data.respond_to?(:start_record)}
        end
      end
    end
  end
end
