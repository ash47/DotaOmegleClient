package {
    // Socket stuff
    import flash.net.Socket;

    // Buffer stuff
    import flash.utils.ByteArray;

    // Networking events
    import flash.events.Event;
    import flash.events.ProgressEvent;

    public class HttpRequest {
        // The socket we use for the connection
        private var sock:Socket;

        public function HttpRequest(url:String) {
            trace(url);

            // Create the socket
            sock = new Socket();

            // Max 10 second timeout
            sock.timeout = 10000;

            // Add events
            sock.addEventListener(Event.CONNECT, onSocketConnected);

            // Attempt to connect
            try {
                sock.connect('107.6.110.220', 80);
            } catch (e:Error) {
                // Error :(
                trace("Failure!");
            }
        }

        // When we successfully connect
        private function onSocketConnected(e:Event):void {
            // Hook the data
            sock.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);

            // Request options
            var path:String = '/';
            var host:String = 'http://omegle.com'

            // Setup the request
            var req:String = "GET " + path + " HTTP/1.1\r\n" +
               "Host: " + host + "\r\n" +
               "Connection: close\r\n\r\n";

            // Send the message
            var buff:ByteArray = new ByteArray();
            buff.writeUTFBytes(req);
            sock.writeBytes(buff, 0, buff.length);
            sock.flush();
        }

        // When we get data from our request
        private function onSocketData(e:ProgressEvent):void {
            // Grab how many bytes were sent
            var bl = e.bytesLoaded;

            // Create a buffer to read the data into
            var buff:ByteArray = new ByteArray();

            // Read the data into our buffer
            sock.readBytes(buff, 0, bl);

            trace(buff);
        }
    }
}
