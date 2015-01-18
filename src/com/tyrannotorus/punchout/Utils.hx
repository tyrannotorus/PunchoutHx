package com.tyrannotorus.punchout;

import flash.display.DisplayObject;
import motion.Actuate;

class Utils {

	public static function centerX(displayObject:Dynamic, maxWidth:Int = -1):Int {
		var w:Int = maxWidth < 0 ? Constants.fullWidth : maxWidth;
		return Std.int((w - displayObject.width) * 0.5);
	}
	
	public static function centerY(displayObject:Dynamic, maxHeight:Int = -1):Int {
		var h:Int = maxHeight < 0 ? Constants.fullHeight : maxHeight;
		return Std.int((h - displayObject.height) * 0.5);
	}
	
	public static function center(displayObject:Dynamic, maxWidth:Int = -1, maxHeight:Int = -1):Void {
		displayObject.x = centerX(displayObject, maxWidth);
		displayObject.y = centerY(displayObject, maxHeight);
	}
	
	/**
	 * Returns field of object if it exists, otherwise returns defaultField
	 * @param	object
	 * @param	field
	 * @param	defaultField
	 * @return Dynamic
	 */
	public static function getField(object:Dynamic, field:Dynamic, defaultField:Dynamic):Dynamic {
		return Reflect.hasField(object, field) ? Reflect.field(object, field) : defaultField;
	}
	
	/**
	 * Tweens the color of an object, with on optional callback function on complete
	 * @param	object
	 * @param	callBackFunction
	 */
	public static function tweenColor(object:Dynamic, callBackFunction:Dynamic = null):Void {
		var i:Int = Math.floor(Math.random() * Constants.colors.length);
		Actuate.transform(object, 1).color(Constants.colors[i], 0.5).onComplete(callBackFunction);
	}
	
	
}