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
	int posttime,
	int lastupdate,
	string title,
	string author,
	stringmap(Message.t) messages
}

module Model {
	function insert(topic){
		match(next_id()){
		case {none}: jlog("insert failed!")
		case {some:id}: /liveroom/topics[~{id}] <- {topic with ~id}
		}
	}

	function query(_){
		topics = /liveroom/topics[id <= 100]
		DbSet.iterator(topics)
	}

	function get(id){
		/liveroom/topics[~{id}]
	}

	function post_message(id,message){
		key = Random.string(8);
		/liveroom/topics[~{id}]/messages[key] <- message
	}

	function post_comment(id,key,comment){
		/liveroom/topics[~{id}]/messages[key]/comments <+ comment
	}
}