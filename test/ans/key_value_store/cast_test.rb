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

    class CastTest < Minitest::Test
      describe "キャスト" do
        before do
          TestSetting::Data.reload
        end
        it "copy_right" do
          setting = TestSetting.find_by!(key: "copy_right")
          setting.update!(value: "answer")
          assert{TestSetting.copy_right == "answer"}
          setting.update!(value: "answer!")
          assert{TestSetting.copy_right == "answer!"}
        end
        it "retry_limit" do
          setting = TestSetting.find_by!(key: "retry_limit")
          setting.update!(value: "3")
          assert{TestSetting.retry_limit == 3}
          setting.update!(value: "4")
          assert{TestSetting.retry_limit == 4}
        end
        it "consumption_tax_rate" do
          setting = TestSetting.find_by!(key: "consumption_tax_rate")
          setting.update!(value: "0.8")
          assert{TestSetting.consumption_tax_rate == BigDecimal.new("0.8")}
          setting.update!(value: "0.9")
          assert{TestSetting.consumption_tax_rate == BigDecimal.new("0.9")}
        end
        it "start_on" do
          setting = TestSetting.find_by!(key: "start_on")
          setting.update!(value: "2015/01/01")
          assert{TestSetting.start_on == Date.parse("2015/01/01")}
          setting.update!(value: "2015/01/02")
          assert{TestSetting.start_on == Date.parse("2015/01/02")}
        end
      end
      describe "キャスト: utc 設定" do
        before do
          TestSetting::Data.reload
          ActiveRecord::Base.default_timezone = :utc
        end
        it "start_at" do
          setting = TestSetting.find_by!(key: "start_at")
          setting.update!(value: "2015/01/01 10:00")
          assert{TestSetting.start_at == Time.utc(2015,1,1,10,0,0)}
          setting.update!(value: "2015/01/01 11:00")
          assert{TestSetting.start_at == Time.utc(2015,1,1,11,0,0)}
        end
        it "start" do
          setting = TestSetting.find_by!(key: "start")
          setting.update!(value: "10:00")
          assert{TestSetting.start == Time.utc(2000,1,1,10,0,0)}
          setting.update!(value: "11:00")
          assert{TestSetting.start == Time.utc(2000,1,1,11,0,0)}
        end
      end
      describe "キャスト: local 設定" do
        before do
          TestSetting::Data.reload
          ActiveRecord::Base.default_timezone = :local
        end
        it "start_at" do
          setting = TestSetting.find_by!(key: "start_at")
          setting.update!(value: "2015/01/01 10:00")
          assert{TestSetting.start_at == Time.local(2015,1,1,10,0,0)}
          setting.update!(value: "2015/01/01 11:00")
          assert{TestSetting.start_at == Time.local(2015,1,1,11,0,0)}
        end
        it "start" do
          setting = TestSetting.find_by!(key: "start")
          setting.update!(value: "10:00")
          assert{TestSetting.start == Time.local(2000,1,1,10,0,0)}
          setting.update!(value: "11:00")
          assert{TestSetting.start == Time.local(2000,1,1,11,0,0)}
        end
      end
      describe "空文字列のキャスト" do
        before do
          TestSetting::Data.reload
          ActiveRecord::Base.default_timezone = :utc
        end
        it "copy_right" do
          setting = TestSetting.find_by!(key: "copy_right")
          setting.update!(value: "")
          assert{TestSetting.copy_right == ""}
        end
        it "retry_limit" do
          setting = TestSetting.find_by!(key: "retry_limit")
          setting.update!(value: "")
          assert{TestSetting.retry_limit.nil?}
        end
        it "consumption_tax_rate" do
          setting = TestSetting.find_by!(key: "consumption_tax_rate")
          setting.update!(value: "")
          assert{TestSetting.consumption_tax_rate.nil?}
        end
        it "start_on" do
          setting = TestSetting.find_by!(key: "start_on")
          setting.update!(value: "")
          assert{TestSetting.start_on.nil?}
        end
        it "start_at" do
          setting = TestSetting.find_by!(key: "start_at")
          setting.update!(value: "")
          assert{TestSetting.start_at.nil?}
        end
        it "start" do
          setting = TestSetting.find_by!(key: "start")
          setting.update!(value: "")
          assert{TestSetting.start.nil?}
        end
      end
    end
  end
end
