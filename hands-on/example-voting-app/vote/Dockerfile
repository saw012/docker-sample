# pythonの3.9.1のdebian-busterのものをベースイメージとして使用します
FROM python:3.9.1-buster

# アプリケーションのディレクトリを指定します。
WORKDIR /app

# 必要なpipモジュールを追加します
COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

# カレントディレクトリの資材をコンテナイメージ内にコピーします
COPY . .

# 環境変数PORT=80を定義します
EXPOSE 80

# コンテナ起動時に指定したコマンドを実行します
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
