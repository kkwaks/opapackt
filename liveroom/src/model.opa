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
	string email,
	string nickname,
	string password
}

module Model {
	function insert(topic){
		match(next_id()){
		case {none}: {
			jlog("Failed to get next id, insert failed!")
			{false}
		}
		case {some:id}:{
			/liveroom/topics[~{id}] <- {topic with ~id}
			{true}	
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

	function auth(email,password){
		/** match(?/liveroom/users[~{email}]){
		case {none}: {none}
		case {some:user}: {
			if(user.password == password) some(user) else {none}
		}} */

		user = {
		 email: "li.wenbo@whu.edu.cn",
		 nickname: Random.string(8),
		 password: ""
		}
		some(user)		
	}
}