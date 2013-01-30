/**
 * This module is for drawing on the canvas.
 */
 
client module Render {
	SQRT2     = 1.4142135623730950488016887242097;
	tick      = Mutable.make(int 0);   		//last tick
	elapse    = Mutable.make(int 0); 		//elaspe time since last action
	radius    = Mutable.make(int 0)

	function IMAGE(key){ 
		{image: %%Preloader.get%%(key)}
	}

	function draw_board(g,ctx){
		//update time
		now = Date.in_milliseconds(Date.now())
		delta = now - tick.get()
		tick.set(now)
		elapse.set(elapse.get() + delta)

		if(elapse.get() >= 100){
			elapse.set(0);
			radius.set(mod(radius.get() + 1, 7))
		}

		//clear background
		Canvas.clear_rect(ctx,0,0,520,620)
		Canvas.draw_image(ctx,IMAGE("IMG_BG"),0,0)
		
		//draw board
		Array.iteri(function(j,row){
			Array.iteri(function(i,item){
				match(item){
				case 1: draw_food(ctx,i,j)
				case 2: draw_bean(ctx,i,j,radius.get())
				case _: void
				}
			},row)
		},g.grids)

		//draw ghosts
		List.iter(function(ghost){
			draw_ghost(ctx,ghost)
		},g.ghosts);
		
		//draw pacman
		draw_pacman(ctx,g.pacman)

		//draw game info
		draw_score(ctx,g.score)
		draw_lives(ctx,g.lives)

		Canvas.set_font(ctx,"italic bold 24px verdana")
		Canvas.set_fill_style(ctx,{color: Color.white})
		match(g.state){
		  case {GAME_START}: Canvas.fill_text(ctx,"READY", 215, 335); 
		  case {GAME_OVER}:  Canvas.fill_text(ctx,"GAME OVER", 180, 335);
		  case _: void
		}
	}

	function draw_score(ctx, score){
		Canvas.save(ctx)
		Canvas.set_fill_style(ctx,{color:Color.white})
		Canvas.set_font(ctx,"36px bold impact")
		Canvas.fill_text(ctx,"{score}",120,610)
		Canvas.restore(ctx)
	}
	
	function draw_lives(ctx,lives){
		if(lives >= 1) fill_pacman(ctx, 400, 595, {RIGHT}, {true})
		if(lives >= 2) fill_pacman(ctx, 440, 595, {RIGHT}, {true})
		if(lives >= 3) fill_pacman(ctx, 480, 595, {RIGHT}, {true})
	}
	
	function draw_pacman(ctx,pacman){
		fill_pacman(ctx,pacman.x + 32, pacman.y + 32, pacman.face, pacman.frame < 4);
	}

	function fill_pacman(ctx, x, y, face, open){
		Canvas.save(ctx)
		Canvas.set_stroke_style(ctx,{color:Color.white})
		Canvas.set_fill_style(ctx,{color:Color.yellow})
		Canvas.begin_path(ctx)
		Canvas.move_to(ctx,x,y)
		if(not(open)){
			Canvas.arc(ctx,x,y,10,0.0, 2.0*Math.PI, {false})
		}else{
			match(face){
			case {UP}   : Canvas.arc(ctx,x,y,10,7.0*Math.PI/4.0,5.0*Math.PI/4.0,{false})
			case {DOWN} : Canvas.arc(ctx,x,y,10,3.0*Math.PI/4.0,1.0*Math.PI/4.0,{false})
			case {LEFT} : Canvas.arc(ctx,x,y,10,5.0*Math.PI/4.0,3.0*Math.PI/4.0,{false})
			case {RIGHT}: Canvas.arc(ctx,x,y,10,1.0*Math.PI/4.0,7.0*Math.PI/4.0,{false})
			}
		}
		Canvas.close_path(ctx)
		Canvas.fill(ctx)
		Canvas.stroke(ctx)
		Canvas.restore(ctx)
	}
	
	function draw_food(ctx,i,j){
		Canvas.save(ctx)
		Canvas.set_fill_style(ctx,{color:Color.white})
		Canvas.fill_rect(ctx, 30 + i*18, 30 + j*18, 4, 4)
		Canvas.restore(ctx)
	}

	function draw_bean(ctx,i,j,r){
		Canvas.save(ctx)
		Canvas.set_fill_style(ctx,{color:Color.white})
		Canvas.begin_path(ctx)
		Canvas.arc(ctx,32 + i*18, 30 + j*18,r,0.0,Math.PI*2.0,{false})
		Canvas.close_path(ctx)
		Canvas.fill(ctx)
		Canvas.restore(ctx)
	}

	function draw_ghost(ctx,ghost){
		function draw(style,frame,x,y){
			Canvas.draw_image_full(ctx,IMAGE("IMG_GHOST"),(frame/5)*25,style*25,25,25,x,y,25,25)
		}

		Canvas.save(ctx)
		match(ghost.chase){
		case  {true}: draw(4,ghost.frame,ghost.x + 20,ghost.y + 20)
		case {false}: draw(ghost.style,ghost.frame,ghost.x + 20,ghost.y + 20)
		}
		Canvas.fill(ctx)
		Canvas.restore(ctx)
	}
}
