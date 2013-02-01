type Comment.t = {
	string author,
	string content,
	int posttime
}

type Message.t = {
	string author,
	string content,
	int posttime,
	list(Comment.t) comments
}

type Topic.t = {
	int id,
	string title,
	string author,
	int posttime,
	int lastupdate,
	string lastposter,
	int reply,	
	stringmap(Message.t) messages
}

type User.t = {
	string username,
	string password
}

module Model {
	/** inert topic to database */
	function insert(topic){
		match(next_id()){
		case {none}: {failure: "Failed to generate next id!"}
		case {some:id}:{
			/liveroom/topics[~{id}] <- {topic with ~id}
			{success: id}	
		}}
	}

	function query(page){
		topics = /liveroom/topics[skip page*50;limit 50;order -lastupdate]
		DbSet.iterator(topics)
	}

	function get(id){
		/liveroom/topics[~{id}]
	}

	function post_message(id,message){
		now = get_now()
		key = "{id}_{now}_{Random.string(5)}"

		/liveroom/topics[~{id}]/messages[key] <- message
		/liveroom/topics[~{id}]/reply++
		/liveroom/topics[~{id}]/lastupdate = now
		/liveroom/topics[~{id}]/lastposter = message.author
	}

	function post_comment(id,key,comment){
		/liveroom/topics[~{id}]/messages[key]/comments <+ comment
	}

	/**
	 * Authorization. this is fake, for real application, password should be encrypoed.
	 */
	function auth(username,password){
		if(String.is_blank(username) || String.is_blank(password)) {none} else {
			some(~{username, password})
		}
	}
}