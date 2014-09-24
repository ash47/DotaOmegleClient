package {
    // To make http requests
    import HttpRequest;

    // Buffer stuff
    import flash.utils.ByteArray;

    // JSON stuff
    import com.adobe.serialization.json.*;

    public class OmegleClient {
        // Our unique omegle identifier
        private var randid:String;

        // Our clientID
        private var clientID:String;

        // Event Processing Map
        private var eventMap:Object;

        public function OmegleClient() {
            // Allocate a new randomID
            newRandID();

            // Map of what to do with certain events
            eventMap = {
                waiting: this.omegleWaiting,
                connected: this.omegleConnected,
                recaptchaRequired: this.omegleRecaptchaRequired,
                commonLikes: this.omegleCommonLikes,
                typing: this.omegleTyping,
                stoppedTyping: this.omegleStoppedTyping,
                gotMessage: this.omegleGotMessage,
                strangerDisconnected: this.omegleStrangerDisconnected,
                statusInfo: this.omegleStatusInfo
            }

            // Connect to a stranger
            connect();
        }

        // Connects / reconnects
        private function connect() {
            // Connect
            new HttpRequest('107.6.110.220', 'http://front8.omegle.com', '/start?rcs=1&firstevents=1&m=0&lang=en&randid='+this.randid+'', null, false, onConnected);
        }

        // Fired when we get our initial connection
        private function onConnected(err, data:String) {
            if(err) return;

            // Attempt to decode the data
            var omegleData = decode(data);

            // Grab our ID
            this.clientID = omegleData.clientID;//.replace(':', '%3A');

            // Process any events
            processEvents(omegleData.events);
        }

        // Processes events
        private function processEvents(events:Array) {
            if(events != null) {
                // Loop over the events
                for(var i:Number = 0; i<events.length; i++) {
                    var event = events[i];

                    // Check if we have a handler for this event
                    if(eventMap[event[0]] != null) {
                        // Run the handler
                        eventMap[event[0]](event);
                    }
                }
            }

            // Do the events loop
            new HttpRequest('107.6.110.220', 'http://front8.omegle.com', '/events', 'id='+this.clientID, true, eventLoop);
        }

        // The event loop
        private function eventLoop(err, data:String) {
            if(err) {
                processEvents(null);
                return;
            }

            // Process the data
            processEvents(decode(data));
        }

        // Genereates a new random ID for us
        public function newRandID() {
            // Reset randomID
            this.randid = '';

            // Data to pull from
            var randData = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';

            // Add 8 random characters for our ID
            for(var i=0; i<8; i++) {
                this.randid += randData.charAt(Math.floor(Math.random() * randData.length));
            }
        }

        // JSON decoder
        public static function decode(s:String, strict:Boolean = true):* {
            return new JSONDecoder(s, strict).getValue();
        }

        // JSON encoder
        public static function encode(o:Object):String {
            return new JSONEncoder(o).getString();
        }

        /*
            Omegle message handlers
        */

        private function omegleWaiting(args:Array) {
            trace('Searching for a stranger...');
        }

        private function omegleConnected(args:Array) {
            trace('A stranger has connected!');
        }

        private function omegleGotMessage(args:Array) {
            trace('Got a message!');
            trace(args[1]);
        }

        private function omegleCommonLikes(args:Array) {
            trace('Got common likes');
        }

        private function omegleTyping(args:Array) {
            trace('Stranger is typing');
        }

        private function omegleStoppedTyping(args:Array) {
            trace('Stranger stoped typing');
        }

        private function omegleStrangerDisconnected(args:Array) {
            trace('Stranger disconnected');

            // Lets go ahead and reconnect
            connect();
        }

        private function omegleStatusInfo(args:Array) {}

        private function omegleRecaptchaRequired(args:Array) {
            trace('Recapture required GGWP');
        }
    }
}