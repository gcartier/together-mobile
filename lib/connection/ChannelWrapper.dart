// import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChannelWrapper {
  WebSocketChannel _channel;

  final String secretCode = 'TWJG';

  ChannelWrapper(this._channel, String id,
      void dataHandler(Uint8List),
      Function errorHandler,
      void Function() doneHandler)
  // Function(String? reason, int? code) doneHandler)
  {
    _channel.sink.add(secretCode + '\"${id}\"');
    // _socket.write('\"A06250E4-B0D2-4119-90AB-E4B84D2FFCF3\"');
    _channel.stream.listen(
      dataHandler,
      onError: errorHandler,
      // onDone: doneHandler(_channel.closeReason, _channel.closeCode),
      onDone: doneHandler,
      cancelOnError: true,
    );
  }

  void write(message) {
    String complete = secretCode + message;
    print ("writing ${complete}");
    _channel.sink.add(complete);
  }

  close() async {
    await (_channel.sink.close());
  }

  destroy() {
    // not sure what to do here
  }

  bool isClosed() {
    if (_channel?.closeCode == null) {
      return false;
    }
    return true;
  }
}
