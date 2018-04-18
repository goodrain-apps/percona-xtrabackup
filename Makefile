base:
	@docker build -t goodrain-apps/percona-xtrabackup:base -f Dockerfile.base .

plugins:
	@docker build -t goodrain-apps/percona-xtrabackup:plugins -f Dockerfile.plugin .