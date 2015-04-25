#!/bin/bash

SPARK_HOME=${SPARK_HOME:-/opt/spark}

if [[ ! -z "$MESOS_SANDBOX" && -e "$MESOS_SANDBOX/conf" ]]; then
  for f in $MESOS_SANDBOX/conf; do
    BASE=`basename $f`
    DEST="${SPARK_HOME}/conf/${f}"
    echo "INFO: Copying conf file: $f -> $DEST"
    cp $f $DEST
  done
fi

if [[ ! -e $SPARK_HOME/conf/spark-defaults.conf ]]; then
  cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
fi

for VAR in `env`
do
  if [[ $VAR =~ ^SPARK_ && ! $VAR =~ ^SPARK_HOME && ! $VAR =~ ^SPARK_VERSION ]]; then
    spark_name=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    spark_name=${spark_name/spark\.eventlog/spark\.eventLog}
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    if egrep -q "(^|^#)$spark_name" $SPARK_HOME/conf/spark-defaults.conf; then
      sed -r -i "s@(^|^#)($spark_name)=(.*)@\2=${!env_var}@g" $SPARK_HOME/conf/spark-defaults.conf #note that no config values may contain an '@' char
    else
      echo "$spark_name=${!env_var}" >> $SPARK_HOME/conf/spark-defaults.conf
    fi
  fi
done

CMD=$1
shift

if [[ -z "$CMD" ]]; then
  echo "USAGE: $0 <shell|submit> <args ...>"
  exit 1
fi

if [[ "$CMD" == "shell" ]]; then
  echo "INFO: Starting spark-shell"
  /opt/spark/bin/spark-shell $@
elif [[ "$CMD" == "submit" ]]; then
  echo "INFO: Starting /opt/spark/bin/spark-submit $@"
  ${SPARK_HOME}/bin/spark-submit $@
else
  echo "ERROR: Invalid command as first arg: $CMD"
  exit 1
fi
