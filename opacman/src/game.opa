import stdlib.web.canvas

type Dir.t = {UP} or {DOWN} or {LEFT} or {RIGHT}
type Game.state = {GAME_START} or {STARTING} or {RUNNING} or {PAUSE} or {GAME_OVER} or {GAME_RESET}
type Game.t = {
	Game.state 		state,
	Pacman.t		pacman,
	list(Ghost.t)	ghosts,
	int		   		score,
	int 			lives,
	int 			combo,
	llarray(llarray(int)) grids
}

/** a shortcut for LowLevelArray, LowLevelArray is just too long to type */
Array = LowLevelArray

client module Game {
	play    = %%Preloader.play%%
	play_cb = %%Preloader.play_cb%%

	GRID = [
  		[1,1,1,1,1,1,1,1,1,1,1,1,8,8,1,1,1,1,1,1,1,1,1,1,1,1],
  		[2,8,8,8,8,1,8,8,8,8,8,1,8,8,1,8,8,8,8,8,1,8,8,8,8,2],
  		[1,8,8,8,8,1,8,8,8,8,8,1,8,8,1,8,8,8,8,8,1,8,8,8,8,1],
  		[1,8,8,8,8,1,8,8,8,8,8,1,8,8,1,8,8,8,8,8,1,8,8,8,8,1],
  		[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
		[1,8,8,8,8,1,8,8,1,8,8,8,8,8,8,8,8,1,8,8,1,8,8,8,8,1],
		[1,8,8,8,8,1,8,8,1,8,8,8,8,8,8,8,8,1,8,8,1,8,8,8,8,1],
		[1,1,1,1,1,1,8,8,1,1,1,1,8,8,1,1,1,1,8,8,1,1,1,1,1,1],
		[8,8,8,8,8,1,8,8,8,8,8,0,8,8,0,8,8,8,8,8,1,8,8,8,8,8],
		[8,8,8,8,8,1,8,8,8,8,8,0,8,8,0,8,8,8,8,8,1,8,8,8,8,8],
		[8,8,8,8,8,1,8,8,0,0,0,0,0,0,0,0,0,0,8,8,1,8,8,8,8,8],
		[8,8,8,8,8,1,8,8,0,8,8,8,4,4,8,8,8,0,8,8,1,8,8,8,8,8],
		[8,8,8,8,8,1,8,8,0,8,8,8,0,0,8,8,8,0,8,8,1,8,8,8,8,8],
		[5,0,0,0,0,1,0,0,0,8,8,8,0,0,8,8,8,0,0,0,1,0,0,0,0,5],
		[8,8,8,8,8,1,8,8,0,8,8,8,8,8,8,8,8,0,8,8,1,8,8,8,8,8],
		[8,8,8,8,8,1,8,8,0,8,8,8,8,8,8,8,8,0,8,8,1,8,8,8,8,8],
		[8,8,8,8,8,1,8,8,0,0,0,0,0,0,0,0,0,0,8,8,1,8,8,8,8,8],
		[8,8,8,8,8,1,8,8,0,8,8,8,8,8,8,8,8,0,8,8,1,8,8,8,8,8],
		[8,8,8,8,8,1,8,8,0,8,8,8,8,8,8,8,8,0,8,8,1,8,8,8,8,8],
		[1,1,1,1,1,1,1,1,1,1,1,1,8,8,1,1,1,1,1,1,1,1,1,1,1,1],
		[1,8,8,8,8,1,8,8,8,8,8,1,8,8,1,8,8,8,8,8,1,8,8,8,8,1],
		[2,8,8,8,8,1,8,8,8,8,8,1,8,8,1,8,8,8,8,8,1,8,8,8,8,2],
		[1,1,1,8,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,8,1,1,1],
		[8,8,1,8,8,1,8,8,1,8,8,8,8,8,8,8,8,1,8,8,1,8,8,1,8,8],
		[8,8,1,8,8,1,8,8,1,8,8,8,8,8,8,8,8,1,8,8,1,8,8,1,8,8],
		[1,1,1,1,1,1,8,8,1,1,1,1,8,8,1,1,1,1,8,8,1,1,1,1,1,1],
		[1,8,8,8,8,8,8,8,8,8,8,1,8,8,1,8,8,8,8,8,8,8,8,8,8,1],
		[1,8,8,8,8,8,8,8,8,8,8,1,8,8,1,8,8,8,8,8,8,8,8,8,8,1],
		[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],]

	/**
	 * Map GRID to a value of type llarray(llarray(int))
	 * Cause we will need to access the value of GRID by index frequently, 
	 * LowLevelArray may be faster (I guess!).
	 */
	function init_grids(){
		Array.of_list_mapi(GRID)(function(_, row){ Array.of_list(row) })
	}

	function get_grid(grids, i, j){
		if(i <= -1 || j <= -1 || i >= 26 || j >= 29) -1 else {
			Array.get(Array.get(grids, j), i)
		}
	}

	function set_grid(grids, i, j, val){
		Array.mapi(grids)(function(n, row){
			if(n == j) Array.set(row, i, val)
			row
		})
	}

	Game.t default_game = {
		state: {GAME_START},
		pacman:	Pacman.init(),
		ghosts: Ghost.create(),
		score: 0,
		combo: 0,
		lives: 3,
		grids: init_grids()
	}
	game = Mutable.make(default_game)

	/**
	 * Test if the destination direction is blocked
	 */
	function is_blocked(grids, i, j, dir, is_ghost, is_ready){
		pos = match(dir){
		case {UP}   : (i,j-1)
		case {DOWN} : (i,j+1)
		case {LEFT} : (i-1,j)
		case {RIGHT}: (i+1,j)
		}
		
		data = get_grid(grids,pos.f1,pos.f2)
		if(data == 8 || data == -1){ {true} }else{
			if((data == 4 && not(is_ghost)) || (data == 4 && not(is_ready))){ {true} }else{
				if((data == 5 && is_ghost)  || (data == 4 && not(is_ghost))){ {true} }else{ {false} }
			}
		}
	}

	function are_blocked(grids, r, c, ghost){
		is_ready = ghost.ready <= 0
		blocked_up    = is_blocked(grids,r,c,{UP}   ,{true},is_ready) || (ghost.face == {DOWN}  && not(ghost.chase))
		blocked_right = is_blocked(grids,r,c,{RIGHT},{true},is_ready) || (ghost.face == {LEFT}  && not(ghost.chase))
		blocked_down  = is_blocked(grids,r,c,{DOWN} ,{true},is_ready) || (ghost.face == {UP}    && not(ghost.chase))
		blocked_left  = is_blocked(grids,r,c,{LEFT} ,{true},is_ready) || (ghost.face == {RIGHT} && not(ghost.chase))
		(blocked_up,blocked_right,blocked_down,blocked_left)
	}


	function pacman_dir(ghost, pacman){
		dx = pacman.x - ghost.x
		dy = pacman.y - ghost.y
		if(dx >= 0 && dy <= 0) 1 else {
			if(dx >= 0 && dy >= 0) 2 else{
				if(dx <= 0 && dy >= 0) 3 else 4
			}
		}
	}

	/**
	 * choose a direction to go for ghost, the decission is based on the direction
	 * of pacman relative to the ghost.
	 */
	function choose_dir(ghost,pacman,grids){
		function choose(b1,b2,d1,d2){
			if(not(b1) && not(b2)){
				if(mod(Random.int(100),2) == 0) some(d1) else some(d2)
			}else{
				if(not(b1)) some(d1) else {
					if(not(b2)) some(d2) else {none}
				}
			}
		}

		r = ghost.x / 18
		c = ghost.y / 18
		pacmandir = pacman_dir(ghost,pacman)
		blocks = are_blocked(grids,r,c,ghost)
		bestdir = if(pacman.eaten <= 0){
			match(pacmandir){
			case 1: choose(blocks.f1,blocks.f2,{UP},{RIGHT})
			case 2: choose(blocks.f2,blocks.f3,{RIGHT},{DOWN})
			case 3: choose(blocks.f3,blocks.f4,{DOWN},{LEFT})
			case 4: choose(blocks.f4,blocks.f1,{LEFT},{UP})
			case _: {none}
			}
		}else{
			match(pacmandir){
			case 1: choose(blocks.f3,blocks.f4,{DOWN},{LEFT})
			case 2: choose(blocks.f4,blocks.f1,{LEFT},{UP})
			case 3: choose(blocks.f1,blocks.f2,{UP},{RIGHT})
			case 4: choose(blocks.f2,blocks.f3,{RIGHT},{DOWN})
			case _: {none}
			}
		}

		match(bestdir){
		  case ~{some}: some
		  case  {none}: random_dir(blocks)
		}
	}

	/** 
	 * choose a random direction to go.
	 */
	function random_dir(blocks){
		if(not(blocks.f1)) { {UP} }else{
			if(not(blocks.f2)) { {RIGHT} }else{
				if(not(blocks.f3)) { {DOWN} }else{ {LEFT} }
			}
		}
	}

	/**
	 * reset the game
	 */
	function reset(g){
		ghosts = List.map(function(ghost){
			match(ghost.id){
			case 0: {ghost with x:  90, y:  72, chase: {false}, face:{LEFT},  ready: 0}
			case 1: {ghost with x: 360, y:  72, chase: {false}, face:{RIGHT}, ready: 0}
			case 2: {ghost with x: 234, y: 234, chase: {false}, face:{UP},    ready: 100}
			case _: {ghost with x: 234, y: 234, chase: {false}, face:{UP},    ready: 100}
			}
			
		},g.ghosts)
		pacman = {g.pacman with x: 234, y:396, eaten: 0}
		{g with ~ghosts,~pacman,state:{RUNNING}}
	}

	/**
	 * update game. For example: update pacman's postion, ghost's postion.
	 */
	function update(g){
		//update pacman
		pacman = g.pacman
		i = pacman.x / 18; //row number on the grid 
		j = pacman.y / 18; //col number on the grid	
		
		//Keep still if there is wall on the direction of pacman, or else walk.
		g = if((mod(pacman.x,18) != 0 || mod(pacman.y,18) != 0)) {
			{g with pacman: Pacman.move(g.pacman)}
		}else{
			g = match(get_grid(g.grids,i,j)){
			case 1: {
				play("SND_EAT")
				grids = set_grid(g.grids, i, j, 0)
				score = g.score + 10 
				{g with ~grids, ~score}
			}
			case 2: {
				grids  = set_grid(g.grids, i, j, 0)
				score  = g.score + 50
				pacman = {pacman with eaten: 500}
				ghosts = List.map(function(ghost){{ghost with chase: {true}}},g.ghosts)
				{g with ~grids, ~score, ~pacman, ~ghosts} 
			}
			case 5: {
				pacman = if(pacman.x == 0){ {pacman with x: 432, face:{LEFT}} }else{ {pacman with x:18, face:{RIGHT}}}
				{g with ~pacman}
			}
			case _: g
			}

			pacman  = g.pacman
			blocked = is_blocked(g.grids,i,j,pacman.next_dir,{false},{true})
			if(not(blocked)){
				pacman = {pacman with face: pacman.next_dir}
				{g with pacman: Pacman.move(pacman)}
			}else{
				blocked = is_blocked(g.grids,i,j,pacman.face,{false},{true})
				if(not(blocked)) {g with pacman: Pacman.move(pacman)} else {g with ~pacman}
			}
		}
		g = {g with pacman: Pacman.update(g.pacman)}
		
		//update ghosts
		ghosts = List.map(function(ghost){
			if((mod(ghost.x,18) == 0) && (mod(ghost.y,18) == 0)){
				next_dir = choose_dir(ghost,pacman,g.grids)
				{ghost with face:next_dir} |> Ghost.move(_) |> Ghost.update(_)
			}else{
				ghost |> Ghost.move(_) |> Ghost.update(_)
			}
		},g.ghosts)
		
		if(g.pacman.eaten >= 1) { {g with ~ghosts} } else {
			ghosts = List.map(function(ghost){{ghost with chase: {false}}},ghosts)
			{g with ~ghosts}
		}
	}

	/**
	 * tick is meant to be invoked every 16 milliseconds, we update the game on every tick.
	 */
	function tick(ctx)(){
		g = game.get();
		Render.draw_board(g,ctx);

		g = match(g.state){
		case {RUNNING}:{
			g = update(g)
			pacman = g.pacman
			List.fold(function(ghost,g){
				if(g.state != {RUNNING}) g else {
					//if pacman collides with ghosts
					if(Math.square_i(ghost.x - pacman.x) + Math.square_i(ghost.y - pacman.y) <= 144){
						if(pacman.eaten <= 0){
							play_cb("SND_DIE", function(){
								g = {g with lives: g.lives - 1}
								if(g.lives <= 0) game.set({g with state: {GAME_OVER}}) else game.set({g with state:{GAME_RESET}})
							})
							{g with state: {PAUSE}}						
						}else{
							ghosts = List.map(function(ghost2){
								if(ghost2.id != ghost.id) ghost2 else{
									{ghost2 with x:234, y: 234, chase: {false}, ready: 200}
								}
							},g.ghosts)
							{g with ~ghosts,score:g.score+1000}
						}
					}else g
				}
			},g.ghosts,g)
		}
		case {GAME_RESET}: reset(g)
		default: g
		}
		game.set(g)
	}

	/**
	 * bind key press event
	 */
	function keyfun(event){
		g = game.get();
		if(g.state == {RUNNING}){
			p = g.pacman
			keycode = event.key_code ? -1
			p = match(keycode){
			  case 38: {p with next_dir: {UP}}
			  case 40: {p with next_dir: {DOWN}}
			  case 37: {p with next_dir: {LEFT}}
			  case 39: {p with next_dir: {RIGHT}}
			  case _ : p
			}
			game.set({g with pacman:p})		
		}
	}

	/** 
	 * start the game
	 */
	function gamestart(_){
		match(get_context(#gamecanvas)){
		case {none}: void
		case {some:ctx}: {
			%%Preloader.preload%%(function(){
				timer = Scheduler.make_timer(16, tick(ctx))
				_ = Dom.bind_with_options(Dom.select_document(), {keydown}, keyfun, [{prevent_default}])
				timer.start()
				play_cb("SND_START", function(){
					game.set({game.get() with state: {RUNNING}})	
				})				
			})
		}}
	}

}

/** get canvas context */
function get_context(id){
	match(Canvas.get(id)){
	case  {none}: {none}
	case ~{some}: Canvas.get_context_2d(some)
	}
}

/** the main page */
function page(){
	<canvas id=#gamecanvas width="520" height="620" onready={Game.gamestart}>
		Your browser does not support canvas element.
	</canvas>
}

Server.start(Server.http, [
	{resources: @static_resource_directory("resources")},
	{register: [
		{doctype: {html5}},
		{css:["/resources/css/style.css"]},
		{js: ["/resources/js/preloadjs.min.js","/resources/js/soundjs.min.js"]}
	]},
	{title:"Opacman", ~page}
])
