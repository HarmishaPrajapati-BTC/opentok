LiveSession = {
  initialize: function() {
    var session = OT.initSession(API_KEY, sessionId);
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
        fitMode: 'contain'
      }, handleError);
    });

    // Create a publisher
    var publisher = OT.initPublisher('publisher', {
      insertMode: 'append',
      fitMode: 'contain'
    }, handleError);

    // Connect to the session
    session.connect(token, function(error) {
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
    var enableVideo=true;
    $('#disablevideo').on('click', function() {
      if(this.checked && enableVideo) {
          publisher.publishVideo(false);
          enableVideo=false;
          $('#toggle-trigger').prop('checked', true).change();
      } else
      {
        publisher.publishVideo(true);
        enableVideo=true;
        $('#toggle-trigger').prop('checked', false).change();
      }
    });
  }
};
