import stdlib.themes.bootstrap
import stdlib.web.client
import stdlib.tools.markdown

module View {
	function navbar() { 
		<>{Login.login_form()} 
		<div id=#title class="navbar navbar-fixed-top">
      		<div class=navbar-inner> 
      			<div class="container-fluid">
      				<a href="/" class="brand hidden-phone hidden-tablet">
      					<img alt="Opa" src="/resources/img/opa-logo.png" class="logo">
      				</a>
      				<div id=#login_panel class="pull-right">
      				{if(Login.logged()){
      					<span> welcom {Login.get_user()}</span> 
      					<button id=#btn_logout class="btn btn-success" onclick={Login.logout}>Logout</button>
      				}else{
      					<button id=#btn_login class="btn btn-success" onclick={Login.show_login}>Login</button>	
      				}}      					
      				</div>
      			</div>
      		</div>
    	</div>
    	</>
	}

	function topic_list(){
		row = 0;
		Iter.map(function(t){
			row   = row + 1;
			style = if(mod(row,2) == 0) "index-subscribed" else "index-unsubscribed"

			<tr class="{style}">
		    	<td align="left">
		    		<span class="icon icon-bookmark"></span>
		    		<a href="/detail/{t.id}">{t.title}</a>
		    	</td>
		    	<td align="center">2</td>
		    	<td align="center">{t.author}</td>
		    	<td align="center">{time_diff(t.lastupdate)}</td>
		    </tr>
		},Model.query(0))
	}

	function main(){
		xhtml = <>
			{navbar()}
	    	<div class="container-fluid">
	    		<div id=#content>
	    			<div class="section-block section-block-inner">
	    				<div>
	    					<h1 class="pull-left">Lastest Discussions</h1>
	    					{if(Login.logged()){
	    						<div class="pull-right" style="margin:10px 0px">
	    							<a href="/new_topic"><i class="icon icon-plus"/> New Topic</a>
	    						</div>	
	    					}else <></>}   					
	    				</div>
		    			<table class="table table-striped pointer">
		    				<thead>
		    					<tr>
		    						<th align="left">Topic</th>
		    						<th align="center">Reply</th>
		    						<th align="center">Last Poster</th>
		    						<th align="center">Last Update</th>
		    					</tr>
		    				</thead>
		    				<tbody id=#topic_list>{topic_list()}</tbody>
		    			</table>
	    			</div>
	    		</div>
	    	</div>
	    </>
	    Resource.html("Live Room", xhtml)
	}

	function add_topic(_){
		message = {
			author: "winbomb",
			content: Dom.get_value(#new_topic_content),
			posttime: get_now(),
			comments: []
		}
		topic = {
			id: -1,
			posttime: get_now(),
			lastupdate: get_now(),
			title: Dom.get_value(#new_topic_text),
			author: "winbomb",
			messages: StringMap.add("0", message, StringMap.empty)
		}

		Model.insert(topic)
		Client.goto("/")
	}

	function new_topic() {
		xhtml = <>
			{navbar()}
			<div class="container-fluid">
    			<div id=#content>
    				<div class="section-block section-block-inner">
    					<fieldset>
    						<legend>New Topic</legend>
    						<div class="control-group">
    							<label>Title</label>
    							<input id=#new_topic_text type="text" style="width:40%; min-width:240px"/>
    							<label>Message</label>
    							<textarea id=#new_topic_content class="markdown-content" width="98%" rows="11" placeholder="Enter your message here..."></textarea>
    						</div>
    						<div class="actions">
    							<button class="btn btn-primary" onclick={add_topic}>Create</button>
    							<button class="btn btn-primary" onclick={preview}>Preview</button>
    							<button class="btn btn-primary">Cancle</button>
    						</div>
    						<div id=#preview_area class="preview" style="display:none"></div>
    					</fieldset>
    				</div>
    			</div>
    		</div>
    	</>
    	Resource.html("Live Room", xhtml)
	}

	client function preview(_) {
		#preview_area = Markdown.xhtml_of_string(Markdown.default_options, Dom.get_value(#new_topic_content))
		Dom.show(#preview_area)
	}

	function post_message(id)(_) {
		message = {
			author: "tester",
			content: Dom.get_value(#new_message_content),
			posttime: 0,
			comments: []
		}
		Model.post_message(id,message)
	}

	function post_comment(id, key)(_) {
		comment = {
			author: "texter",
			content: Dom.get_value(#new_message_content),
			posttime: 0
		}
		Model.post_comment(id, key, comment)
	}

	function hide_comment_box(key)(_){
		Dom.remove_content(#{"add_new_comment_{key}"})
	}

	function show_comment_box(id, key)(_){
		xhtml = <>
			<div class="section-block">
    			<label>New message</label>
    			<div class="row-fluid markdown-wrapper">
    				<textarea id=#new_message_content class="markdown-content" rows="11" placeholder="Enter your message here..."></textarea>
    			</div>
    			<div class="actions">
    				<button class="btn btn-info" onclick={hide_comment_box(key)}>Cancel</button>
    				<button class="btn btn-info" onclick={post_comment(id,key)}>Post</button>
    			</div>
    		</div>
    	</>

    	#{"add_new_comment_{key}"} = xhtml
    	Dom.show(#{"add_new_comment_{key}"})
	}

	client function show_messages(id, messages)(_){
		logged = Login.logged()
		Map.iter(function(key,msg){
    		message = <li class="section-block message">
    			<div class="base-wrapper">
    				<div class="author">{msg.author}</div>
    				<div class="postdate">Posted {time_diff(msg.posttime)}</div>
    				<div class="base-content">{Markdown.xhtml_of_string(Markdown.default_options, msg.content)}</div>
    			</div>
    			<div class="message_comments">
    				{if(not(List.is_empty(msg.comments))){
	    				<div class="caret-divider">
	    					<div class="caret-outer"></div>
	    					<div class="caret-inner"></div>
	    				</div>
    				}else <></>}    				
    				<ul id="comment_list_{key}" class="unstyled comments">
    					{List.map(function(comment){
    						<li class="comment">
    							<div class="base-wrapper">
    								<div class="author">{comment.author}</div>
    								<div class="postdate">{time_diff(comment.posttime)}</div>
    								<div class="base-content">{Markdown.xhtml_of_string(Markdown.default_options, comment.content)}</div>
    							</div>
    						</li>
    					},msg.comments)}
    				</ul>
    				{if(logged){
    					<div class="add_new_comment" onclick={show_comment_box(id, key)}>
    						<i class="icon icon-comment"></i>Add a comment...
    					</div>
    					<div id="add_new_comment_{key}" class="add_new_comment_box" style="display:none"></div>	
    				}else <></>}    				
    			</div>
    		</li>
    		#messagelist =+ message
    	}, messages)
	}

	function detail(id) {
		topic = Model.get(id)
		xhtml = <>
			{navbar()}
			<div class="container-fluid">
    			<div id=#content>
    				<div class="page-header section-block">
    					<h2>{topic.title}</h2>
    				</div>
    				<ul class="unstyled messages" id=#messagelist onready={show_messages(id, topic.messages)}></ul>
    				{if(Login.logged()){
    					<div class="section-block">
    						<label>New message</label>
    						<div class="row-fluid markdown-wrapper">
    							<textarea id=#new_message_content class="markdown-content" rows="11" placeholder="Enter your message here..."></textarea>
    						</div>
    						<div class="actions">
    							<a href="#" onclick={post_message(id)} class="btn btn-info">Post</a>
    						</div>
    					</div>	
    				}else <></>}    				
    			</div>
    		</div>
		</>
		Resource.html("Live Room", xhtml)
	}
}