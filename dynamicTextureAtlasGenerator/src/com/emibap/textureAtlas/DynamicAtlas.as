package com.emibap.textureAtlas
{
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import com.emibap.textureAtlas.TextureItem;
	
	/**
	 * DynamicAtlas.as
	 * https://github.com/emibap/Dynamic-Texture-Atlas-Generator
	 * @author Emibap (Emiliano Angelini) - http://www.emibap.com
	 *
	 * Dynamic Texture Atlas Generator (Starling framework Extension)
	 * ========
	 * 
	 * # version 0.7 #
	 * 
	 * This tool will convert any MovieClip containing Other MovieClips, Sprites or Graphics into a starling Texture Atlas, all in runtime. 
	 * By using it, you won't have to statically create your spritesheets. Just take a regular MovieClip containing all the display objects you wish to put into your Altas, and convert everything from vectors to bitmap textures. 
	 * This extension could save you a lot of time specially if you'll be coding mobile apps with the [starling framework](http://www.starling-framework.org/).
	 * 
	 * ### Features ###
	 * 
	 * * Dynamic creation of a Texture Altas from a MovieClip (flash.display.MovieClip) container that could act as a sprite sheet
	 * * Filters made to the objects are captured
	 * * Automatically detects the objects bounds so you don't necesarily have to set the registration points to TOP LEFT
	 * 
	 * ### TODO List ###
	 * 
	 * * Scaling all the objects based on a parameter before taking snapshots (for optimal memory usage)
	 * * Further code optimization
	 * * Documentation (?)
	 * 
	 * ### Whish List ###
	 * * Optional division of the process into small intervals (for smooth performance of the app)
	 * 
	 * ### Usage ###
	 * 	Use the static method DynamicAtlas.fromMovieClipContainer.
	 * 	
	 * 	DynamicAtlas.fromMovieClipContainer(swf:flash.display.MovieClip):starling.textures.TextureAtlas
	 * 	
	 * 	Params:
	 * 		* swf:flash.display.MovieClip - The MovieClip sprite sheet you wish to convert into a TextureAtlas. It should contain named instances of all the MovieClips that will become the subtextures of your Atlas.
	 * 	
	 * 	Returns:
	 * 		* A TextureAtlas.
	 * 		
	 * 	Enclose inside a try/catch for error handling:
	 * 		try {
	 * 				var atlas:TextureAtlas = DynamicAtlas.fromMovieClipContainer(mc);
	 * 			} catch (e:Error) {
	 * 				trace("There was an error in the creation of the texture Atlas. Please check if the dimensions of your clip exceeded the maximun allowed texture size. -", e.message);
	 * 			}
	 * 
	 *
	**/
	
	public class DynamicAtlas
	{
		static protected const DEFAULT_CANVAS_WIDTH:Number = 640;
		
		static protected var _items:Array;
		static protected var _canvas:Sprite;
		
		static protected var _currentLab:String = "";
		
		static protected var _x:Number;
		static protected var _y:Number;
		
		static protected var _bounds:Rectangle;
		static protected var _bData:BitmapData;
		static protected var _mat:Matrix;
		static protected var _margin:Number = 0;
		static protected var _preserveColor:Boolean = true;
		
		// Will not be used - Only using one static method
		public function DynamicAtlas()
		{
		
		}
		
		static public function fromMovieClipContainer(swf:MovieClip):TextureAtlas
		{
			var parseFrame:Boolean = false;
			var selected:MovieClip;
			var selectedTotalFrames:int;
			var selectedColorTransform:ColorTransform;
			
			var itemW:Number;
			var itemH:Number;
			
			
			var children:uint = swf.numChildren;
			
			var canvasData:BitmapData;
			
			var texture:Texture;
			var xml:XML;
			var subText:XML;
			var atlas:TextureAtlas;
			
			var itemsLen:int;
			var itm:TextureItem;
			
			var m:uint;
			
			_items = [];
			
			if (!_canvas) _canvas = new Sprite();
			
			swf.gotoAndStop(1);
			
			for (var i:uint = 0; i < children; i++)
			{
				selected = MovieClip(swf.getChildAt(i));
				selectedTotalFrames = selected.totalFrames;
				selectedColorTransform = selected.transform.colorTransform;
				_x = selected.x;
				_y = selected.y;
				
				m = 0;
				
				// check for frames
				while (++m <= selectedTotalFrames) {
					selected.gotoAndStop(m);
					drawItem(selected, selected.name + "_" + appendIntToString(m-1, 5), selected.name, selectedColorTransform);
				}
				
			}
			
			_currentLab = "";
			
			layoutChildren();
			
			canvasData = new BitmapData(_canvas.width, _canvas.height, true, 0x000000);
			canvasData.draw(_canvas);
			
			
			xml = new XML(<TextureAtlas></TextureAtlas>);
			xml.@imagePath = "atlas.png";
			
			itemsLen = _items.length;
			
			for(var k:uint=0; k<itemsLen; k++){
				
				itm = _items[k];
				
				itm.graphic.dispose();
				
				// xml
				subText= new XML(<SubTexture />); 
				subText.@x = itm.x;
				subText.@y = itm.y;
				subText.@width = itm.width;
				subText.@height = itm.height;
				subText.@name = itm.textureName;
				if(itm.frameName != "") subText.@frameLabel = itm.frameName;
				xml.appendChild(subText);
			}
			texture = Texture.fromBitmapData(canvasData);
			atlas = new TextureAtlas(texture, xml);
			
			return atlas;
		}
		
		static protected function drawItem(clip:MovieClip, name:String = "", baseName:String ="", clipColorTransform:ColorTransform=null):TextureItem{
			
			
			_bounds = clip.getBounds(clip.parent);
			
			_bounds.x = 		Math.floor(_bounds.x);
			_bounds.y = 		Math.floor(_bounds.y);
			_bounds.height = Math.ceil(_bounds.height);
			_bounds.width = Math.ceil(_bounds.width);
			
			var realBounds:Rectangle = new Rectangle(0, 0, _bounds.width + _margin * 2, _bounds.height + _margin * 2);
			
			if (clip.filters.length > 0)
			{
				// filters
				var j:int = 0;
				var clipFilters:Array = clip.filters;
				var clipFiltersLength:int = clipFilters.length;
				var tmpBData:BitmapData;
				var filterRect:Rectangle;
				
				tmpBData = new BitmapData(realBounds.width, realBounds.height, false);
				filterRect = tmpBData.generateFilterRect(tmpBData.rect, clipFilters[j]);
				tmpBData.dispose();
				
				while (++j < clipFiltersLength) 
				{
					tmpBData = new BitmapData(filterRect.width, filterRect.height, true, 0);
					filterRect = tmpBData.generateFilterRect(tmpBData.rect, clipFilters[j]);
					realBounds = realBounds.union(filterRect);
					tmpBData.dispose();
				}
			}
			
			realBounds.offset(_bounds.x, _bounds.y);
			realBounds.width = Math.max(realBounds.width, 1);
			realBounds.height = Math.max(realBounds.height, 1);
			
			_bData = new BitmapData(realBounds.width, realBounds.height, true, 0);
			
			_mat = clip.transform.matrix;
			_mat.translate(-realBounds.x + _margin, -realBounds.y + _margin);
			
			_bData.draw(clip, _mat, _preserveColor ? clipColorTransform : null);
			
			realBounds.offset(-_x - _margin, -_y - _margin);

			var label:String = "";

			if(clip.currentLabel != _currentLab && clip.currentLabel != null){
				_currentLab = clip.currentLabel;
				label = _currentLab;
			}
			var item:TextureItem = new TextureItem(_bData, name, label);
			_items.push(item);
			_canvas.addChild(item);
			
			
			tmpBData = null;
			_bData = null;

			
			return item;
		}
		
		static public function layoutChildren():void
		{
			var xPos:Number = 0;
			var yPos:Number = 0;
			var maxY:Number = 0;
			var len:int = _items.length;
			
			var itm:TextureItem;
			
			for (var i:uint = 0; i < len; i++)
			{
				itm = _items[i];
				if ((xPos + itm.width) > DEFAULT_CANVAS_WIDTH)
				{
					xPos = 0;
					yPos += maxY;
					maxY = 0;
				}
				if (itm.height + 1 > maxY)
				{
					maxY = itm.height + 1;
				}
				itm.x = xPos;
				itm.y = yPos;
				xPos += itm.width + 1;
			}
		}
		
		static protected function appendIntToString(num:int, numOfPlaces:int):String{
			var numString:String = num.toString();
			var outString:String = "";
			for(var i:int=0; i<numOfPlaces - numString.length; i++){
				outString += "0";
			}
			return outString + numString;
		}
		
	}

}