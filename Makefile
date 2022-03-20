build:
	docker-compose build
run:
	docker-compose up
restart:
	echo "stopping docker services..."
	docker-compose down
	echo "building docker services..."
	docker-compose build
	echo "starting docker services..."
	docker-compose up


