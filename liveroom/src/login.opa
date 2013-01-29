import stdlib.apis.{facebook, facebook.auth}

type Login.user = {unlogged} or {string user}

module Login {
	config = {
		app_id:  "121883501319223",
		api_key: "121883501319223",
		app_secret: "fd23bd0b580af141cf76f428e0e01222"
	}
	
	FBA 	  = FbAuth(config)
 	login_url = FBA.user_login_url([], redirect)
 	redirect  = "http://localhost:8080/connect"

 	state = UserContext.make(Login.user {unlogged})

	function login_form() {
		<div id=#login_form class="login-form">
			<h1><span class="log-in">Log in</span></h1>
			<p class="float">
				<label for="login"><i class="icon-user"></i>Username</label>
				<input id=#username type="text" name="login" placeholder="Username or email"/>
			</p>
			<p class="float">
				<label for="password"><i class="icon-lock"></i>Password</label>
				<input id=#password type="password" name="password" placeholder="Password" class="showpassword"/>
			</p><p class="opt"><input type="checkbox" class="showpasswordcheckbox" id="showPassword"><label for="showPassword">Show password</label></p>
			<p class="clearfix"> 
				<a href="#" class="log-facebook">Log in with Facebook</a>    
				<input type="submit" name="submit" value="Log in" onclick={login}/>
			</p>
		</div>
	}

	function show_login(_){ Dom.show(#login_form) }

	function login(_) {
		if(Dom.get_value(#password) == "admin"){
			user = Dom.get_value(#username)
			UserContext.change(function(_){~{user}},state)
			Dom.hide(#login_form)

			#login_panel = <span>Welcome {user}</span>
		}else{
			void
		}
	}

	function logout(_){
		UserContext.change(function(_){{unlogged}},state)
	}

	function logged() {
		match(UserContext.execute(identity,state)){
		case {unlogged}: {false}
		case {user:_}  : {true}
		}
	}

	function get_user() {
		match(UserContext.execute(identity,state)){
		case {unlogged}: "anonymous"
		case ~{user}: user
		}
	}
}