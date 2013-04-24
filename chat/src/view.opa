module View {
	function broadcast(user)(_){
		text = Dom.get_value(#entry);
    	Model.broadcast(~{user, text});
    	Dom.clear_value(#entry);
	}

	function updatemsg(msg){
		line = <div class="row-fluid line">
             <div class="span1 userpic" />
             <div class="span2 user">{msg.user}:</>
             <div class="span9 message">{msg.text}</>
           </div>;
    	#conversation =+ line;
    	Dom.scroll_to_bottom(#conversation);
	}

	function page(){
		user = Random.string(8)

		<div id=#title class="navbar navbar-inverse navbar-fixed-top">
      		<div class=navbar-inner> 
      			<div id=#logo /> 
      		</div>
    	</div>
   		<div id=#conversation class=container-fluid onready={function(_){Model.join(updatemsg)}} />
    	<div id=#footer class="navbar navbar-fixed-bottom">
			<div class=input-append>
        		<input type=text id=#entry class=input-xxlarge  onnewline={broadcast(user)}/>
        		<button class="btn btn-primary" onclick={broadcast(user)}>Post</button>
			</div>
    	</div>
	}
}
