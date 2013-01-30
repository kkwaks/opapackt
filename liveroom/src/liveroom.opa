import stdlib.apis.mongo

database liveroom {
	int     /next_id
	Topic.t /topics[{id}]
	User.t  /users[{email}]
}
my_db = MongoConnection.openfatal("default")

function next_id(){
	if(?/liveroom/next_id == none) { /liveroom/next_id <- 0 }

  	r = MongoCommands.findAndUpdateOpa(
         my_db, "liveroom", "_default",
         Bson.opa2doc({_id : "/liveroom/next_id"}),
         Bson.opa2doc({`$inc` : { value : 1}}),
         {some : true}, {none}
	);
	match (r) {
	case { success : {string _id, int value} v }: some(v.value)
	case { failure : e }: {
		Log.error("Db:", "{MongoCommon.string_of_failure(e)}"); 
		{none}
	}}
}

function get_now() {
	Date.in_milliseconds(Date.now())
}

function to_date(ms){
	Date.milliseconds(ms)
}

function time_tag(t){
	now = Date.in_milliseconds(Date.now()) / 1000
	t   = t / 1000
	if(now - t < 60) "just now" else {
		if(now - t < 3600) "{(now - t) / 60} minutes ago" else {
			if(now - t < 86400) "{(now - t) / 3600} hours ago" else "{(now - t) / 86400} days ago"
		}
	}

}

function dispatch(url){
	match(url){
	case {path:[] ...}: 				View.main()
	case {path:["new_topic"] ... }:		if(Login.logged()) View.new_topic() else Login.page()
	case {path:["detail",id|_] ...}:    View.detail(Int.of_string(id))
	case {path:["login"] ...}:			Login.page()
	case {path:["connect"] ...}:{
		data = List.head(url.query).f2
		Login.connect(data)
	} 		
	case {path:_ ...}:					View.main()
	}
}

Server.start(Server.http, [
	{resources: @static_resource_directory("resources")},
	{register: [
		{doctype: {html5}},
		{css: ["/resources/css/style.css"]}
	]},
	{~dispatch}
])