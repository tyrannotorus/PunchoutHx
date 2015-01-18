package com.tyrannotorus.punchout;

import openfl.net.URLRequest;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import List;
import haxe.zip.Reader;
import haxe.zip.Entry;
import haxe.zip.Uncompress;

class ExternalAsset {
	
	private var urlLoader:URLLoader;
	private var urlRequest:URLRequest;
	
	public function new():Void {
		// Constructor
	}
	
	/**
	 * Loads an external asset (like a zip file)
	 * @param	{String} path
	 */
	public function load(path:String):Void {
		trace("Attempting to load " + path);
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
		trace('Zip loaded!');
		var byteArray:ByteArray = cast(e.target, URLLoader).data;
		var bytes:Bytes = Bytes.ofData(byteArray);    
		var bytesInput = new BytesInput(bytes);
    
		var reader = new Reader(bytesInput);
		var entries:List<Entry> = reader.read();            
		//var searchEntryFileName = "path/to/textfile.txt";
		for (entry in entries ) {
			trace(entry.fileName);
			//if (entry.fileName == searchEntryFileName) {
			//	var bytes:Bytes = entry.data;
			//	var string = bytes.toString();
			//	trace(string); // <--- Traces "Hello zip!"
			//}
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
