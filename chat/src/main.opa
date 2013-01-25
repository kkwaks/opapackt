Server.start(Server.http, [
	{resources: @static_resource_directory("resources")},
	{register: [{css:["/resources/css/style.css"]}]},
	{title:"Opa Chat", page: View.page }
])