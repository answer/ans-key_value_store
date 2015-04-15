require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class TestSetting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          category :core do
            t.string  :copy_right
            t.integer :retry_limit
            t.decimal :consumption_tax_rate
          end
          category :general, label: "一般" do
            t.datetime :start_at
            t.date     :start_on
            t.time     :start
          end
          t.time :no_category
        end
      end
    end

    class CategoryTest < Minitest::Test
      describe ".category" do
        before do
          TestSetting.data.reload
        end
        it "core" do
          assert{TestSetting.category(:core).pluck(:key) == ["copy_right","retry_limit","consumption_tax_rate"]}
          assert{TestSetting.category("core").pluck(:key) == ["copy_right","retry_limit","consumption_tax_rate"]}
          assert{TestSetting.category_label(:core) == "Core"}
          assert{TestSetting.category_label("core") == "Core"}
        end
        it "general" do
          assert{TestSetting.category(:general).pluck(:key) == ["start_at","start_on","start"]}
          assert{TestSetting.category("general").pluck(:key) == ["start_at","start_on","start"]}
          assert{TestSetting.category_label(:general) == "一般"}
          assert{TestSetting.category_label("general") == "一般"}
        end
        it "nil" do
          assert{TestSetting.category(nil).pluck(:key) == ["no_category"]}
          assert{TestSetting.category_label(nil) == ""}
        end
        it "unknown" do
          assert_raises(KeyError){TestSetting.category(:unknown).pluck(:key)}
          assert_raises(KeyError){TestSetting.category_label(:unknown)}
        end
      end

      describe "#category" do
        before do
          TestSetting.data.reload
        end
        it "core" do
          assert{TestSetting.find_by(key: "copy_right").category == :core}
          assert{TestSetting.find_by(key: "copy_right").category_label == "Core"}
        end
        it "general" do
          assert{TestSetting.find_by(key: "start_at").category == :general}
          assert{TestSetting.find_by(key: "start_at").category_label == "一般"}
        end
        it "nil" do
          assert{TestSetting.find_by(key: "no_category").category == nil}
          assert{TestSetting.find_by(key: "no_category").category_label == ""}
        end
      end
    end
  end
end
