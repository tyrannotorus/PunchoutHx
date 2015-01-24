package com.tyrannotorus.punchout;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.StageDisplayState;
import openfl.events.Event;
import openfl.Lib;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

class Game extends Sprite {
		
	private var ring:Ring;
	private var player:Player;
	private var opponent:Actor;
	private var healthBars:HealthBars;
	private var menu:Menu;
	
	// Fonts and text typing
	public var textManager:TextManager;
	
	private var externalAssetLoader:ExternalAssetLoader;
	
	// Music and sfx
	private var music:Sound;
	private var musicChannel:SoundChannel;
	private var musicTransform:SoundTransform;
	
	public function new() {
		
		super();
		
		ring = new Ring();
		ring.loadRing("img/ring-01.png");
		addChild(ring);
				
		player = new Player();
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
		var fields:Array<String> = Reflect.fields(Reflect.field(characterData, "actions"));
		trace(fields);
		//addChild(new Bitmap(characterData.actions.KNOCKDOWN.bitmap[0]));
		
		opponent = new Actor(characterData);
		Utils.center(opponent);
		addChild(opponent);
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(e:Event):Void {
		opponent.animate();
	}
	
	
	
}
