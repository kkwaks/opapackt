type Ghost.t = {
	int id,
	int x,
	int y,
	int style,
	int ready,
	int frame,
	Dir.t face,
	bool chase,
}

client module Ghost {
	function create(){
		[{id:0, x: 90,y: 72,style:0,face:{LEFT},  chase: {false}, frame:0, ready:0},
		 {id:1, x:360,y: 72,style:1,face:{RIGHT}, chase: {false}, frame:0, ready:0},
		 {id:2, x:234,y:234,style:2,face:{UP},    chase: {false}, frame:0, ready:100},
		 {id:3, x:234,y:234,style:3,face:{DOWN},  chase: {false}, frame:0, ready:100}
		]
	}

	function move(ghost){
		speed = if(ghost.chase) 1 else 2
		match(ghost.face){
			case {UP}   : {ghost with y: (ghost.y - speed)}
			case {DOWN} : {ghost with y: (ghost.y + speed)}
			case {LEFT} : {ghost with x: (ghost.x - speed)}
			case {RIGHT}: {ghost with x: (ghost.x + speed)}
		}
	}

	function update(ghost){
		ghost = if(ghost.ready <= 0) ghost else {
			{ghost with ready: ghost.ready - 1}
		}
		{ghost with frame: mod(ghost.frame + 1,10)}
	}
}
