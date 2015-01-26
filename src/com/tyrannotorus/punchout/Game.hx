package com.tyrannotorus.punchout;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.StageDisplayState;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

class Game extends Sprite {
		
	private var screen:Sprite;
	private var ring:Ring;
	private var player:Actor;
	private var opponent:Actor;
	private var healthBars:HealthBars;
	private var menu:Menu;
	
	// Keyboard Controls
	private var zKey:Bool = false;
	private var xKey:Bool = false;
	private var cKey:Bool = false;
	private var upKey:Bool = false;
	private var downKey:Bool = false;
	private var leftKey:Bool = false;
	private var rightKey:Bool = false;
		
	// Fonts and text typing
	public var textManager:TextManager;
	
	private var externalAssetLoader:ExternalAssetLoader;
	
	// Music and sfx
	private var music:Sound;
	private var musicChannel:SoundChannel;
	private var musicTransform:SoundTransform;
	
	public function new() {
		
		super();
		
		screen = new Sprite();
		
		// Add Mike Tyson Welcome Screen
		var intro:Bitmap = new Bitmap();
		intro.bitmapData = Assets.getBitmapData("img/intro.png");
		screen.addChild(intro);
		addChild(screen);
		
		ring = new Ring();
		addChild(ring);
		
		// Create Little Mac
		var macSpritesheet:BitmapData = Assets.getBitmapData("actors/mac_spritesheet.png");
		var macLogic:String = Assets.getText("actors/mac_logic.txt");
		var macData:Dynamic = Utils.parseCharacterData(macSpritesheet, macLogic);
		player = new Actor(macData);
		
		healthBars = new HealthBars();
		textManager = new TextManager();
		menu = new Menu(this);
		addChild(menu);
		
		var testText:Dynamic = { };
		testText.text = "Mike Tysons\nPunch\nout!!";
		testText.fontColor1 = 0xFFFFFFFF;
		testText.fontSet = 4;
		addChild(textManager.typeText(testText));
		
		externalAssetLoader = new ExternalAssetLoader();
		externalAssetLoader.addEventListener(DataEvent.LOAD_COMPLETE, parseExternalAsset, false, 0, true);
		externalAssetLoader.load("http://sites.google.com/site/tyrannotorus/01-glassjoe.zip", ["spritesheet.png", "logic.txt"]);
				
		musicTransform = new SoundTransform(0.1);
		music = Assets.getSound("audio/title_music.mp3", true);
		musicChannel = music.play();
		musicChannel.soundTransform = musicTransform;
	}
	
	/**
	 * External Asset has been loaded and extracted from the zip. Parse it.
	 * @param {DataEvent.LOAD_COMPLETE}	e
	 */
	private function parseExternalAsset(e:DataEvent):Void {
		externalAssetLoader.removeEventListener(DataEvent.LOAD_COMPLETE, parseExternalAsset);
		
		var spritesheet:Bitmap = Reflect.field(e.data, "spritesheet.png");
		var logic:String = Reflect.field(e.data, "logic.txt");
		var characterData:Dynamic = Utils.parseCharacterData(spritesheet.bitmapData, logic);
		opponent = new Actor(characterData);
		Utils.position(opponent, Constants.CENTER, 73);
		addChild(opponent);
		
		ring.loadRing(characterData);
				
		Utils.position(player, Constants.CENTER, 135);
		addChild(player);
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onGameKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onGameKeyUp);
	}
	
	private function onEnterFrame(e:Event):Void {
		player.animate();
		opponent.animate();
	}
	
	private function onGameKeyDown(e:KeyboardEvent):Void {
		
		switch(e.keyCode) {
			
			// Left key
			case 37:
				if (leftKey == false) {
					leftKey = true;
				}
			
			// Up key
			case 38:
				if (upKey == false) {
					upKey = true;
				}
			
			// Right Key	
			case 39:
				if (rightKey == false) {
					rightKey = true;
				}
			
			// Down Key
			case 40:
				if (downKey == false) {
					downKey = true;
				}
			
			// X Key
			case 88:
				if (xKey == false) {
					xKey = true;
				}
			
			// Z Key
			case 90:
				if (zKey == false) {
					zKey = true;
					player.punchKey();
				}
		}
			
	}
	
	private function onGameKeyUp(e:KeyboardEvent):Void {
				
		switch(e.keyCode) {
			case 37:
				leftKey = false;
			case 38:
				upKey = false;
			case 39:
				rightKey = false;
			case 40:
				downKey = false;
			case 88:
				xKey = false;
			case 90:
				zKey = false;
		}
		
	}
	
	
	
}
