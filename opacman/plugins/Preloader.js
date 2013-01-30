/**
 * This function preloads all resources we need in the game, callback will be invoked when loading is finished.
 * 
 * @register {( -> void) -> void}
 */
function preload(callback) {
	queue = new createjs.LoadQueue();
 	queue.installPlugin(createjs.Sound);
 	queue.addEventListener("complete", callback);
 	queue.loadManifest([
     	{id: "IMG_BG",    src:"resources/img/bg.png"},
     	{id: "IMG_GHOST", src:"resources/img/ghost.png"},
     	{id: "SND_START", src:"resources/sound/start.mp3"},
     	{id: "SND_EAT",   src:"resources/sound/eat.mp3"},
     	{id: "SND_DIE",   src:"resources/sound/die.mp3"}
 	]);
}

/** @externType Image.image */

/**
 * This will return a value of type Image.image for a given key.
 *
 * @register {string -> Image.image}
 */
function get(key) {
	return queue.getResult(key);
}

/**
 * This function will play a sound for a given sound id.
 * 
 * @register {string -> void}
 */
function play(sid) {
	var mySound = createjs.Sound.play(sid);
	mySound.play();
}

/**
 * This function will play a sound for a given sound id, and will invoke oncomplete will finish.
 *
 * @register {string, ( -> void) -> void}
 */
function play_cb(sid, oncomplete){
	var mySound = createjs.Sound.play(sid);
	mySound.addEventListener("complete", oncomplete);
	mySound.play();
}
