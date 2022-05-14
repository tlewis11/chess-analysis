#!/bin/bash

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 928001197750.dkr.ecr.us-east-1.amazonaws.com

docker build -t stockfish-engine .

docker tag stockfish-engine:latest 928001197750.dkr.ecr.us-east-1.amazonaws.com/stockfish-engine:latest
docker push 928001197750.dkr.ecr.us-east-1.amazonaws.com/stockfish-engine:latest
