//import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChannelWrapper {
  WebSocketChannel _channel;

  final String secretCode = 'TWJG';

  ChannelWrapper(this._channel, String id, void dataHandler(Uint8List),
      Function errorHandler, void doneHandler()) {
    _channel.sink.add(secretCode + '\"${id}\"');
    // _socket.write('\"A06250E4-B0D2-4119-90AB-E4B84D2FFCF3\"');
    _channel.stream.listen(
      dataHandler,
      onError: errorHandler,
      onDone: doneHandler,
      cancelOnError: true,
    );
  }

  void write(message) {
    _channel.sink.add(secretCode);
    _channel.sink.add(message);
  }

  close() async {
    await (_channel.sink.close());
  }

  destroy() {
    //not sure what to do here
  }
}
