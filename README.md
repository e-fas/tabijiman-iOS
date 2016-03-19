# tabijimanOSS-iOS / 旅自慢OSS-iOS

This app is released as a sample app with opendata (provided from SPARQL endpoint)

## 目次

- [このアプリについて](#このアプリについて)
    * [概要](#概要)
    * [使い方](#使い方)
    * [開発環境](#開発環境)
    * [検証済み環境](#検証済み環境)
    * [ライセンス](#ライセンス)
- [カスタマイズ](#カスタマイズ)
    * [パッケージ名を変更する](#パッケージ名を変更する)
    * [スプラッシュ画像を変更する](#スプラッシュ画像を変更する)
    * [アイコン画像を変更する](#アイコン画像を変更する)
    * [同梱カオハメフレームを変更する](#同梱カオハメフレームを変更する)
    * [とりあえず動作を変更する](#とりあえず動作を変更する)
- [開発情報](#開発情報)
    * [StoryBoard](#StoryBoard)
    * [多言語](#多言語)
    * [ライブラリ](#ライブラリ)
    * [Swiftを超えてるところ](#Swiftを超えてるところ)
- [オープンデータ](#オープンデータ)
    * [endpoint](#endpoint)
    * [データ提供](#データ提供)
- [謝辞](#謝辞)



## このアプリについて

### 概要

旅自慢OSS は、 観光マップ＆カオハメフレーム合成アプリです。オープンデータ活用実証のために、開発しました。
福井システム工業会が開発を行ったので、初期ロジックは福井をメインで扱う内容となっています。

- 観光マップ：
    * SPARQLエンドポイントから取得した観光情報を利用
    * 全国の観光情報を地図・詳細画面に表示
- カオハメフレーム：
    * SPARQLエンドポイントから取得したカオハメフレーム情報を利用 （今後、増殖予定！）
    * ２種類の内蔵フレームが同梱 （福井県福井市、福井県鯖江市）
    * カオハメフレームで写真をとり、Twitter, Facebook へシェアできます
- 多言語：
    * 日・英の対応したリソースを同梱
    * 一部、中国語・韓国語・ポルトガル語対応の部分も含まれています

### 使い方

swift で作った xcode のプロジェクトです。

- git clone でローカルにソースコードを展開して下さい
- ワークスペース : tabijiman.xcworkspace を xcodeで開いて開発が可能です
    * プロジェクト ： tabijiman.xcodeproj ではありません。関連ライブラリが読み込まれなくBuildが通らなくなりますので注意
- 必要なカスタマイズなどをおこなってください

### 開発環境

- Xcode 7.2.1 (OS X の App Store からダウンロード)
- Swift 2.1.1
- CocoaPods (ライブラリ管理ツール。個別にインストール。後述のライブラリの updateが容易に可能)
    * Podfile ファイルがあるディレクトリで　 '$ pod update' を行うと、各ライブラリが最新になります
- ライブラリ (いずれも、リポジトリに同梱。CocoaPods で管理されています)
    * [Alamofire](https://github.com/Alamofire/Alamofire)
    * [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
    * [SQLite.swift](https://github.com/stephencelis/SQLite.swift)

※ライブラリは、ダウンロード直後にBuildが試せるよう、開発時バージョンを同梱してあります

### 検証済み環境

- iPhone 6s + iOS 9.2.1
- iPhone 6 Plus + iOS 9.2.1
- iPhone 5s + iOS 8.4
- iPad2 + iOS 9.2.1

### ライセンス

- 旅自慢OSS ソフトウェア部分 は MITライセンス の元で配布されます。 LICENSE.txtを、参照ください。
- 旅自慢OSS 同梱のアイコン・画像は [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.ja) の元で配布されます。


## カスタマイズ

アプリをカスタマイズする時の、基本的な説明です。

### パッケージ名を変更する

プロジェクト名 : tabijiman , ターゲット名 : tabijimanOSS （日本語表記 : 旅自慢OSS） のターゲット名を変更すると、インストールした時のアプリ名が変更できます。

1. xcode で ワークスペースを開く
2. 左ペインのプロジェクトナビゲーター上部の tabijiman をクリック
3. 中央ペインに TARGETS の項目がでる。ここを変更するとターゲット名が変更されます
4. 日本語表記は、多言語対応ファイル tabijiman/InfoPlist.strings の中の修正します

```
// アプリ名の変更
CFBundleDisplayName = "旅自慢OSS";
```

### スプラッシュ画像を変更する

起動時のスプラッシュ画像は tabijiman/resources/LaunchImage.jpg です。
この画像を tabijiman/LaunchScreen.storyboard で読み込んで表示させています。

※LaunchImage.png (アルファチャネルなし） も同梱されていますが、スプラッシュ画像が真っ黒になる現象が実機で発生した為 jpeg を採用しています


### アイコン画像を変更する

アイコン画像は Assets.xcassets　> AppIcon で準備を行っています。
「iPhone App iOS 7-9 60pt」 の 2x　(W120xH120:Icon-60@2x.png), 3x (W180xH180:Icon-60@3x.png) が登録済みです。


### 同梱カオハメフレームを変更する

タイトルなどの文字情報　と　画像ファイル の２つにわけて管理されています。

- 文字情報：
    * tabijiman/InitFrameData.plist で ja/en の言語別に管理しています
    * 各item > img にかいたファイル名により、該当画像を指定します
- 画像ファイル：
    * tabijiman/resource.bundle の中に　フレーム画像 が配置されています
    * 変更や追加を行う場合には、xcode の 該当箇所に Finder からドラッグ＆ドロップしてください
    * カオハメしたい箇所を透過処理したPNGファイルを配置します
    * おすすめのサイズは W1080xH1440 です


### とりあえず動作を変更する

設定パラメーター系は　tabijiman/AppSetting.swift に、可能な限り集約してありますので、まずこのファイルをみてもらうのが良いと思います。
いくつか抜粋して紹介しますので、変更して動作させてみてください。

コード中からは、 *AppSetting.変数名* のようにして呼び出しています。　

```
...
    static let shareTag = "#tabijiman"
...
    // SPARQL
    static let SPARQL_endpoint = "http://sparql.odp.jig.jp/api/v1/sparql"
    static let SPARQL_get_param = "?output=json&query="
    static let minDescriptionString = 10

    // 観光情報を取得
    static let SPARQL_query_place =
    "select ?s ?name ?cat ?lat ?lng ?add ?name ?desc ?img {"
        + "?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/jrrk#CivicPOI>;"
        + "<http://imi.ipa.go.jp/ns/core/rdf#種別> ?cat;"
        + "<http://www.w3.org/2003/01/geo/wgs84_pos#long> ?lng;"
        + "<http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat;"
        + "<http://www.w3.org/2000/01/rdf-schema#label> ?name;"
        + "<http://imi.ipa.go.jp/ns/core/rdf#説明> ?desc;"
        + "<http://schema.org/image> ?img;"
        + "OPTIONAL {"
        +     "?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/jrrk#CivicPOI>;"
        +     "<http://purl.org/jrrk#address> ?add; }"
        + "}"
...
```

## 開発情報

### StoryBoard

次のファイルに、全画面が定義されています （起動時のスプラッシュ画面を除く）

- tabijiman/Main.storyboard

観光情報、カオハメフレームなどの詳細を表示する MoreInfo Scene のみ、３箇所で使いまわしていますので、コードも合わせて確認ください。

その他、画面デザイン上の注意点：

- Device: iPhone, Device Orientation: Portrait で設定してあります
- class size は、原則　「w:Any h:Any」 で開発をしています。部分的に　「w:Compact h:Regular」 での Constraints 指定が入っている可能性があります。
- UIコンポーネントに、外部ライブラリの利用はありません


### 多言語

コード内、StoryBoard上のリソースを含めて、基本の言語を英語とし、言語設定が日本語のときに、日本語リソースを利用する方針で開発されています。


### ライブラリ

各種ライブラリの利用用途

- Alamofire
    * endpoint , 画像ファイル への HTTPアクセスに利用
- SwiftyJSON
    * endpoint からのレスポンスの処理に利用
- SQLite.swift
    * 取得したオープンデータの内部保存、 内蔵フレームやGETフレームの管理に利用

### Swiftを超えてるところ

SHA256　のハッシュ関数の利用のため、次のBridgingHeaderファイルを追加してObjective-Cの関数を利用しています。

- tabijiman/tabijiman-Bridging-Header.h

ハッシュの使いどころは、endpoint情報の更新を確認する処理の中です。


## オープンデータ

### endpoint

本アプリでは [odp](http://odp.jig.jp/) 提供の　endpointにアクセスして、全国の自治体が公開している観光情報オープンデータを参照しています。

- [odp 開発者サイト](http://developer.odp.jig.jp/)  ※利用情報などがあります
- [odp SPARQLコンソール](http://sparql.odp.jig.jp/sparql.html)  ※ブラウザで表示する　チェックをいれて試行錯誤するのがオススメ

### データ提供

[odp データ提供](http://developer.odp.jig.jp/data/#assetlist) にある提供一覧の中より、<http://purl.org/jrrk#CivicPOI> に関連付けられてる、かつ画像を持つものなどの条件のもと取得して利用しています。

公開時にマップ上にできている自治体提供情報は、次になるようです。

- 北海道室蘭市
- 東京都品川区
- 福井県、県内各自治体
- 静岡県島田市
- 兵庫県神戸市
- 広島県尾道市


## 謝辞

次の皆様の協力のもと、本アプリを完成させることが出来ました。末筆ではありますが、謝辞を述べさせていただきます。

- 各種ライブラリを提供いただいている開発者・開発会社様
- イラストを無料提供いただいてる　[いらすとや](http://www.irasutoya.com/)　様
- 地元オープンデータを提供されてる自治体・担当者様
- odp提供会社の皆様
- 福井県システム工業会の関係者の皆様
- プロジェクトメンバーのプログラマー＆デザイナーの方々
