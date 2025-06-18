# 第五回課題

## 概要

* 組み込みサーバー(Puma)のみで起動。

* 組み込みサーバーとUnix Socketを使ったRailsアプリの動作確認。

* Nginxの単体起動確認。

* Nginxと組み込みサーバー、Unix Socketを組み合わせて、Railsアプリケーション動作確認を行う。

* ALBの追加。

* S3の追加。

* 構成図の作成。

## 1. 組み込みサーバー(Puma)のみで起動
### パブリックIPアドレスと3000番ポートでアクセスを行う。

![puma単体起動](image5/1pumaonly.png)

## 2. 組み込みサーバーとUnix Socketを使ったRailsアプリの動作確認
### puma.rbに記載を行う。
* TCP通信をコメントアウト。
* リッスン設定をUnix Socketに変更。

![ソケット変更](image5/2unixsockethenkou.png)

### curlコマンドを使用し,動作確認を行う。

``` 
curl --unix-socket /home/ec2-user/raisetech-live8-sample-app/tmp/sockets/puma.sock
```

![curl確認](image5/3curldousakakuninn.png)

【メモ】PumaがUnix socketで起動している場合、ブラウザから直接アクセスするためには、NginxやApacheなどのリバースプロキシが必要となる。これらがない場合での起動確認は、curlコマンド使用する。

## 3.Nginxの単体起動確認
### yumでNginxをインストール。

```
sudo yum -y install nginx
```

### Nginx起動
```
sudo systemctl start nginx
```

![nginx起動確認](image5/5nginxburauzakakuninn.png)

## 4.Nginxと組み込みサーバー、Unix Socketを組み合わせて、Railsアプリケーション動作確認を行う。
* ```/etc/nginx/nginx.conf.d```を修正しNginx再起動。
* Puma再起動。


![nginxpuma起動](image5/6Pumaandnginx.png)

### ブラウザでの確認

![nginx起動確認](image5/7.png)

## 5.ALBの追加
### ターゲットグループ作成・ヘルスチェック設定

![ALB-TG](image5/8ALB.png)

### ロードバランサー作成

![ロードバランサー](image5/9ALB.png)

### DNS名を使用しブラウザでアクセス

![DNSブラウザ確認](image5/10dnsburauzakakuninn.png)

## エラー発生
Blocked hostsエラーが発生したので、
```config/environments/development.rb```へ

`
config.hosts « "lecture05-1b-1580245885.ap-northeast-1.elb.amazonaws.com"`の記載を行う。

![エラー](image5/11error.png)

## 6.S3の追加

* バケット作成。
* EC2にS3フルアクセス権限のIAMロール権限を付与。
* storage.ymlの編集。 (S3 /リージョン/バケット名入力)
* development.rbの編集。（active storageをamazonに指定）
* active storageをインストール。
### バケット作成
![バケット](image5/12baketto.png)

ブラウザ内で画像をアップロードをし、バケットに反映できているかを確認。

![バケット](image5/15trouble.png)
※上記、アップロードした画像が、反映されないエラーが発生。
![バケット](image5/14bakettohannei.png)
バケットとの連携は完了。

## エラー発生　　
![トラブル](image5/16.png)

アプリケーションでアップロードした画像がブラウザで表示されないので、
調べていくとlibvipsが不足していることが判明。

　
※libvips：画像リサイズするライブラリ。

【解決した方法】
* Remiリポジトリをインストール。

```
sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
```

* Remiリポジトリからvipsを探してインストール。
```
sudo yum install vips --enablerepo=remi
```

![トラブル](image5/13ec2gazoutuika.png)
無事、画像反映完了。

## 7.構成図
![構成図](image5/17kouseizu.png)

## 感想
課題を進めていく上で、上記の他以外にも、たくさんのエラーが発生しました。

* Nginx 404エラー
* Nginx 502エラー
* development.rbにホスト名を記載　RailsのHost Authorization設定
* ALBのUnhealthy、Request timed out）※RDS未起動が原因。

一つのエラーを解決するために、かなりの時間を要してしまったので、早く解決できるよう、引き出しや、論理的思考を身につけなきゃなと考えさせられました。

これらエラーを早期解決するために、作業の切り分けをし、どこからどこまでがエラーが起きているかを推測しやすくする作業方法は非常に重要だと感じました。

