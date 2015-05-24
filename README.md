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
# 値の読み出し
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

Setting.data.reload # DB から値を読み込み
```
```erb
<%# フォームの組み立て: model のように組み立てるとわかりやすいかもしれない %>
<%= form_for Setting.data do |f| %>
  <%= f.label :copy_right %>
  <%= f.text_field :copy_right %>
<% end %>
```
```ruby
# 更新時に読み出される値のアップデート
# アップデートは Setting モデルから行う
def update
  @setting = Setting.find_by(key: :copy_right)
  @setting.update(params.require(:setting).permit(:value))
end
```

```ruby
# バリデーション
@setting = Setting.find_by(key: :copy_right)
@setting.update(value: nil)
@setting.valid? # => false
```

```ruby
# カテゴリ
Setting.categories # => {core: {name: :core, label: "Core"}, general: {name: :general, label: "一般"}}

Setting.category_name(:core) # => Core

Setting.category(:core)
# => [<Setting key: copy_right>, <Setting key: retry_limit>, <Setting key: consumption_tax_rate>]

Setting.category(:general)
# => [<Setting key: start_at>, <Setting key: start_on>, <Setting key: start>]

Setting.category_name(:core) # => Core
Setting.category_name(:general) # => 一般

Setting.find_by(key: "copy_right").category #=> core
Setting.find_by(key: "copy_right").category_label #=> Core

Setting.find_by(key: "start_at").category #=> general
Setting.find_by(key: "start_at").category_label #=> 一般
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

設定値を取得しようとしたタイミングで、すべてのデータが読み込まれる  
`all` スコープが使用され、一回クエリが発行される

データの更新が完了した時点で、そのデータが読み込まれる

initializer 等、アプリケーションの初期化時点で読み出しを行うのが良いかもしれない

### データが保存されるタイミング

#### 値の一意性

key は一意であるべきなので、データベースレベルで unique インデックスを作っておく必要がある

アプリケーションレベルで一意にする努力はしていない

#### 値を取得した時点

データが読み込まれたタイミングで、 schema で指定したキーがデータベースに存在しない場合、書き込みを行う

書き込み時には default で指定した値を使用する


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

指定したバリデーションは対象のモデルに還元され、バリデーションエラー時には
base にバリデーションエラーメッセージが追加される

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

* 第一引数 : データストア名
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

* `default_store_name` : デフォルトのデータストア名
* `default_key_column` : デフォルトのキーとして使用するカラム名
* `default_value_column` : デフォルトの値として使用するカラム名
* `category_method_name` : カテゴリを取得するメソッドの名前
* `category_label_method_name` : カテゴリラベルを取得するメソッドの名前
* `category_scope_name` : カテゴリでフィルタするスコープの名前

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
