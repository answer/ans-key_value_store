require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class Setting < ActiveRecord::Base
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

    describe "デフォルトの永続化" do
      before do
        Setting.data.reload
      end
      it "copy_right" do
        assert{Setting.find_by(key: "copy_right").try(:value) == "answer"}
      end
      it "retry_limit" do
        assert{Setting.find_by(key: "retry_limit").try(:value) == "3"}
      end
      it "consumption_tax_rate" do
        assert{Setting.find_by(key: "consumption_tax_rate").try(:value) == "0.8"}
      end
      it "start_at" do
        assert{Setting.find_by(key: "start_at").try(:value) == "2015-01-01 10:00:00"}
      end
      it "start_on" do
        assert{Setting.find_by(key: "start_on").try(:value) == "2015-01-01"}
      end
      it "start" do
        assert{Setting.find_by(key: "start").try(:value) == "10:00:00"}
      end

      it "no_default_value" do
        assert{Setting.find_by(key: "no_default_value").nil?}
      end
    end
  end
end
