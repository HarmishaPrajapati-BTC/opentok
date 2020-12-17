import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.apiKey = this.data.get("apiKey")
    this.sessionId = this.data.get("sessionId")
    this.token = this.data.get("token")
      var session = OT.initSession(this.apiKey, this.sessionId);
      var connectionCount = 0;
      session.on({
        connectionCreated: function (event) {
          connectionCount++;
          if (event.connection.connectionId !== session.connection.connectionId &&
            event.connection.creationTime < session.connection.creationTime){
            console.log(connectionCount)
            if (connectionCount > 1){
              alert('disconnecting this room is already full')
              session.disconnect();
            }
          }
        },
      });
      // Subscribe to a newly created stream
      session.on('streamCreated', function(event) {
        session.subscribe(event.stream, 'subscriber', {
          insertMode: 'append',
          width: '50%',
          height: '100%'
        }, handleError);
      });
  
      // Create a publisher
      var publisher = OT.initPublisher('publisher', {
        insertMode: 'append',
        width: '50%',
        height: '100%'
      }, handleError);
  
      // Connect to the session
      session.connect(this.token, function(error) {
        // If the connection is successful, initialize a publisher and publish to the session
        if (error) {
          handleError(error);
        } else {
          session.publish(publisher, handleError);
        }
      });
      function handleError(error) {
        if (error) {
          alert(error.message);
        }
      }
  }

  disconnect() {
    if (this.session) {
      this.session.disconnect()
    }
  }
}
