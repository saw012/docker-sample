# /bin/bash

####################################################################3
#
# dockerコマンドを打って構築するのが面倒な人のためのスクリプト
#
#####################################################################

# きれいにする
# コンテナの停止、削除
docker stop vote result worker redis db
docker rm vote result worker redis db

# ネットワーク削除
docker network rm back-tier front-tier

# 永続ボリューム削除
docker volume rm db-data

# 作成していく
# docker network作成
docker network create front-tier
docker network create back-tier

# 確認
echo ""
echo "------------------------------------------------------------------------"
echo "いったんdocker環境をきれいにしました"
echo "docker ps -a"
docker ps -a
echo ""
echo "docker network ls"
docker network ls
echo ""
echo "docker volume ls"
docker volume ls
echo "------------------------------------------------------------------------"
echo ""

# docker buildする
# vote
docker build -t vote:sample ./vote

# worker
docker build -t worker:sample ./worker

# result
docker build -t result:sample ./result

# docker runする
# redis
docker run -d -p 6379:6379 --net back-tier --name redis redis:6.0.9-buster

# db
docker run -d -v db-data:/var/lib/postgresql/data --net back-tier -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres --name db postgres:9.4
sleep 5

# vote
docker run -d -p 5000:80 --network back-tier  --name vote vote:sample
sleep 3
docker network connect front-tier vote

# worker
docker run -d --net back-tier --name worker worker:sample

# result
docker run -d -p 5001:80 -p 5858:5858 --network back-tier  --name result result:sample
sleep 3
docker network connect front-tier result


echo ""
echo "------------------------------------------------------------------------"
echo "サンプルアプリケーションをdockerコマンドで構築しました"
echo "docker ps -a"
docker ps -a
echo ""
echo "docker network ls"
docker network ls
echo ""
echo "docker volume ls"
docker volume ls
echo "------------------------------------------------------------------------"
echo ""