package com.tyrannotorus.punchout;

import format.swf.Data.Sound;
import openfl.display.DisplayObject;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import motion.Actuate;
import openfl.geom.Point;

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
	
	public static function parseCharacterData(source:BitmapData, characterLogic:String):Dynamic {
		
		var line:String;
		var logic:Array<String> = characterLogic.split("\r\n").map(removeComments).map(removeWhiteSpace).filter(removeNulls);
				
		var character:Dynamic = { };
		var stats:Dynamic = { };
		var frameCoordinates:Dynamic = { };
		
		var actions:Dynamic = { };
		var actionData:Dynamic = null;
		var combos:Dynamic = { };
		var comboData:Dynamic = null;
		
		var tempString:String;
		var frameProperties:Array<String>;
		var frameProperty:Array<String>;
		var actionType:String = "";
		
		for (i in 0...logic.length) {
			
			line = logic[i];
			
			// Parse the stat
			if(line.indexOf("stats.")==0) {
				tempString = line.substring(6, line.indexOf("="));
				Reflect.setField(stats, tempString, line.split("=")[1]);
				
			// Initilize parsing of frame data, followed by timing data
			} else if(line.indexOf("frames.")==0){
				actionType = line.substring(7, line.indexOf("("));
				parseFrame(line, actionType, actions, frameCoordinates);
											
			// Initilize parsing of combo data, followed by combo timing data
			} else if (line.indexOf("combos.")==0) {
				actionType = line.substring(7);
				Reflect.setField(combos, actionType, new Array<Int>());
			
			// Parse data for successive frames in this action
			} else if(Reflect.field(actions, actionType) != null) {
				parseFrameData(line, actionType, actions);
						
			} else if(Reflect.field(combos, actionType) != null) {
				var comboData:Array<String> = line.split(",");
				Reflect.field(combos, actionType).push(comboData);
			}
		}
		
		// Find width of animation cell
		var cellWidth:Int = source.width;
		for (i in 0...cellWidth) {
			if (source.getPixel32(i, 0) != Constants.COLOR_MAGENTA) {
				cellWidth = i;
				break;
			}
		}
		
		// Find height of animation cell
		var cellHeight:Int = source.height;
		for (i in 0...cellHeight) {
			if (source.getPixel32(0, i) != Constants.COLOR_MAGENTA) {
				cellHeight = i;
				break;
			}
		}		
		
		// Create new spritesheet of source with alpha channel
		var rect:Rectangle = source.rect;
		var zeroPoint:Point = new Point(0, 0);
				
		// Copy and Fill animation cells
		var fields:Array<Dynamic> = Reflect.fields(actions);
		for (key in Reflect.fields(actions)) {
			var actionData:Dynamic = Reflect.field(actions, key);
			var point:Point = Reflect.field(frameCoordinates, key);
			Reflect.setField(actionData, "bitmap", new Array<BitmapData>());
			
			var len:Int = Reflect.field(actionData, "timing").length;
			for(i in 0...len) {
				var posX:Int = Std.int(point.x * cellWidth + point.x + i * (cellWidth + 1));
				var posY:Int = Std.int(point.y * cellHeight + point.y);
				var rect:Rectangle = new Rectangle(posX, posY, cellWidth, cellHeight);
				var cell:BitmapData = new BitmapData(cellWidth, cellHeight, true);
				cell.copyPixels(source, rect, zeroPoint);
				cell.threshold(cell, cell.rect, zeroPoint, "==", Constants.COLOR_MAGENTA);
				Reflect.field(actionData, "bitmap")[i] = cell;
			}
		}
		
		source.dispose();
			
		Reflect.setField(character, "stats", stats);
		Reflect.setField(character, "actions", actions);
		Reflect.setField(character, "combos", combos);
		
		return character;			
	}
	
	private static function parseFrame(line:String, actionType:String, actions:Dynamic, frameCoordinates:Dynamic):Void {
		
		// Parse frame coordinates
		var bracket:Int = line.indexOf("(");
		var comma:Int = line.indexOf(",");
		var posX:Int = Std.parseInt(line.substring(bracket + 1, comma));
		var posY:Int = Std.parseInt(line.substring(comma + 1, line.indexOf(")")));
		Reflect.setField(frameCoordinates, actionType, new Point(posX, posY));
				
		var actionData:Dynamic = { };
		Reflect.setField(actionData, "sfx", new Array<Sound>());
		Reflect.setField(actionData, "timing", new Array<Int>());
		Reflect.setField(actionData, "hit", new Array<Int>());
		Reflect.setField(actionData, "hitpow", new Array<Int>());
		Reflect.setField(actionData, "hitangle", new Array<Int>());
		Reflect.setField(actionData, "hitvx", new Array<Int>());
		Reflect.setField(actionData, "hitvy", new Array<Int>());
		Reflect.setField(actionData, "hithp", new Array<Int>());
		Reflect.setField(actionData, "hitsp", new Array<Int>());
		Reflect.setField(actionData, "xshift", new Array<Int>());
		Reflect.setField(actionData, "yshift", new Array<Int>());
		Reflect.setField(actionData, "xshove", new Array<Int>());
		Reflect.setField(actionData, "yshove", new Array<Int>());
		Reflect.setField(actionData, "flip", new Array<Int>());
		
		Reflect.setField(actions, actionType, actionData);
	}
	
	private static function parseFrameData(line:String, actionType:String, actions:Dynamic):Void {
		var actionData:Dynamic = Reflect.field(actions, actionType); 			
		var frame:Int = Reflect.field(actionData, "timing").length;
								
		// Ensure all indices (except for sfx) are populated with at least int 0
		var fields:Array<String> = Reflect.fields(actionData);
		for (i in 0...fields.length) {
			if (fields[i] != "sfx") {
				Reflect.field(actionData, fields[i])[frame] = 0;
			}
		}
				
		Reflect.field(actionData, "sfx")[frame] = null;
		Reflect.field(actionData, "flip")[frame] = 1;
					
		var frameProperty:Array<String>;
		var frameProperties:Array<String> = line.split(",");
		for(i in 0...frameProperties.length){
			frameProperty = frameProperties[i].split(":");
					
			if (frameProperty[0] == "sfx") {
				//var sound:Sound = sound[ arr[1].slice(0, arr[1].indexOf(".")) ] as Sound;
				//var sound:String = 
				//Reflect.setField(actionData, "sfx". sound); 
					
			} else if(frameProperty[0] == "flip") {
				Reflect.field(actionData, "flip")[frame] = (frameProperty[1]=="0"?1:-1);
						
			} else {
				Reflect.field(actionData, frameProperty[0])[frame] = frameProperty[1];
			}
		}
	}
	
	private static function removeNulls(element:String):Bool {
    	return (element != "");
	}
																										
	private static function removeComments(element:String):String {
    	return element.split(";")[0];
	}
		
	private static function removeWhiteSpace(element:String):String {						//
		var string:String;
		var array1:Array<String> = element.split("\t").join("").split(",");									//
		for (i in 0...array1.length) {
			var array2:Array<String> = array1[i].split("\"");
			string = "";
			for(j in 0...array2.length) {														//
				(j==1) ? string += array2[j] : string += array2[j].split(" ").join("");					//
			}
			array1[i] = string;
		}
		string = array1.join(",");
		return string;
    }
	
	
}