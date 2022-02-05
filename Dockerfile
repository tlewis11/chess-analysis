FROM python:3

WORKDIR /usr/src/app

RUN apt-get update -y && apt-get install -y apt-utils stockfish 
ENV PATH=$PATH:/usr/games
COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

#CMD [ "python", "./pgn-analyzer.py" ]

CMD [ "python", "-m" , "flask", "run", "--host=0.0.0.0"]