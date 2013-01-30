type Pacman.t = {
	int x,
	int y,
	Dir.t face,
	Dir.t next_dir,
	int eaten,
	int frame
}
client module Pacman {

	function init(){
		{x:234, y: 396, face: {LEFT}, next_dir: {LEFT}, eaten: 0, frame: 0}
	}

	function move(pacman){
		match(pacman.face){
		case {UP}   : {pacman with y: pacman.y - 2}
		case {DOWN} : {pacman with y: pacman.y + 2}
		case {LEFT} : {pacman with x: pacman.x - 2}
		case {RIGHT}: {pacman with x: pacman.x + 2}
		}
	}

	function update(pacman){
		if(pacman.eaten <= 0){
			{pacman with eaten:0, frame: mod(pacman.frame+1,10)}
		}else{
			{pacman with eaten: pacman.eaten - 1, frame: mod(pacman.frame+1,10) }
		}
	}
}
