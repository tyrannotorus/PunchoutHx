package com.tyrannotorus.punchout;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.Lib;

class Ring extends Sprite {

	private var ringBitmap:Bitmap;
	
	public function new() {
		super();
		ringBitmap = new Bitmap();
		ringBitmap.smoothing = true;
		addChild(ringBitmap);
	}
	
	public function loadRing(assetPath:String) {
		trace(assetPath);
		ringBitmap.bitmapData = Assets.getBitmapData(assetPath);
	}

}
