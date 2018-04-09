dev:
	rake db:create db:migrate
	foreman start -e .env.local -f Procfile.dev

docker_dependencies:
	docker-compose up -d postgres redis

docker_shell:
	docker-compose build
	docker-compose run --rm --service-ports web bash
