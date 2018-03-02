build:
	docker build -t git-sync-container-test:latest .

test:
	docker run --env-file env.list git-sync-container-test:latest

private-test:
	docker run --env-file private-env.list git-sync-container-test:latest

interactive-test:
	docker run -t -i --env-file env.list git-sync-container-test:latest /sbin/my_init -- /bin/bash -l

private-interactive-test:
	docker run -t -i --env-file private-env.list git-sync-container-test:latest /sbin/my_init -- /bin/bash -l