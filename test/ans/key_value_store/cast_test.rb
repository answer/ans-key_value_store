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
      describe "文字列での設定とキャスト、永続化からの復元" do
        before do
          TestSetting.data.instance_variable_set :@data, nil
          TestSetting.data.instance_variable_set :@stored_data, nil
        end
        it "copy_right" do
          TestSetting.data.update! copy_right: "answer"
          assert{TestSetting.find_by(key: "copy_right").value == "answer"}
          TestSetting.data.reload
          assert{TestSetting.copy_right == "answer"}
        end
        it "retry_limit" do
          TestSetting.data.update! retry_limit: "3"
          assert{TestSetting.find_by(key: "retry_limit").value == "3"}
          TestSetting.data.reload
          assert{TestSetting.retry_limit == 3}
        end
        it "consumption_tax_rate" do
          TestSetting.data.update! consumption_tax_rate: "0.8"
          assert{TestSetting.find_by(key: "consumption_tax_rate").value == "0.8"}
          TestSetting.data.reload
          assert{TestSetting.consumption_tax_rate == BigDecimal.new("0.8")}
        end
        it "start_on" do
          TestSetting.data.update! start_on: "2015/01/01"
          assert{TestSetting.find_by(key: "start_on").value == "2015-01-01"}
          TestSetting.data.reload
          assert{TestSetting.start_on == Date.parse("2015/01/01")}
        end
      end
      describe "文字列での設定とキャスト、永続化からの復元: utc 設定" do
        before do
          ActiveRecord::Base.default_timezone = :utc
          TestSetting.data.instance_variable_set :@data, nil
          TestSetting.data.instance_variable_set :@stored_data, nil
        end
        it "start_at" do
          TestSetting.data.update! start_at: "2015/01/01 10:00"
          assert{TestSetting.find_by(key: "start_at").value == Time.utc(2015,1,1,10,0,0).to_s}
          TestSetting.data.reload
          assert{TestSetting.start_at == Time.utc(2015,1,1,10,0,0)}
        end
        it "start" do
          TestSetting.data.update! start: "10:00"
          assert{TestSetting.find_by(key: "start").value == Time.utc(2000,1,1,10,0,0).to_s}
          TestSetting.data.reload
          assert{TestSetting.start == Time.utc(2000,1,1,10,0,0)}
        end
      end
      describe "文字列での設定とキャスト、永続化からの復元: local 設定" do
        before do
          ActiveRecord::Base.default_timezone = :local
          TestSetting.data.instance_variable_set :@data, nil
          TestSetting.data.instance_variable_set :@stored_data, nil
        end
        it "start_at" do
          TestSetting.data.update! start_at: "2015/01/01 10:00"
          assert{TestSetting.find_by(key: "start_at").value == Time.local(2015,1,1,10,0,0).to_s}
          TestSetting.data.reload
          assert{TestSetting.start_at == Time.local(2015,1,1,10,0,0)}
        end
        it "start" do
          TestSetting.data.update! start: "10:00"
          assert{TestSetting.find_by(key: "start").value == Time.local(2000,1,1,10,0,0).to_s}
          TestSetting.data.reload
          assert{TestSetting.start == Time.local(2000,1,1,10,0,0)}
        end
      end
      describe "空文字列での設定とキャスト、永続化からの復元" do
        before do
          ActiveRecord::Base.default_timezone = :utc
          TestSetting.data.instance_variable_set :@data, nil
        end
        it "copy_right" do
          TestSetting.create(key: "copy_right", value: "answer")
          TestSetting.data.reload
          TestSetting.data.copy_right = ""
          assert{TestSetting.copy_right == "answer"}
          TestSetting.data.save!
          assert{TestSetting.find_by(key: "copy_right").value == ""}
          TestSetting.data.reload
          assert{TestSetting.copy_right == ""}
        end
        it "retry_limit" do
          TestSetting.create(key: "retry_limit", value: "3")
          TestSetting.data.reload
          TestSetting.data.retry_limit = ""
          assert{TestSetting.retry_limit == 3}
          TestSetting.data.save!
          assert{TestSetting.find_by(key: "retry_limit").value.nil?}
          TestSetting.data.reload
          assert{TestSetting.retry_limit.nil?}
        end
        it "consumption_tax_rate" do
          TestSetting.create(key: "consumption_tax_rate", value: "0.8")
          TestSetting.data.reload
          TestSetting.data.consumption_tax_rate = ""
          assert{TestSetting.consumption_tax_rate == BigDecimal.new("0.8")}
          TestSetting.data.save!
          assert{TestSetting.find_by(key: "consumption_tax_rate").value.nil?}
          TestSetting.data.reload
          assert{TestSetting.consumption_tax_rate.nil?}
        end
        it "start_on" do
          TestSetting.create(key: "start_on", value: "2015-01-01")
          TestSetting.data.reload
          TestSetting.data.start_on = ""
          assert{TestSetting.start_on == Date.parse("2015/01/01")}
          TestSetting.data.save!
          assert{TestSetting.find_by(key: "start_on").value.nil?}
          TestSetting.data.reload
          assert{TestSetting.start_on.nil?}
        end
        it "start_at" do
          TestSetting.create(key: "start_at", value: "2015-01-01 10:00:00 UTC")
          TestSetting.data.reload
          TestSetting.data.start_at = ""
          assert{TestSetting.start_at == Time.utc(2015,1,1,10,0,0)}
          TestSetting.data.save!
          assert{TestSetting.find_by(key: "start_at").value.nil?}
          TestSetting.data.reload
          assert{TestSetting.start_at.nil?}
        end
        it "start" do
          TestSetting.create(key: "start", value: "2000-01-01 10:00:00 UTC")
          TestSetting.data.reload
          TestSetting.data.start = ""
          assert{TestSetting.start == Time.utc(2000,1,1,10,0,0)}
          TestSetting.data.save!
          assert{TestSetting.find_by(key: "start").value.nil?}
          TestSetting.data.reload
          assert{TestSetting.start.nil?}
        end
      end
    end
  end
end
