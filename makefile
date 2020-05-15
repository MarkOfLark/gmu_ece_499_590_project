
default:
	@echo "Try pressing tab after typing make to see a list of targets"

container:
	podman build --format=docker --tag ece590:latest -f ./Dockerfile

run: container
	podman run \
	-p 10000:8888 \
	-p 10001:4040 \
	-p 10002:8080 \
	-p 10003:27017 \
	-v /home/mmcderm1/projects/grad_school/gmu_ece590:/gmu_ece590 \
	-e SPARK_HOME=/opt/spark-2.4.5-bin-hadoop2.7 \
	-v /home/mmcderm1/projects/grad_school/gmu_ece590/mongodata:/data/db \
	-it localhost/ece590 bash

deploy: container
	podman save -o ece590.img localhost/ece590:latest
	tar -zcf ece590.img.tar.gz ece590.img

.PHONY: container run deploy
