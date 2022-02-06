import { useState } from 'react';
import Chess from 'chess.js';
import { Chessboard } from 'react-chessboard';

const axios = require('axios')


const SERVER_URL = 'http://localhost:3000'; //process.env.REACT_APP_SERVER_URL;

export default function App() {
  const [game, setGame] = useState(new Chess());
  function safeGameMutate(modify) {
    setGame((g) => {
      const update = { ...g };
      modify(update);
      return update;
    });
  }

  function makeEngineMove() {
    const possibleMoves = game.moves();
    
    if (game.game_over() || game.in_draw() || possibleMoves.length === 0) return; // exit if the game is over

    //var suggested_move;
    var formData = new FormData();
    formData.append('fen', game.fen());

    axios({ method: "post",
            url: SERVER_URL + "/suggest", 
            data: formData,
            Headers: {"Content-Type":"multipart/form-data"}
          })
      .then(res => {
        //#suggested_move = res['move'];
        //console.log(suggested_move);
        var suggested_move = res.data.move;
        safeGameMutate((game) => {
          game.move(suggested_move, {sloppy: true});
        });
      })
      .catch(error => {
        console.error(error)
      })

  }

  function onDrop(sourceSquare, targetSquare) {
    let move = null;

    safeGameMutate((game) => {
      move = game.move({
        from: sourceSquare,
        to: targetSquare,
        promotion: 'q' // always promote to a queen for example simplicity
      });
    });
    if (move === null) return false; // illegal move
    setTimeout(makeEngineMove, 200);
    return true;
  }

  return <Chessboard position={game.fen()} onPieceDrop={onDrop} />;
}
