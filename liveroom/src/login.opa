import stdlib.apis.{facebook, facebook.auth, facebook.graph}
import stdlib.themes.bootstrap.css

type Login.user = {unlogged} or {User.t user}

module Login {
	config = {
		app_id:  "***************",
		api_key: "***************",
		app_secret: "*******************************"
	}
	
	FBA 	  = FbAuth(config)
	FBG 	  = FbGraph
	login_url = FBA.user_login_url([], redirect)
 	redirect  = "http://localhost:8080/connect"

 	state = UserContext.make(Login.user {unlogged})

 	/**
 	 * The login page
 	 */ 
	function page() {
		xhtml = <>
			<div id=#title class="navbar navbar-fixed-top">
	      		<div class=navbar-inner> 
	      			<div class="container-fluid">
	      				<a href="/" class="brand">
	      					<img alt="Opa" src="/resources/img/opa-logo.png" class="logo">
	      				</a>
	      			</div>
	      		</div>
	    	</div>
		<div class="container" style="width:100%;margin-top:15px">
		      <div class="form-signin">
		        <h2 class="form-signin-heading">Please sign in</h2>
		        <input id=#username type="text" class="input-block-level" placeholder="Username">
		        <input id=#password type="password" class="input-block-level" placeholder="Password">
		        <label class="checkbox">
		          <input type="checkbox" value="remember-me"> Remember me
		        </label>
		        <button class="btn btn-large btn-primary" type="submit" onclick={login}>Sign in</button>
		        <a href="{login_url}" class="btn btn-large btn-info" >Sign in with Facebook</a>
		      </div>
    		</div>
		</>
		header = <><meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no"></>
		Resource.full_page("Login",xhtml, header, {success}, [])
	}

	function show_login(_){ Dom.show(#login_form) }

	function login(_) {
		username = Dom.get_value(#username)
		password = Dom.get_value(#password)
		match(Model.auth(username,password)){
		case {none}: Client.reload()
	  	case {some:user}: {
	      	UserContext.change(function(_){~{user}},state)
	      	Client.goto("/")
	  	}}
	}

	function logout(_){
		UserContext.remove(state)
		Client.reload()
	}

	function logged() {
		match(UserContext.get(state)){
		case {unlogged}: {false}
		case {user:_}  : {true}
		}
	}

	function get_user() {
		match(UserContext.get(state)){
		case {unlogged}: "anonymous"
		case ~{user}:    user.username
		}
	}

	/* Auxiliary function for processing JSON data obtained from Facebook Graph
    API. Gets an [obj]ect and tries to extract field named [field] */
	function extract_field(obj, field) {
	  match (List.assoc(field, obj.data)) {
	    case {some: {String: v}}: some(v)
	    default: none
	  }
	}

	 /* Returns the name of the currently authenticated Facebook user */
	function get_name(token) {
	  opts = { FBG.Read.default_object with token:token.token }
	  match (FBG.Read.object("me", opts)) {
	  case {~object}: extract_field(object, "name")
	  default: none
	  }
	}

	function connect(data) {
		match (FBA.get_token_raw(data, redirect)) {
			case {~token}: {
				match(get_name(token)) {
		    		case {some: name}: {
						user = {username: name, password: ""}
						UserContext.change(function(_){~{user}}, state)
						View.main()	
  					}
		    		default: Resource.html("Error", <><h1>Error getting your name</h1></>);
		    	}
			}			
			case ~{error}: Resource.html("Error", <><h1>{error.error} {error.error_description}</h1></>)
			default: Resource.html("Error",<><h1>Unknown Error</h1></>)
		}		 
	}
}
