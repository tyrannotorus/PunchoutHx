package com.tyrannotorus.punchout;

import haxe.ds.ObjectMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.Entry;
import haxe.zip.Reader;
import List;
import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;

class AssetLoader extends EventDispatcher {
	
	// Handled File types.
	private static inline var PNG:String = "png";
	private static inline var TXT:String = "txt";
	private static inline var ZIP:String = "zip";
	
	// Cache of previously loaded assets.
	private static var assetCache:ObjectMap<Dynamic,Dynamic> = new ObjectMap<Dynamic,Dynamic>();
	
	// Class variables.
	private var urlLoader:URLLoader;
	private var assetData:Dynamic;
	private var filesLeft:Int = 0;
	
	/**
	 * Constructor.
	 */
	public function new():Void {
		super();
	}
	
	/**
	 * Loads an external asset (like a zip file)
	 * @param {String} assetPath
	 */
	public function loadAsset(assetPath:String):Void {
		
		// If this asset was previously loaded, return it from the cache.
		assetData = Utils.getField(assetCache, assetPath, null);
		if (assetData != null) {
			dispatchEvent(new DataEvent(DataEvent.LOAD_COMPLETE, assetData));
			return;
		}
		
		// Create the asset data that will be returned to the user.
		assetData = { };
		assetData.assetPath = assetPath;
		assetData.fileType = assetPath.split(".").pop().toLowerCase();
		
		// Initiate loading the asset.
		urlLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.addEventListener(Event.COMPLETE, onAssetLoaded);
		urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onAssetLoadedError);
		urlLoader.addEventListener(ProgressEvent.PROGRESS, onAssetProgress);
		urlLoader.load(new URLRequest(assetPath));
	}
	
	/**
	 * The asset loaded successfully.
	 * @param {Event.COMPLETE} e
	 */
	private function onAssetLoaded(e:Event):Void {
		
		switch(assetData.fileType) {
			
			// Unpack the zip file.
			// OpenFL currently does *not* support compressed zip files.
			case ZIP:
				unpackZip(urlLoader.data);
				
			case PNG:
				
			default:
		}
		
		cleanUp();
	}
	
	/**
	 * There was an error loading the asset. Nothing more we can do here.
	 * @param {IOErrorEvent.IO_ERROR} e
	 */
	private function onAssetLoadedError(e:IOErrorEvent):Void {
		trace("AssetLoader.onAssetLoadedError() Loading: " + assetData.assetPath + " " + e);
		cleanUp();
		dispatchEvent(new DataEvent(DataEvent.LOAD_COMPLETE, null));
	}
	
	/**
	 * Called on progress loading the asset.
	 * @param {ProgressEvent.PROGRESS} e
	 */
	private function onAssetProgress(e:ProgressEvent):Void {
		var loadedPct:UInt = Math.round(100 * (e.bytesLoaded / e.bytesTotal)); 
		trace(loadedPct + "% loaded."); 
	}
	
	/**
	 * Unpack a loaded asset that's a zip file.
	 * @param {ByteArray} byteArray
	 */
	private function unpackZip(byteArray:ByteArray):Void {
		
		// Read the file entries in the zip.
		var bytes:Bytes = Bytes.ofData(byteArray);
        var bytesInput:BytesInput = new haxe.io.BytesInput(bytes);
       	var reader:format.zip.Reader = new format.zip.Reader(bytesInput);
		var zipEntries:List<format.zip.Data.Entry> = reader.read();
		
		filesLeft = zipEntries.length;
		
		// Cycle through entries in the zip
		for(entry in zipEntries) {
			
			var fileName:String = entry.fileName.split("/").pop().toLowerCase();
			var fileType:String = fileName.split(".").pop();
			
			trace("Loading " + fileName);
			
			// Parse the PNG from the zip.
			if(fileType == PNG){
				var loader:Loader = new Loader();
				loader.name = fileName;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageFromZipLoaded);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageFromZipError);
				loader.loadBytes(entry.data.getData());
			
			// parse .txt from the zip
			} else if (fileType == TXT) {
				Reflect.setField(assetData, fileName, entry.data.toString());
				trace("loading TXT " + assetData.fileName);
				dispatchComplete();
			}
		} 
	}
	
	/**
	 * An image from within a zip file has loaded.
	 * @param {Event.COMPLETE} e
	 */
	private function onImageFromZipLoaded(e:Event):Void {
		
		// Remove the loader listeners.
		var loaderInfo:LoaderInfo = cast(e.target, LoaderInfo);
		loaderInfo.removeEventListener(Event.COMPLETE, onImageFromZipLoaded);
		loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImageFromZipError);
		
		Reflect.setField(assetData, loaderInfo.loader.name, cast(loaderInfo.content, Bitmap));
		dispatchComplete();
	}
	
	/**
	 * There was an error loading an image from within a zip file.
	 * @param {IOErrorEvent.IO_ERROR} e
	 */
	private function onImageFromZipError(e:IOErrorEvent):Void {
		
		// Remove the loader listeners.
		var loaderInfo:LoaderInfo = cast(e.target, LoaderInfo);
		loaderInfo.removeEventListener(Event.COMPLETE, onImageFromZipLoaded);
		loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImageFromZipError);
		
		Reflect.setField(assetData, loaderInfo.loader.name, null);
		dispatchComplete();
	}
	
	/**
	 * Dispatch Event.COMPLETE to let anyone listening know that the asset has loaded.
	 */
	private function dispatchComplete():Void {
		
		// We're still waiting on files to load.
		if (--filesLeft > 0) {
			return;
		}
		
		// Save the assetData to the assetCache and dispatch compelete.
		var assetPath:String = assetData.assetPath;
		Reflect.setField(assetCache, assetPath, assetData);
		dispatchEvent(new DataEvent(DataEvent.LOAD_COMPLETE, assetData));
	}
	
	/**
	 * Always clean up your mess.
	 */
	private function cleanUp():Void {
		urlLoader.removeEventListener(Event.COMPLETE, onAssetLoaded);
		urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onAssetLoadedError);
		urlLoader.removeEventListener(ProgressEvent.PROGRESS, onAssetProgress);
		urlLoader = null;
	}
	
	
}
