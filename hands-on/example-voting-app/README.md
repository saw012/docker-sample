# README
## 概要

このページでは、ハンズオンについての説明を記載します。
いきなりすべてを理解するのは難しいとは思っていまして、いったんは適当に手を動かすでも良いと個人的には思っております。

## ハンズオンで扱うアプリケーションの全体図

ハンズオンで扱うアプリケーションの概要を説明します。

シンプルな投票アプリケーションをdockerで起動させます。  
全体像は下図の通りです。  
(workerは`.NET`ではなくて`Java`を使用しています)
![](./architecture.png)

アプリケーションの説明を簡単に行いますと、voting-appは`dog`か`cat`が投票ができるアプリケーションです。voting-appで投票し、redis、worker、db、result-appで投票結果が反映される感じです。

これらのアプリケーションがdocker-compose.ymlで定義されており、`docker-compose up`で一気に立ち上げることができます。便利ですね！

## ハンズオンの内容
### docker-compose
docker-composeのハンズオンです。あえて先にdocker-composeを行います。
都合によりdockerコマンドがでてきますがお気になさらず。。。

- 一応docker-compose.ymlの中身をみてみましょう。ここはGUIでも大丈夫です。あとパスは適当です。

    なんか中身が色々かかれています。

    ```bash
    cd /path/to/docker/hands-on/example-voting-app
    cat docker-compose.yml
    ```

- docker-composeを立ち上げる前のdockerのプロセスを確認してみましょう

    ```docker
    docker ps
    ```

- 資材を立ち上げましょう。workerがJavaでmavenつかっているので起動が初回は遅いです。

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

    - dockerネットワークをつくっておきます。

        - front-tierネットワークを作成します。

            voteとresultで使用します。

            ```bash
            docker network create front-tier
            ```

        - back-tierネットワークを作成します。

            すべてのコンテナで使用します。

            ```bash
            docker network create back-tier
            ```

        - 作成したネットワークを作成しましょう。`front-tier`、`back-tier`がいればOKです。

            ```bash
            docker network ls
            ```

    - 永続ボリュームをつくっておきます。

        - `db-data`を作成します。

            ```bash
            docker volume create db-data
            ```

        - 作成したネットワークを作成しましょう。`db-data`がいればOKです。

            ```bash
            docker volume ls
            ```

- redis

    redisを用意します。

    ```bash
    docker run -d -p 6379:6379 --net back-tier --name redis redis:6.0.9-buster
    ```

- db

    postgresqlを用意します。

    ```bash
    docker run -d -v db-data:/var/lib/postgresql/data --net back-tier -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres --name db postgres:9.4
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

    - dockerイメージをつかってコンテナを起動してみましょう。`docker run`するときにネットワークの接続は一気に2つできないようなのまずはback-tierからつなげます。

        ```bash
        docker run -d -p 5000:80 --network back-tier  --name vote vote:sample
        ```

    - 先ほど起動したvoteコンテナにfront-tierネットワークにもつなげていきます。

        - voteがいることを確認してください。

            ```bash
            docker ps 
            ```

        - voteにfront-tierネットワークを接続しましょう。

            ```bash
            docker network connect front-tier vote
            ```

        - 本当にネットワークがつながったか確認してみましょう。`vote`コンテナに接続したしたネットワーク`front-tier`、`back-tier`が表示されるはずです。

            ```bash
            docker container inspect vote
            ```

    - dockerのプロセス`vote`が立ち上がっているか確認しましょう

        ```bash
        docker ps
        ```

- worker

    - workerディレクトリにいって、Dockerfileの中身を確認しましょう。ここはGUIでも大丈夫です。

        ```bash
        cd ../worker
        ls -l 
        cat Dockerfile
        ```

    - 試しにビルドしてみましょう。  
        ※注)buildが数分かかるかもです。

        ```bash
        docker build -t worker:sample .
        ```

    - dockerイメージ`worker:sample`があるか確認してみましょう。

        ```bash
        docker images worker:sample
        ```

    - dockerイメージをつかってコンテナを起動してみましょう。(※mavenがわりと時間食います。あと色々ダウンロードします)


        ```bash
        docker run -d --net back-tier --name worker worker:sample
        ```

    - dockerのプロセス`worker`が立ち上がっているか確認しましょう

        ```bash
        docker ps
        ```

- result

    - voteディレクトリにいって、Dockerfileの中身を確認しましょう。ここはGUIでも大丈夫です。

        ```bash
        cd ../result
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

    - dockerイメージをつかってコンテナを起動してみましょう。`docker run`するときにネットワークの接続は一気に2つできないようなのまずはback-tierからつなげます。

        ```bash
        docker run -d -p 5001:80 -p 5858:5858 --network back-tier  --name result result:sample
        ```

    - 先ほど起動したresultコンテナにfront-tierネットワークにもつなげていきます。

        - resultがいることを確認してください。

            ```bash
            docker ps 
            ```

        - resultにfront-tierネットワークを接続しましょう。

            ```bash
            docker network connect front-tier result
            ```

        - 本当にネットワークがつながったか確認してみましょう。`result`コンテナに接続したしたネットワーク`front-tier`、`back-tier`が表示されるはずです。

            ```bash
            docker container inspect result
            ```

    - dockerのプロセス`result`が立ち上がっているか確認しましょう

        ```bash
        docker ps
        ```

- 動作確認

    - アプリケーションをブラウザから確認しましょう。どちらも開いてみてください。

        - [vote](http://localhost:5000)
        - [result](http://localhost:5001)

    - voteをクリックすると`Cats vs Dogs!`という画面が表示れます。`cat`もしくは`dog`のどちらかお好きな方を投票してください。

    - resultをクリックすると、投票結果の画面が表示されますので確認しましょう。

    voteで投票した内容がresultで反映されましたでしょうか・・・？できたら成功です！

- お片付け

    一個くらいなら全然問題ないんですが、複数もビルドするのはなかなか大変でしたね！
    お片付けしましょう。

    ```bash
    docker stop vote worker result redis db
    docker rm -f vote worker result redis db
    docker network rm front-tier back-tier
    docker volume prune
    docker image prune
    ```
