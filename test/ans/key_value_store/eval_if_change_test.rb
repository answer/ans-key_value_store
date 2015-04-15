require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class TestSetting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string :copy_right
          t.string :other_value
        end
      end
    end
    class Variable
      def variable
        TestSetting.eval_if_changed do
          @count ||= 0
          @count += 1
          @variable = TestSetting.copy_right
        end
      end
      def cached_variable
        unless @cached_variable
          TestSetting.eval_if_changed do
            @count ||= 0
            @count += 1
            @cached_variable = TestSetting.copy_right
          end
        end
        @cached_variable
      end
      def count
        @count
      end
    end

    class EvalIfChangedTest < Minitest::Test
      describe "eval_if_changed" do
        before do
          TestSetting.data.update(copy_right: "answer")
        end
        it "変更時に再評価される" do
          variable = Variable.new
          assert{variable.variable == "answer"}
          assert{variable.variable == "answer"}
          assert{variable.count == 2}
          TestSetting.data.update(copy_right: "other")
          assert{variable.count == 4}
          assert{variable.instance_variable_get(:@variable) == "other"}
        end

        it "他の値の変更時には再評価されない" do
          variable = Variable.new
          assert{variable.variable == "answer"}
          assert{variable.count == 1}
          TestSetting.data.update(other_value: "value")
          assert{variable.count == 1}
          assert{variable.instance_variable_get(:@variable) == "answer"}
        end

        it "キャッシュされているインスタンス変数が更新される" do
          variable = Variable.new
          assert{variable.cached_variable == "answer"}
          assert{variable.cached_variable == "answer"}
          assert{variable.count == 1}
          TestSetting.data.update(copy_right: "other")
          assert{variable.count == 2}
          assert{variable.instance_variable_get(:@cached_variable) == "other"}
        end
      end
    end
  end
end
