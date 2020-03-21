all: base plugins
base:
	@docker build -t linux2573/addones:xtrabackup_base -f Dockerfile.base .

plugins:
	@docker build -t linux2573/xtrabackup:backup -f Dockerfile.plugin .

push:
	@docker push linux2573/addones:xtrabackup_base
	@docker push linux2573/xtrabackup:backup