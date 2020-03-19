all: base plugins
base:
	@docker build -t rainbond/addones:xtrabackup_base -f Dockerfile.base .

plugins:
	@docker build -t rainbond/addones:xtrabackup_backup -f Dockerfile.plugin .

push:
	@docker push rainbond/addones:xtrabackup_base
	@docker push rainbond/addones:xtrabackup_backup