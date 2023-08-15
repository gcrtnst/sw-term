# sw-term
sw-term は Stormworks 上で動作するターミナルエミュレータです。

## システム構成
sw-term は以下のマイコンで構成されています。
- screen：端末の画面をモニタ部品に表示します。
- keyboard：端末への入力を行えるタッチスクリーンを提供します。
- reset：ボタン入力に応じて端末を再起動します。

各マイコンの Lua スクリプトは、本リポジトリの対応するフォルダに `script.lua` として格納されています。ただし、screen と keyboard のスクリプトは4096文字制限を超えているため、[Pony IDE](https://lua.flaffipony.rocks/) などで minify する必要があります。

これらのマイコンは、サーバーアプリケーション [sw-term-server](https://github.com/gcrtnst/sw-term-server) と通信します。PTY の管理、ターミナルシーケンスの解析、シェルアプリケーションの起動等はサーバー側で行われます。
