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
	private var opponent:Opponent;
	private var healthBars:HealthBars;
	private var menu:Menu;
	
	// Fonts and text typing
	public var textManager:TextManager;
	
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
		opponent = new Opponent();
		healthBars = new HealthBars();
		textManager = new TextManager();
		menu = new Menu(this);
		addChild(menu);
		
		var testText:Dynamic = { };
		testText.text = "Mike Tysons\nPunch\nout!!";
		testText.fontColor1 = 0xFFFFFFFF;
		testText.fontSet = 4;
		addChild(textManager.typeText(testText));
		
		var externalAsset:ExternalAsset = new ExternalAsset();
		externalAsset.load("http://sites.google.com/site/tyrannotorus/bruce_lee_v1.zip");// ../../../assets/zips / bruce_lee_v1.zip");
				
		musicTransform = new SoundTransform(0.1);
		music = Assets.getSound("audio/title_music.mp3", true);
		musicChannel = music.play();
		musicChannel.soundTransform = musicTransform;
	}
	
}
