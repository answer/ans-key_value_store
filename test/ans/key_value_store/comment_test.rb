require "ans/key_value_store/test_helper"

module Ans
  module KeyValueStore
    class Setting < ActiveRecord::Base
      include Ans::KeyValueStore

      key_value_store do
        schema do |t|
          t.string :copy_right, comment: %w{著作権表示}
        end
      end
    end

    describe "コメントメソッド" do
      it "copy_right_comment" do
        assert{Setting.data.copy_right_comment == ["著作権表示"]}
      end
    end
  end
end
