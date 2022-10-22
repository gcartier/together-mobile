import 'dart:io';

class SocketWrapper {
  Socket _socket;

  final String secretCode = 'TWJG';

  SocketWrapper(this._socket, String id, void dataHandler(Uint8List),
      Function errorHandler, void doneHandler()) {
    _socket.write(secretCode);
    _socket.write('\"${id}\"');
    // _socket.write('\"A06250E4-B0D2-4119-90AB-E4B84D2FFCF3\"');
    _socket.listen(
      dataHandler,
      onError: errorHandler,
      onDone: doneHandler,
      cancelOnError: true,
    );
  }

  void write(message) {
    _socket.write(secretCode);
    _socket.write(message);
  }

  close() async {
    await (_socket.close());
  }

  destroy() {
    _socket.destroy();
  }
}
