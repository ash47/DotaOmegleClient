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

        // The URL to request
        private var host:String;

        // The path to request
        private var path:String;

        // Data to send to the server
        private var queryData:String;

        // Should we keep the connection alive
        private var keepAlive:Boolean;

        // The callback to run when we get data
        private var callback:Function;

        // Stores data
        private var data:String;

        public function HttpRequest(ip:String, host:String, path:String, queryData:String, keepAlive:Boolean, callback:Function) {
            // Store data
            this.host = host;
            this.path = path;
            this.keepAlive = keepAlive;
            this.queryData = queryData;
            this.callback = callback;

            // Create the socket
            sock = new Socket();

            // Max 10 second timeout
            sock.timeout = 10000;

            // Add events
            sock.addEventListener(Event.CONNECT, onSocketConnected);

            // Attempt to connect
            try {
                sock.connect(ip, 80);
            } catch (e:Error) {
                // Error :(
                trace("Failure!");
            }
        }

        // When we successfully connect
        private function onSocketConnected(e:Event):void {
            // Hook the data
            sock.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
            sock.addEventListener(Event.CLOSE, onSocketClose);

            // Reset the data field
            this.data = '';

            // Workout the connection type
            var con = 'close';
            if(this.keepAlive) {
                con = 'Keep-Alive';
            }

            var dataHeader = '';
            if(this.queryData != null) {
                dataHeader = 'Content-Type: application/x-www-form-urlencoded\r\n' +
                    'Content-Length: '+this.queryData.length+'\r\n';
            }

            // Setup the request
            var req:String = "GET " + this.path + " HTTP/1.1\r\n" +
               "Host: " + this.host + "\r\n" +
               dataHeader +
               "Connection: "+con+"\r\n\r\n";

            // Send the message
            var buff:ByteArray = new ByteArray();
            buff.writeUTFBytes(req);
            sock.writeBytes(buff, 0, buff.length);
            sock.flush();

            // Forward the data
            if(this.queryData != null) {
                buff = new ByteArray();
                buff.writeUTFBytes(this.queryData);
                sock.writeBytes(buff, 0, buff.length);
                sock.flush();
            }
        }

        // When we get data from our request
        private function onSocketData(e:ProgressEvent):void {
            // Grab how many bytes were sent
            var bl = e.bytesLoaded;

            // Create a buffer to read the data into
            var buff:ByteArray = new ByteArray();

            // Read the data into our buffer
            sock.readBytes(buff, 0, bl);
            buff.position = 0;

            // Read the data
            this.data += buff.readUTFBytes(buff.length);
        }

        // When the socket closes
        private function onSocketClose(e:Event) {
            var split:Array = this.data.split('\r\n\r\n');
            if(split.length >= 2) {
                var split2 = split[1].split('\r\n');
                if(split2.length >= 2) {
                    var data:String = split2[1];

                    // Run the callback
                    callback(null, data);
                    return;
                }
            }

            // Something rooted up
            callback('Something went wrong!');
        }
    }
}
