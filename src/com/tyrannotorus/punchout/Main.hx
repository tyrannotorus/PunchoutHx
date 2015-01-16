package com.tyrannotorus.punchout;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.StageDisplayState;
import openfl.events.Event;
import openfl.Lib;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

class Main extends Sprite {

	// Game Dimensions
	private var GAME_WIDTH:Int = 256;
	private var GAME_HEIGHT:Int = 224;
	private var stageWidth (get, null):Int;
	private var stageHeight (get, null):Int;
	
	private var container:Sprite;
	private var menu:Menu;
	private var ring:Ring;
	private var player:Player;
	private var opponent:Opponent;
	private var healthBars:HealthBars;
	
	// Music and sfx
	private var music:Sound;
	private var musicChannel:SoundChannel;
	private var musicTransform:SoundTransform;
	
	public function new() {
		
		container = new Sprite();
		
		ring = new Ring();
		ring.loadRing("img/ring-01.png");
		container.addChild(ring);
		
		player = new Player();
		opponent = new Opponent();
		healthBars = new HealthBars();
		
		super();
		addChild(container);
				
		musicTransform = new SoundTransform(0.1);
		music = Assets.getSound("audio/title_music.mp3", true);
		musicChannel = music.play();
		musicChannel.soundTransform = musicTransform;
		
		addGameListeners();
	}
	
	private function addGameListeners():Void {
		stage.addEventListener(Event.RESIZE, onGameResize);
	}
	
	/**
	 * Returns width of stage in windowed or fullscreen
	 * @return {Int}
	 */
	private function get_stageWidth():Int {
		return (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) ? stage.fullScreenWidth : stage.stageWidth;
	}
	
	/**
	 * Returns height of stage in windowed or fullscreen
	 * @return {Int}
	 */
	private function get_stageHeight():Int {
		return (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) ? stage.fullScreenHeight : stage.stageHeight;
	}
	
	/**
	 * Called automatically on resize of the swf. Scales and positions the game container
	 * @param {Event.RESIZE} e
	 */
	private function onGameResize(e:Event):Void {
		
		var scale:Float = 1;
				
		// Find which dimension to scale by
		if (GAME_WIDTH / stageWidth > GAME_HEIGHT / stageHeight) {
			scale = stageWidth / GAME_WIDTH;		
		} else {
			scale = stage.stageHeight / GAME_HEIGHT;
		}
					
		container.scaleX = container.scaleY = scale;
		container.x = Std.int((stageWidth - (GAME_WIDTH * scale)) * 0.5);
		container.y = Std.int((stageHeight - (GAME_HEIGHT * scale)) * 0.5);
	}
	
	
	
	
}
