FROM mesosphere/mesos:0.22.0-1.0.ubuntu1404
MAINTAINER Dan Isla <disla@jpl.nasa.gov>

ENV MESOS_NATIVE_LIBRARY /usr/local/lib/libmesos.so

ENV SPARK_VERSION 1.1.1-bin-hadoop2.4

RUN apt-get update

RUN apt-get install -y curl python && \
    curl -sf "http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}.tgz" | tar zx -C /opt && \
    mv "/opt/spark-${SPARK_VERSION}" /opt/spark

# Define working directory.
WORKDIR /opt/spark

ADD conf/jets3t.properties /opt/spark/conf/

ADD start.sh /opt/spark/
RUN chmod +x /opt/spark/start.sh

EXPOSE 4040

# Define default command.
CMD ["/opt/spark/start.sh"]
ENTRYPOINT ["/opt/spark/start.sh"]
