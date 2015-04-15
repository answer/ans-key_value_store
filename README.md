# Ans::KeyValueStore

こんなモデルで

```ruby
create_table :settings do |t|
  t.string :key
  t.text   :value
end

=begin
+----------------------+---------------------+
| key                  | value               |
+----------------------+---------------------+
| copy_right           | answer              |
| retry_limit          | 3                   |
| consumption_tax_rate | 0.8                 |
| start_at             | 2015-01-01 10:00:00 |
| start_on             | 2015-01-01          |
| start                | 10:00:00            |
+----------------------+---------------------+
=end
```

こういうアクセスができたらいいかも知れない

```ruby
Setting.copy_right           # => answer              <String>
Setting.retry_limit          # => 3                   <Fixnum>
Setting.consumption_tax_rate # => 0.8                 <BigDecimal>
Setting.start_at             # => 2015-01-01 10:00:00 <Time>
Setting.start_on             # => 2015-01-01          <Date>
Setting.start                # => {now} 10:00:00      <Time>

Setting.category(:core)
# => [<Setting key: copy_right>, <Setting key: retry_limit>, <Setting key: consumption_tax_rate>]

Setting.category(:general)
# => [<Setting key: start_at>, <Setting key: start_on>, <Setting key: start>]

Setting.find_by(key: "copy_right").category #=> core
Setting.find_by(key: "copy_right").category_label #=> Core

Setting.find_by(key: "start_at").category #=> general
Setting.find_by(key: "start_at").category_label #=> 一般

Setting.eval_if_changed do
  # 変更があった場合に再評価される
  config.copy_right = Setting.copy_right
end
```
```erb
<%# フォームの組み立て: update アクションへのルーティング %>
<%= form_for Setting.data do |f| %>
  <%= f.label :copy_right %>
  <%= f.text_field :copy_right %>
<% end %>
```
```ruby
# コントローラーでアップデートができる
Setting.data.update params.require(:setting_data).permit(:copy_right)

# バリデーションの定義も可能
# ただし、データ保存時には変更されていないカラムのバリデーションエラーはそのまま放っておいて更新は行われる
Setting.data.update! copy_right: nil # => raise ActiveRecord::RecordInvalid

# クラスメソッドで参照しているデータは保存が完了したもの
Setting.copy_right #=> "answer"
Setting.data.copy_right = "copy_right"
Setting.copy_right #=> "answer"
Setting.data.save
Setting.copy_right #=> "copy_right"

# キーで find_by したものを取得
Setting.data.copy_right_record #=> Setting.find_by(key: "copy_right")
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ans-key_value_store'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ans-key_value_store

## Usage

```ruby
class Setting < ActiveRecord::Base
  include Ans::KeyValueStore
  key_value_store do
    schema do |t|
      category :core do
        t.string   :copy_right,                       validates: {presence: true}
        t.integer  :retry_limit,          default: 3
        t.decimal  :consumption_tax_rate
      end
      category :general, label: "一般" do
        t.datetime :start_at
        t.date     :start_on
        t.time     :start
      end
    end
  end
end
```

### key_value_store

データストア用のサブクラスを定義する


### schema

サブクラスには schema クラスメソッドが定義されており、これを使用してキーと型の定義を行う  
マイグレーションで使用可能なメソッドは使えるが、上記以外のテストはしていない

オプションは default, validates のみ使用可能

validates を使用した場合、その項目に対してバリデーションが定義される

key_value_store ブロックの中はデータストア用の ActiveModel::Model なので、その後でも validate 関連のメソッドでバリデーションの定義は可能

### category

各キーにカテゴリを指定

カテゴリは `Setting.category(name)` スコープでそのカテゴリのキーのリレーションを取得したり、 `setting.category`, `setting.category_label` メソッドでカテゴリ名を取得したりするのに使用する

設定項目に操作権限を付けることを想定(core なら admin 権限のみ、とか)


### データが読み込まれるタイミング

設定値を取得、更新しようとしたタイミングで、すべてのデータが読み込まれる

`all` スコープが使用され、一回クエリが発行される


### データが保存されるタイミング

#### 値を取得した時点

データが読み込まれたタイミングで、 schema で指定したキーがデータベースに存在しない場合、書き込みを行う

書き込み時には default で指定した値を使用する

#### 保存された時点

update, update!, save, save! がコールされた時点で変更されたキーを検索して値を更新  
各変更済みキーに対して、検索して更新、の二回づつ検索クエリが発行される


## キャスト

キャストは ActiveRecord::Type::#{型クラス} を用いて行われる

* string   : String
* integer  : Integer
* decimal  : Decimal
* datetime : DateTime
* date     : Date
* time     : Time

datetime と time は、 ActiveRecord::Base.default_timezone によって、 utc か local かが決まる

データベースには、キャストされた値を `to_s` したものを保存する

String 以外の型に空文字列を設定すると値は nil に変換される  
データベース上も null で保存される

String の場合は空の文字列で設定すると空の文字列で保存される


## バリデーション

schema 定義の中で validates にハッシュを渡すことで定義可能  
また、 key_value_store ブロックの中で任意のバリデーションが定義可能

データ保存時にバリデーションエラーが検出された場合は更新がキャンセルされる

ただし、変更のないカラムにバリデーションエラーがあった場合、変更点の保存は行われる  
これは、想定している key-value のデータがそれぞれ独立していることを想定しているため、他の key のバリデーションエラーにつられてすべてのデータが更新不可能になるのが不便であったためである


## Setting and defaults

```ruby
class Setting < ActiveRecord::Base
  include Ans::KeyValueStore
  key_value_store(
    config.default_store_name,
    key: config.default_key_column,
    value: config.default_value_column,
  ) do
    ...
  end
end
```

* 第一引数 : データストア用のクラスインスタンスにアクセスするためのクラスメソッド名
* key : キーカラム名
* column : 値カラム名

```ruby
# config/initializers/ans-key_value_store.rb
Ans::KeyValueStore.configure do |config|
  config.default_store_name = :data
  config.default_key_column = :key
  config.default_value_column = :value
  config.category_method_name = :category
  config.category_label_method_name = :category_label
  config.category_scope_name = :category
end
```

* `default_store_name` : デフォルトのクラスメソッド名
* `default_key_column` : デフォルトのキーとして使用するカラム名
* `default_value_column` : デフォルトの値として使用するカラム名

## 想定していること

* value は小さな値で、全部で 100件程度
* 最初にすべての設定を読み、キャッシュ
* 更新は頻繁には行われない
* デフォルト値は最初に DB に記録

## テスト

* mysql データベースに接続: config/database.yml
* ./bin/run_test.sh でテストの実行

## Contributing

1. Fork it ( https://github.com/answer/ans-key_value_store/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
