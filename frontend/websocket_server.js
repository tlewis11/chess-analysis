const io = require('socket.io')();
const port = 8001;
io.on('connection', (socket) => {
    socket.on('chat message',(msg) => {
        console.log("messae: " + msg)
    });
})
io.listen(port);
console.log('Listening on port ' + port + '...');