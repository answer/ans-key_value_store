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

Setting.eval_if_changed do
  # 変更があった場合に再評価される
  config.copy_right = Setting.copy_right
end
```
```erb
<%= form_for Setting.data do |f| %>
  <%= f.label :copy_right %>
  <%= f.text_field :copy_right %>
<% end %>
```
```ruby
Setting.data.update params.require(:data).permit(:copy_right)

# バリデーションエラー
Setting.data.update! copy_right: nil # => raise ActiveRecord::RecordInvalid
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
      t.string   :copy_right
      t.integer  :retry_limit,          default: 3
      t.decimal  :consumption_tax_rate
      t.datetime :start_at
      t.date     :start_on
      t.time     :start
    end

    validates :copy_right, presence: true
  end
end
```

### key_value_store

データストア用のサブクラスを定義する

ブロックの中はデータストア用の ActiveModel::Model で、 validates でバリデーションの定義が可能


### schema

サブクラスには schema クラスメソッドが定義されており、これを使用してキーと型の定義を行う  
マイグレーションで使用可能なメソッドは使えるが、上記以外のテストはしていない

オプションは default のみ使用可能


### データが読み込まれるタイミング

設定値を取得、更新しようとしたタイミングで、すべてのデータが読み込まれる

`all` スコープが使用され、一回クエリが発行される


### データが保存されるタイミング

#### 値を取得、更新した時点(default が指定されているキー)

データが読み込まれたタイミングで、 default が指定されているキーについて書き込みを行う

該当するキーが nil の値を持っている場合に、キーを検索して値を更新  
nil 値を持つ default が指定されているキーに対して二回づつクエリが発行される


#### 保存された場合

update, update!, save, save! がコールされた時点ですべてのキーを検索して値を更新  
すべてのキーに対して一回づつ検索クエリが発行される  
変更があったキーに対して一回づつ更新クエリが発行される


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


## Setting and defaults

```ruby
class Setting < ActiveRecord::Base
  include Ans::KeyValueStore
  key_value_store(
    config.default_store_name,
    key: config.default_key_column,
    value: config.default_value_column,
    delegate: true,
  ) do
    ...
  end
end
```

* 第一引数 : データストア用のクラスインスタンスにアクセスするためのクラスメソッド名
* key : キーカラム名
* column : 値カラム名
* delegate : 各カラムをクラスメソッドとして定義するか

```ruby
# config/initializers/ans-key_value_store.rb
Ans::KeyValueStore.configure do |config|
  config.default_store_name = :data
  config.default_key_column = :key
  config.default_value_column = :value
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
