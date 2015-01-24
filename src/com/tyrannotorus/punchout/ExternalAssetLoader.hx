package com.tyrannotorus.punchout;

import openfl.display.Loader;
import openfl.net.URLRequest;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.ProgressEvent;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.utils.ByteArray;
import openfl.display.LoaderInfo;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.Reader;
import haxe.zip.Tools;
import haxe.zip.Entry;
import haxe.zip.Uncompress;
import openfl.utils.ByteArray;
import List;
import flash.utils.CompressionAlgorithm;

class ExternalAssetLoader extends EventDispatcher {
	
	private var urlLoader:URLLoader;
	private var urlRequest:URLRequest;
	private var filesToLoad:Int;
	private var data:Dynamic;
	
	public function new():Void {
		super();
	}
	
	/**
	 * Loads an external asset (like a zip file)
	 * @param	{String} path
	 * @param	{Array<String>} An array of specific files to return
	 */
	public function load(path:String, filesToLoad:Array<String>):Void {
		
		data = { };
		this.filesToLoad = filesToLoad.length;
		while (filesToLoad.length != 0) {
			Reflect.setField(data, filesToLoad.pop(), true);
		}
		
		urlLoader = new URLLoader();
		urlRequest = new URLRequest(path);
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.addEventListener(Event.COMPLETE, onLoadComplete);
		urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgressEvent);
		urlLoader.load(urlRequest);
	}
	
	private function removeListeners():Void {
		urlLoader.removeEventListener(Event.COMPLETE, onLoadComplete);
		urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
	}
 
	/**
	 * External zip file is loaded
	 * @param {Event.COMPLETE} e
	 */
	private function onLoadComplete(e:Event):Void {
		removeListeners();
		var fileName:String;
		var fileType:String;
		var byteArray:ByteArray = cast(e.target, URLLoader).data;
		var bytes:Bytes = Bytes.ofData(byteArray);
        var bytesInput:BytesInput = new haxe.io.BytesInput(bytes);
       	var reader:format.zip.Reader = new format.zip.Reader(bytesInput);
		var entries:List<format.zip.Data.Entry> = reader.read();
		
		// Cycle through entries in the zip
		for(entry in entries) {
			
			fileName = entry.fileName.split("/").pop().toLowerCase();
			fileType = fileName.substr(-4);
			
			if (false == Std.is(Reflect.field(data, fileName), Bool)) {
				continue;
			}
			
			// Parse the .png from the zip
			if(fileType == ".png"){
				var loader:Loader = new Loader();
				loader.name = fileName;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
				loader.loadBytes(entry.data.getData());
			
			// parse .txt from the zip
			} else if (fileType == ".txt") {
				Reflect.setField(data, fileName, entry.data.toString());
				dispatchFiles();
			}
		} 
	}
	
	/**
	 * PNG Bytearray successfully loaded
	 * @param {Event.COMPLETE} e
	 */
	private function onImageLoaded(e:Event):Void {
		var loaderInfo:LoaderInfo = cast(e.target, LoaderInfo);
		loaderInfo.removeEventListener(Event.COMPLETE, onImageLoaded);
		Reflect.setField(data, loaderInfo.loader.name, cast(loaderInfo.content, Bitmap));
		loaderInfo = null;
		dispatchFiles();
	}
	
	/**
	 * Dispatch files if the load is complete
	 */
	private function dispatchFiles():Void {
		if (--filesToLoad == 0) {
			urlLoader = null;
			dispatchEvent(new DataEvent(DataEvent.LOAD_COMPLETE, data));
		}
	}
	
	private function onIOError(e:IOErrorEvent):Void {
		removeListeners();
		trace("IO Error");
	}
	
	private function onProgressEvent(e:ProgressEvent):Void {
		var loadedPct:UInt = Math.round(100 * (e.bytesLoaded / e.bytesTotal)); 
		trace(loadedPct + "% loaded."); 
	}
	
	private function onSecurityErrorEvent(e:SecurityErrorEvent):Void {
		removeListeners();
		trace("onSecurityErrorEvent event " + e);
	}	
}
