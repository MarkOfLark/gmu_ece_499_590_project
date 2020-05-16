
default:
	@echo "Try pressing tab after typing make to see a list of targets"

container:
	sudo docker build . --tag ece590:latest -f ./Dockerfile

run: container
	sudo docker run \
	-p 10000:8888 \
	-p 10001:4040 \
	-p 10003:27017 \
	-v /home/mmcderm1/gmu_ece_499_590_project:/project \
	-e SPARK_HOME=/opt/spark-2.4.5-bin-hadoop2.7 \
	-v /home/mmcderm1/gmu_ece_499_590_project/mongodata:/data/db \
	-it ece590 bash

.PHONY: container run
