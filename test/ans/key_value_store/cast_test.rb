require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class Setting < ActiveRecord::Base
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

    describe "文字列での設定とキャスト、永続化からの復元" do
      before do
        Setting.data.instance_variable_set :@data, nil
        Setting.data.instance_variable_set :@stored_data, nil
      end
      it "copy_right" do
        Setting.data.update! copy_right: "answer"
        assert{Setting.find_by(key: "copy_right").value == "answer"}
        Setting.data.reload
        assert{Setting.copy_right == "answer"}
      end
      it "retry_limit" do
        Setting.data.update! retry_limit: "3"
        assert{Setting.find_by(key: "retry_limit").value == "3"}
        Setting.data.reload
        assert{Setting.retry_limit == 3}
      end
      it "consumption_tax_rate" do
        Setting.data.update! consumption_tax_rate: "0.8"
        assert{Setting.find_by(key: "consumption_tax_rate").value == "0.8"}
        Setting.data.reload
        assert{Setting.consumption_tax_rate == BigDecimal.new("0.8")}
      end
      it "start_on" do
        Setting.data.update! start_on: "2015/01/01"
        assert{Setting.find_by(key: "start_on").value == "2015-01-01"}
        Setting.data.reload
        assert{Setting.start_on == Date.parse("2015/01/01")}
      end
    end
    describe "文字列での設定とキャスト、永続化からの復元: utc 設定" do
      before do
        ActiveRecord::Base.default_timezone = :utc
        Setting.data.instance_variable_set :@data, nil
        Setting.data.instance_variable_set :@stored_data, nil
      end
      it "start_at" do
        Setting.data.update! start_at: "2015/01/01 10:00"
        assert{Setting.find_by(key: "start_at").value == Time.utc(2015,1,1,10,0,0).to_s}
        Setting.data.reload
        assert{Setting.start_at == Time.utc(2015,1,1,10,0,0)}
      end
      it "start" do
        Setting.data.update! start: "10:00"
        assert{Setting.find_by(key: "start").value == Time.utc(2000,1,1,10,0,0).to_s}
        Setting.data.reload
        assert{Setting.start == Time.utc(2000,1,1,10,0,0)}
      end
    end
    describe "文字列での設定とキャスト、永続化からの復元: local 設定" do
      before do
        ActiveRecord::Base.default_timezone = :local
        Setting.data.instance_variable_set :@data, nil
        Setting.data.instance_variable_set :@stored_data, nil
      end
      it "start_at" do
        Setting.data.update! start_at: "2015/01/01 10:00"
        assert{Setting.find_by(key: "start_at").value == Time.local(2015,1,1,10,0,0).to_s}
        Setting.data.reload
        assert{Setting.start_at == Time.local(2015,1,1,10,0,0)}
      end
      it "start" do
        Setting.data.update! start: "10:00"
        assert{Setting.find_by(key: "start").value == Time.local(2000,1,1,10,0,0).to_s}
        Setting.data.reload
        assert{Setting.start == Time.local(2000,1,1,10,0,0)}
      end
    end
    describe "空文字列での設定とキャスト、永続化からの復元" do
      before do
        Setting.data.instance_variable_set :@data, nil
      end
      it "copy_right" do
        Setting.create(key: "copy_right", value: "answer")
        Setting.data.reload
        Setting.data.copy_right = ""
        assert{Setting.copy_right == "answer"}
        Setting.data.save!
        assert{Setting.find_by(key: "copy_right").value == ""}
        Setting.data.reload
        assert{Setting.copy_right == ""}
      end
      it "retry_limit" do
        Setting.create(key: "retry_limit", value: "3")
        Setting.data.reload
        Setting.data.retry_limit = ""
        assert{Setting.retry_limit == 3}
        Setting.data.save!
        assert{Setting.find_by(key: "retry_limit").value.nil?}
        Setting.data.reload
        assert{Setting.retry_limit.nil?}
      end
      it "consumption_tax_rate" do
        Setting.create(key: "consumption_tax_rate", value: "0.8")
        Setting.data.reload
        Setting.data.consumption_tax_rate = ""
        assert{Setting.consumption_tax_rate == BigDecimal.new("0.8")}
        Setting.data.save!
        assert{Setting.find_by(key: "consumption_tax_rate").value.nil?}
        Setting.data.reload
        assert{Setting.consumption_tax_rate.nil?}
      end
      it "start_on" do
        Setting.create(key: "start_on", value: "2015-01-01")
        Setting.data.reload
        Setting.data.start_on = ""
        assert{Setting.start_on == Date.parse("2015/01/01")}
        Setting.data.save!
        assert{Setting.find_by(key: "start_on").value.nil?}
        Setting.data.reload
        assert{Setting.start_on.nil?}
      end
      it "start_at" do
        Setting.create(key: "start_at", value: "2015-01-01 10:00:00 UTC")
        Setting.data.reload
        Setting.data.start_at = ""
        assert{Setting.start_at == Time.utc(2015,1,1,10,0,0)}
        Setting.data.save!
        assert{Setting.find_by(key: "start_at").value.nil?}
        Setting.data.reload
        assert{Setting.start_at.nil?}
      end
      it "start" do
        Setting.create(key: "start", value: "2000-01-01 10:00:00 UTC")
        Setting.data.reload
        Setting.data.start = ""
        assert{Setting.start == Time.utc(2000,1,1,10,0,0)}
        Setting.data.save!
        assert{Setting.find_by(key: "start").value.nil?}
        Setting.data.reload
        assert{Setting.start.nil?}
      end
    end
  end
end
