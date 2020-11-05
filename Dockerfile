FROM openjdk:8

ENV DRUID_VERSION 0.20.0
ENV ZOOKEEPER_VERSION 3.5.8

# Get Druid
RUN mkdir -p /tmp \
    && cd /tmp/ \
    && curl -fsLS "https://downloads.apache.org/druid/0.20.0/apache-druid-0.20.0-bin.tar.gz&action=download" | tar xvz \
    && mv apache-druid-0.20.0 /opt/druid

WORKDIR /opt/druid/

# Zookeeper
RUN curl -fsLS "https://downloads.apache.org/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz&action=download" | tar xvz \
    && mv zookeeper-$ZOOKEEPER_VERSION zk

ADD config/common.runtime.properties conf/druid/single-server/micro-quickstart/_common/common.runtime.properties

RUN bash -c "./bin/start-micro-quickstart &" && \
    ./bin/post-index-task --file quickstart/tutorial/wikipedia-index.json --url http://localhost:8081 --submit-timeout 600

# Expose ports:
# - 8888: HTTP (router)
# - 8081: HTTP (coordinator)
# - 8082: HTTP (broker)
# - 8083: HTTP (historical)
# - 8091: HTTP (middlemanager)
# - 2181 2888 3888: ZooKeeper
EXPOSE 8888
EXPOSE 8081
EXPOSE 8082
EXPOSE 8083
EXPOSE 8091
EXPOSE 2181 2888 3888

ENTRYPOINT ./bin/start-micro-quickstart
