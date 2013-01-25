type message = {string user, string text}

module Model {
	
	/** the chat-room */
	server private Network.network(message) room = Network.empty();

	@async function broadcast(message) {
    	Network.broadcast(message, room);
  	}

  	function register(callback) {
  		Network.add_callback(callback,room);
  	}
}