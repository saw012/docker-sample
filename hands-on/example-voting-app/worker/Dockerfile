# mavenga3.5、jdk-8が入ったalpineのものをベースイメージとして使用します。
# javaソースのビルドをするためのステージです。
FROM maven:3.5-jdk-8-alpine AS build

# アプリケーションのディレクトリを指定します。
WORKDIR /code

# ホストのpom.xmlを/code配下にコピーします。
COPY pom.xml /code/.

# ビルドするのに必要な準備をしています。
RUN ["mvn", "dependency:resolve"]
RUN ["mvn", "verify"]

# ホストのsrc/mainを/code配下にコピーします。
COPY ["src/main", "/code/src/main"]

# jarパッケージの生成をおこないます。
RUN ["mvn", "package"]

# openjdkの8-jreが入ったdebian-busterのものをベースイメージとして使用します。
# コンテナでは実際こちらがうごきます。
FROM openjdk:8-jre-buster

# buildステージでビルドした`/code/target/worker-jar-with-dependencies.jar`をルートに配置します
COPY --from=build /code/target/worker-jar-with-dependencies.jar /

# コンテナ起動時に指定したコマンドを実行します
CMD ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-jar", "/worker-jar-with-dependencies.jar"]
