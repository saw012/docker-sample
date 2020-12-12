# README
## 概要

ハンズオンについての説明を記入していきます。
いきなりすべてを理解するのは難しいので、わからなかったら適当に手を動かすでも良いと思ってます。

## ハンズオンで扱うアプリケーションの全体図

シンプルな投票アプリケーションをdockerで起動させます。  
全体像はこのようになってます。  
(workerは`.NET`じゃなくて`Java`です)
![](./architecture.png)

ざっくりアプリケーションの説明すると、voting-appで投票し、redis、worker、dbを通り、result-appで投票結果が反映される感じです。

これらのアプリケーションがdocker-compose.ymlで定義されており、`docker-compose up`で一気に立ち上げることができます。便利ですね！

## ハンズオンの内容
### docker-compose
docker-composeのハンズオンです。あえて先にdocker-composeを行います。
都合によりdockerコマンドがでてきますがお気になさらず。。。

- 一応docker-compose.ymlの中身をみてみましょう。ここはGUIでも大丈夫です。

    なんか中身が色々かかれています。

    ```bash
    cat docker-compose.yml
    ```

- docker-composeを立ち上げる前のdockerのプロセスを確認してみましょう

    ```bash
    docker ps
    ```

- 資材を立ち上げましょう。

    ```bash
    docker-compose up -d
    ```

- dockerのプロセスの確認をしましょう。

    - 多分この辺のコンテナたちがいるはずです。

        - example-voting-app_result
        - example-voting-app_vote
        - redis
        - example-voting-app_worker
        - db

        ```bash
        docker-compose ps
        ```

- アプリケーションをブラウザから確認しましょう。どちらも開いてみてください。

   - [vote](http://localhost:5000)
   - [result](http://localhost:5001)

- voteから、`cat` か `dog` の好きな方を投票してください。

- resultから、結果をみてください。反映されましたでしょうか・・・？

- さて、docker 的な目線でどうなっているか確認しましょう。先ほどはプロセスを確認したので、ネットワークから。  
    docker-composeで作成されたネットワークがあります。確認してみましょう。
    docker-compose.ymlで定義したnetworksが追加されていると思います。

    ```bash
    docker network ls
    ```

- docker-compose.ymlから追加したネットワークを確認してみましょう。  
    何かつながってますね？

    - front-tierネットワーク

        - vote、resultがつながってます。

            ```bash
            docker inspect network example-voting-app_front-tier
            ```

    - back-tierネットワーク

        - vote、result、worker、redis、dbがつながってます。

            ```bash
            docker inspect network example-voting-app_back-tier
            ```

- volumeをみてみましょう。何もしないとdockerはプロセス切れるとデータを綺麗さっぱり吹っ飛ばしてくれるんですが、データを残しておきたい時はvolumeで定義します。今回だと`example-voting-app_db-data`がいるはずです。多分。

    ```bash
    docker volume ls
    ```

- お片付け

    dockerハンズオンと実はほぼ同じことを行ったのですが、圧倒的にdocker-composeをつかったほうが楽でしたね！それではお片付けしましょう。

    ```bash
    docker-compose down
    docker volume prune
    ```

### docker
docker-compose upしたら正直一発なのですが、あえてdockerコマンドでやってみましょう。長いので、疲れたら見るだけでも良いとおもってます。

- 準備

    dockerネットワークをつくっておきます。

    - front-tierネットワーク

        voteとresultで使用します。

        ```bash
        docker network create front-tier
        ```

    - back-tier

        すべてのコンテナで使用します。

        ```bash
        docker network create back-tier
        ```

    永続ボリュームをつくっておきます。

    - db-data

        ```bash
        docker volume create db-data
        ```

- vote

    - voteディレクトリにいって、Dockerfileの中身を確認しましょう。ここはGUIでも大丈夫です。

        ```bash
        cd vote
        ls -l 
        cat Dockerfile
        ```

    - 試しにビルドしてみましょう。

        ```bash
        docker build -t vote:sample .
        ```

    - dockerイメージ`vote:sample`があるか確認してみましょう。

        ```bash
        docker images vote:sample
        ```

    - dockerイメージをつかってコンテナを起動してみましょう

        ```bash
        docker run -d -p 5000:80 --net front-tier --net back-tier  --name vote-sample vote:sample
        ```

    - dockerのプロセス`vote-sample`が立ち上がっているか確認しましょう

        ```bash
        docker ps
        ```

- worker

    - workerディレクトリにいって、Dockerfileの中身を確認しましょう。ここはGUIでも大丈夫です。

        ```bash
        cd worker
        ls -l 
        cat Dockerfile
        ```

    - 試しにビルドしてみましょう。

        ```bash
        docker build -t worker:sample .
        ```

    - dockerイメージ`worker:sample`があるか確認してみましょう。

        ```bash
        docker images worker:sample
        ```

    - dockerイメージをつかってコンテナを起動してみましょう。

        ```bash
        docker run -d --net back-tier --name worker-sample worker:sample
        ```

    - dockerのプロセス`worker-sample`が立ち上がっているか確認しましょう

        ```bash
        docker ps
        ```

- result

    - voteディレクトリにいって、Dockerfileの中身を確認しましょう。ここはGUIでも大丈夫です。

        ```bash
        cd result
        ls -l 
        cat Dockerfile
        ```

    - 試しにビルドしてみましょう。

        ```bash
        docker build -t result:sample .
        ```

    - dockerイメージ`result:sample`があるか確認してみましょう。

        ```bash
        docker images result:sample
        ```

    - dockerイメージをつかってコンテナを起動してみましょう。

        ```bash
        docker run -d -p 5001:80 -p 5858:5858 --net front-tier --net back-tier --name result-sample result:sample
        ```

    - dockerのプロセス`result-sample`が立ち上がっているか確認しましょう。

        ```bash
        docker ps
        ```

- redis

    redisを用意します。

    ```bash
    docker run -d -p 6379:6379 --net back-tier --name redis-sample redis:6.0.9-buster
    ```

- db

    postgresqlを用意します。

    ```bash
    docker run -d -v db-data:/var/lib/postgresql/data --net back-tier  --name db-sample postgres:9.4
    ```

- 動作確認

    - アプリケーションをブラウザから確認しましょう。どちらも開いてみてください。

        - [vote](http://localhost:5000)
        - [result](http://localhost:5001)

    - voteから、`cat` か `dog` の好きな方を投票してください。

    - resultから、結果をみてください。反映されましたでしょうか・・・？できたら成功です！


- お片付け

    一個くらいなら全然問題ないんですが、複数もビルドするのは相当面倒でしたね！
    お片付けしましょう。

    ```bash
    docker rm -f vote-sample worker-sample result-sample redis-sample db-sample
    docker network rm front-tier back-tier
    docker volume prune
    ```
