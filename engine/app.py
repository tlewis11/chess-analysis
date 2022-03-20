from flask import Flask, render_template, request
from analyzer.pgn_analyzer import suggest_move
from flask_cors import CORS

app = Flask(__name__)
cors = CORS(app)

@app.route('/')
@app.route('/index')
def index():
    return render_template('index.html', title='Welcome')

@app.route('/suggest', methods=['post'])
def suggest():

    if request.form['fen']:
        print(f'pgn submitted: {request.form["fen"]}')
        suggested_move = suggest_move(fen=request.form['fen'])
    elif request.form['pgn']:
        print(f'pgn submitted: {request.form["pgn"]}')
        suggested_move = suggest_move(pgn=request.form['pgn'])
    else:
        return {"error": "fen or pgn must be supplied to post"}
    return {"move": suggested_move}

if __name__ == "__main__":
    app.run(debug=True)
