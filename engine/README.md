#Docker Image for running a chess engine service with Flask and PyStockfish

#Getting Started

```
chmod +x local_docker_build_and_run.sh
./local_docker_build_and_run.sh
```
Browse to localhost:5000 to submit pgn or fen

or post your pgn or fen to `localhost:5000/compute ` to return Stockfish's recommended best move.