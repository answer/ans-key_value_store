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

    describe "クラスメソッド" do
      it "data" do
        assert{Setting.respond_to?(:data)}
      end
    end

    describe "インスタンスメソッド" do
      it "persisted?" do
        assert{Setting.data.persisted? == true}
      end
      it "new_record?" do
        assert{Setting.data.new_record? == false}
      end

      it "copy_right" do
        assert{Setting.data.respond_to?(:copy_right)}
      end
      it "retry_limit" do
        assert{Setting.data.respond_to?(:retry_limit)}
      end
      it "consumption_tax_rate" do
        assert{Setting.data.respond_to?(:consumption_tax_rate)}
      end
      it "start_at" do
        assert{Setting.data.respond_to?(:start_at)}
      end
      it "start_on" do
        assert{Setting.data.respond_to?(:start_on)}
      end
      it "start" do
        assert{Setting.data.respond_to?(:start)}
      end
    end
  end
end
