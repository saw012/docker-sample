# README
## 概要

ハンズオンについての説明を記入していきます。

## ハンズオンで扱うアプリケーションの全体図

シンプルな投票アプリケーションをdockerで起動させます。  
全体像はこのようになってます。  
(workerは`.NET`じゃなくて`Java`です)
![](./architecture.png)

ざっくりアプリケーションの説明すると、voting-appで投票し、redis、worker、dbを通り、result-appで投票結果が反映される感じです。（※私はアプリあまり詳しくないです）

これらのアプリケーションがdocker-compose.ymlで定義されており、`docker-compose up`で一気に立ち上げることができます。便利ですね！

## ハンズオンの内容

- docker-composeを立ち上げる前のdockerのプロセスを確認してみましょう

    ```bash
    docker-compose ps -a
    docker ps -a
    ```

- 資材を立ち上げましょう。

    ```bash
    docker-compose up -d
    ```

- dockerのプロセスの確認をしましょう。

    - 多分この辺のプロセスがいるはずです。

        - example-voting-app_result
        - example-voting-app_vote
        - redis:6.0.9-buster
        - example-voting-app_worker
        - postgres:9.4

        ```bash
        docker-compose ps 
        docker ps
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