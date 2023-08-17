# sw-term
sw-term は Stormworks 上で動作するターミナルエミュレータです。

## Steam Workshop
本作品を実際に Stormworks 上で使用するには、Steam Workshop で公開しているこちらの作品を参照ください。\
https://steamcommunity.com/sharedfiles/filedetails/?id=3020958048

## システム構成
sw-term は以下のマイコンで構成されています。
- screen：端末の画面をモニタ部品に表示します。
- keyboard：端末への入力を行えるタッチキーボードを提供します。
- reset：ボタン入力に応じて端末をリセットします。

各マイコンの Lua スクリプトは、本リポジトリの対応するフォルダに `script.lua` として格納されています。ただし、screen と keyboard のスクリプトは4096文字制限を超えているため、[Pony IDE](https://lua.flaffipony.rocks/) などで minify する必要があります。

これらのマイコンは、サーバーアプリケーション sw-term-server と通信します。PTY の管理、ターミナルシーケンスの解析、シェルアプリケーションの起動等はサーバー側で行われます。サーバー側の詳細は [sw-term-server](https://github.com/gcrtnst/sw-term-server) のリポジトリを参照ください。

## 各 Lua スクリプトの仕様
### screen
プロパティ：
|種類|ラベル|用途|
|:---|:---|:---|
|number|HTTP Port|sw-term-server のリッスンポートを指定してください|
|number|Offset X|画面表示の X 座標を指定された分だけずらします|
|number|Offset Y|画面表示の Y 座標を指定された分だけずらします|

ロジック入出力：
|in/out|種類|チャンネル|用途|
|:---|:---|:---|:---|
|input|on/off|1|画面表示と HTTP 通信の有効/無効を切り替えます|
|output|video|-|端末の画面を出力します|

端末のサイズは sw-term-server のコマンドライン引数で設定できます。デフォルトでは MONITOR 9X5 部品に適したサイズに設定されています。

### keyboard
プロパティ：
|種類|ラベル|用途|
|:---|:---|:---|
|number|HTTP Port|sw-term-server のリッスンポートを指定してください|

ロジック入出力：
|in/out|種類|用途|
|:---|:---|:---|
|in|composite|タッチキーボードのタッチ入力です|
|out|video|タッチキーボードの画面を出力します|

タッチ入力と画面出力は同じモニタ部品に接続してください。

タッチキーボードは MONITOR 3x1 部品の画面サイズに合わせて作成しています。これより画面サイズが大きい場合、タッチキーボードは画面の左右中央寄せかつ下寄せで表示されます。

修飾キーはトグル式ではないためご注意ください。修飾キーを使うには、修飾キーを押しながら文字入力してください。修飾キーの複数同時使用は現状非対応です、ご了承ください。

### reset
プロパティ：
|種類|ラベル|用途|
|:---|:---|:---|
|number|HTTP Port|sw-term-server のリッスンポートを指定してください|

ロジック入出力：
|in/out|種類|チャンネル|用途|
|:---|:---|:---|:---|
|in|on/off|1|ON 入力時に端末をリセットします|

端末のリセットと表記していますが、より正確には端末を終了するのみで、再起動はしません。しかし、sw-term-server 側の仕様により、画面取得もしくはキーボード入力の API がコールされたとき、自動的に端末を起動するようになっているため、結果的に端末は再起動します。
