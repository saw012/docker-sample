# nodejsの15.4.0のdebian-busterのものをベースイメージとして使用します
FROM node:15.4.0-buster

# アプリケーションのディレクトリを指定します。
WORKDIR /app

# 作成するコンテナイメージの中に、コマンドを走らせます。
RUN npm install -g nodemon

# ホスト側にあるpackage*.jsonをコンテナの/app配下にコピーします
COPY package*.json ./

RUN npm ci \
 && npm cache clean --force \
 && mv /app/node_modules /node_modules

# カレントディレクトリの資材をコンテナイメージ内にコピーします
COPY . .

# 環境変数PORT=80を定義します
ENV PORT 80

# リッスンするポートを80番に指定します
EXPOSE 80

# コンテナ起動時に指定したコマンドを実行します
CMD ["node", "server.js"]
