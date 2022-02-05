from flask import Flask, render_template, request
from analyzer.pgn_analyzer import suggest_move

app = Flask(__name__)

@app.route('/')
@app.route('/index')
def index():
    return render_template('index.html', title='Welcome')

@app.route('/suggest', methods=['post'])
def suggest():
    suggested_move = suggest_move(fen=request.form['fen'])
    return suggested_move

if __name__ == "__main__":
    app.run(debug=True)
