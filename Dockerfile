FROM registry.access.redhat.com/ubi8/ubi:latest
LABEL maintainer="Mark McDermott"

RUN yum install -y java-1.8.0-openjdk-devel.x86_64

RUN SCALA=scala-2.13.1 && \
  SCALA_HOME=/opt/${SCALA} && \
  curl https://downloads.lightbend.com/scala/2.13.1/${SCALA}.tgz -OJ && \
  tar -xvf ${SCALA}.tgz && \
  rm ${SCALA}.tgz && \
  mv ${SCALA} ${SCALA_HOME} && \
  echo "SCALA_HOME=${SCALA_HOME}" > /etc/profile.d/scala.sh && \
  echo "PATH=${PATH}:${SCALA_HOME}/bin" >> /etc/profile.d/scala.sh

# RUN \
#   MINICONDA=Miniconda3-latest-Linux-x86_64.sh && \
#   curl https://repo.anaconda.com/miniconda/${MINICONDA} -OJ && \
#   bash ${MINICONDA} -b -p /opt/miniconda && \
#   /opt/miniconda/bin/conda init && \
#   rm ${MINICONDA}

# RUN /opt/miniconda/bin/conda install -y numpy matplotlib scipy scikit-learn

RUN \
  ANACONDA=Anaconda3-2020.02-Linux-x86_64.sh && \
  curl https://repo.anaconda.com/archive/${ANACONDA} -OJ && \
  bash ${ANACONDA} -b -p /opt/anaconda && \
  /opt/anaconda/bin/conda init && \
  rm ${ANACONDA}

RUN \
  SPARK=spark-2.4.5-bin-hadoop2.7 && \
  SPARK_HOME=/opt/${SPARK} && \
  curl http://mirrors.ibiblio.org/apache/spark/spark-2.4.5/${SPARK}.tgz -OJ && \
  tar -xvf ${SPARK}.tgz && \
  rm ${SPARK}.tgz && \
  mv ${SPARK} ${SPARK_HOME} && \
  echo "SPARK_HOME=/${SPARK_HOME}" > /etc/profile.d/spark.sh && \
  echo "PATH=${PATH}:${SPARK_HOME}/sbin" >> /etc/profile.d/spark.sh && \
  echo "PATH=${PATH}:${SPARK_HOME}/bin" >> /etc/profile.d/spark.sh && \
  echo "PYSPARK_PYTHON=python3" >> /etc/profile.d/spark.sh && \
  echo "PYTHONPATH=${SPARK_HOME}/python:${PYTHONPATH}" >> /etc/profile.d/spark.sh

# RUN \
#   ZEP_VER=0.8.2 && \
#   ZEP_PATH=zeppelin-${ZEP_VER}-bin-all && \
#   curl http://apache.claz.org/zeppelin/zeppelin-${ZEP_VER}/${ZEP_PATH}.tgz -OJ && \
#   tar -xvf ${ZEP_PATH}.tgz

RUN /opt/anaconda/bin/conda install -y -c conda-forge findspark

RUN /opt/anaconda/bin/jupyter notebook --generate-config

RUN \
  RH_VER=8 && \
  MONGO_VER=4.2 && \
  MONGO_RPM=${MONGO_VER}.6-1.el${RH_VER}.x86_64.rpm && \
  MONGO_URL=https://repo.mongodb.org/yum/redhat/${RH_VER}/mongodb-org/${MONGO_VER}/x86_64/RPMS && \
  curl ${MONGO_URL}/mongodb-org-${MONGO_RPM} -OJ && \
  curl ${MONGO_URL}/mongodb-org-mongos-${MONGO_RPM} -OJ && \
  curl ${MONGO_URL}/mongodb-org-server-${MONGO_RPM} -OJ && \
  curl ${MONGO_URL}/mongodb-org-shell-${MONGO_RPM} -OJ && \
  curl ${MONGO_URL}/mongodb-org-tools-${MONGO_RPM} -OJ && \
  yum install -y mongodb-org-mongos-${MONGO_RPM} mongodb-org-server-${MONGO_RPM} mongodb-org-shell-${MONGO_RPM} mongodb-org-tools-${MONGO_RPM} mongodb-org-${MONGO_RPM} && \
  rm mongodb-org-mongos-${MONGO_RPM} mongodb-org-server-${MONGO_RPM} mongodb-org-shell-${MONGO_RPM} mongodb-org-tools-${MONGO_RPM} mongodb-org-${MONGO_RPM}

RUN /opt/anaconda/bin/conda install -y pymongo

RUN /opt/anaconda/bin/conda install -y -c conda-forge pydub
RUN /opt/anaconda/bin/conda install -y ffmpeg

RUN echo "jupyter notebook --ip 0.0.0.0 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' &" > launch_jupyter.sh && chmod 740 launch_jupyter.sh

RUN echo "mongod --bind_ip 0.0.0.0 &" > launch_mongodb.sh && chmod 740 launch_mongodb.sh

RUN echo "/opt/spark-2.4.5-bin-hadoop2.7/bin/pyspark &" > launch_pyspark.sh && chmod 740 launch_pyspark.sh

RUN echo "#!/bin/bash" > run_everything.sh && \
  echo "jupyter notebook --ip 0.0.0.0 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' &" >> run_everything.sh && \
  echo "mongod --bind_ip 0.0.0.0 &" >> run_everything.sh && \
  echo "/opt/spark-2.4.5-bin-hadoop2.7/bin/pyspark &" >> run_everything.sh && \
  echo "wait" >> run_everything.sh && \
  chmod 740 run_everything.sh

SHELL ["/bin/bash", "-c"]
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "source /opt/anaconda/bin/activate base && /run_everything.sh" ]

#CMD /bin/bash run_everything.sh
#RUN echo ./bin/pyspark --conf "spark.mongodb.input.uri=mongodb://127.0.0.1/test.myCollection?readPreference=primaryPreferred" \
#              --conf "spark.mongodb.output.uri=mongodb://127.0.0.1/test.myCollection" \
#              --packages org.mongodb.spark:mongo-spark-connector_2.11:2.4.1

#ENTRYPOINT ./launch_jupyter.sh && ./launch_mongodb.sh && pyspark
