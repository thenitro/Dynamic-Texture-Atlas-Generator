package com.emibap.textureAtlas{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class TextureItem extends Sprite{
		
		private var _graphic:BitmapData;
		private var _clipName:String = "";
		private var _textureName:String = "";
		private var _frameName:String = "";
		
		public function TextureItem(graphic:BitmapData, textureName:String, frameName:String, clipName:String){
			super();
			
			_graphic = graphic;
			_textureName = textureName;
			_frameName = frameName;
			_clipName = clipName;
			
			var bm:Bitmap = new Bitmap(graphic, "auto", false);
			addChild(bm);
		}
		
		public function get clipName():String{
			
			return _clipName;
		}
		
		public function get textureName():String{
			return _textureName;
		}
		
		public function get frameName():String{
			return _frameName;
		}
		
		public function get graphic():BitmapData{
			return _graphic;
		}
	}
}