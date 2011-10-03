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
	 * First Public version
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
	 *  History:
	 *  -------
	 * # version 0.8 #
	 * - Added the scaleFactor constructor parameter. Now you can define a custom scale to the final result.
	 * - Scaling also applies to filters.
	 * - Added Margin and PreserveColor Properties
	 *
	 * # version 0.7 #
	 * First Public version
	 **/
	
	public class DynamicAtlas
	{
		static protected const DEFAULT_CANVAS_WIDTH:Number = 640;
		
		static protected var _items:Array;
		static protected var _canvas:Sprite;
		
		static protected var _currentLab:String;
		
		static protected var _x:Number;
		static protected var _y:Number;
		
		static protected var _bounds:Rectangle;
		static protected var _realBounds:Rectangle
		static protected var _bData:BitmapData;
		static protected var _mat:Matrix;
		static protected var _margin:Number;
		static protected var _preserveColor:Boolean;
		
		// Will not be used - Only using one static method
		public function DynamicAtlas()
		{
		
		}
		
		static public function fromMovieClipContainer(swf:MovieClip, scaleFactor:Number = 1, margin:uint=0, preserveColor:Boolean = true):TextureAtlas
		{
			var parseFrame:Boolean = false;
			var selected:MovieClip;
			var selectedTotalFrames:int;
			var selectedColorTransform:ColorTransform;
			
			var children:uint = swf.numChildren;
			
			var canvasData:BitmapData;
			
			var texture:Texture;
			var xml:XML;
			var subText:XML;
			var atlas:TextureAtlas;
			
			var itemsLen:int;
			var itm:TextureItem;
			
			var m:uint;
			
			_margin = margin;
			_preserveColor = preserveColor;
			
			_items = [];
			
			if (!_canvas)
				_canvas = new Sprite();
			
			swf.gotoAndStop(1);
			
			for (var i:uint = 0; i < children; i++)
			{
				selected = MovieClip(swf.getChildAt(i));
				selectedTotalFrames = selected.totalFrames;
				selectedColorTransform = selected.transform.colorTransform;
				_x = selected.x;
				_y = selected.y;
				
				// Scaling if needed (including filters)
				if (scaleFactor != 1)
				{
					
					selected.scaleX *= scaleFactor;
					selected.scaleY *= scaleFactor;
					
					if (selected.filters.length > 0)
					{
						var filters:Array = selected.filters;
						var filtersLen:int = selected.filters.length;
						var filter:Object;
						for (var j:uint = 0; j < filtersLen; j++)
						{
							filter = filters[j];
							
							if (filter.hasOwnProperty("blurX"))
							{
								filter.blurX *= scaleFactor;
								filter.blurY *= scaleFactor;
							}
							if (filter.hasOwnProperty("distance"))
							{
								filter.distance *= scaleFactor;
							}
						}
						selected.filters = filters;
					}
				}
				
				m = 0;
				
				// Draw every frame
				while (++m <= selectedTotalFrames)
				{
					selected.gotoAndStop(m);
					drawItem(selected, selected.name + "_" + appendIntToString(m - 1, 5), selected.name, selectedColorTransform);
				}
			}
			
			_currentLab = "";
			
			layoutChildren();
			
			canvasData = new BitmapData(_canvas.width, _canvas.height, true, 0x000000);
			canvasData.draw(_canvas);
			
			xml = new XML(<TextureAtlas></TextureAtlas>);
			xml.@imagePath = "atlas.png";
			
			itemsLen = _items.length;
			
			for (var k:uint = 0; k < itemsLen; k++)
			{
				itm = _items[k];
				
				itm.graphic.dispose();
				
				// xml
				subText = new XML(<SubTexture />); 
				subText.@x = itm.x;
				subText.@y = itm.y;
				subText.@width = itm.width;
				subText.@height = itm.height;
				subText.@name = itm.textureName;
				if (itm.frameName != "")
					subText.@frameLabel = itm.frameName;
				xml.appendChild(subText);
			}
			texture = Texture.fromBitmapData(canvasData);
			atlas = new TextureAtlas(texture, xml);
			
			
			_items.length = 0;
			_canvas.removeChildren();
			
			_items = null;
			xml = null;
			_canvas = null;
			_currentLab = null;
			_x = _y = _margin = null;
			_bounds = _realBounds = null;
			
			
			return atlas;
		}
		
		static protected function drawItem(clip:MovieClip, name:String = "", baseName:String = "", clipColorTransform:ColorTransform = null):TextureItem
		{
			_bounds = clip.getBounds(clip.parent);
			_bounds.x = Math.floor(_bounds.x);
			_bounds.y = Math.floor(_bounds.y);
			_bounds.height = Math.ceil(_bounds.height);
			_bounds.width = Math.ceil(_bounds.width);
			
			_realBounds = new Rectangle(0, 0, _bounds.width + _margin * 2, _bounds.height + _margin * 2);
			
			// Checking filters in case we need to expand the outer bounds
			if (clip.filters.length > 0)
			{
				// filters
				var j:int = 0;
				//var clipFilters:Array = clipChild.filters.concat();
				var clipFilters:Array = clip.filters;
				var clipFiltersLength:int = clipFilters.length;
				var tmpBData:BitmapData;
				var filterRect:Rectangle;
				
				tmpBData = new BitmapData(_realBounds.width, _realBounds.height, false);
				filterRect = tmpBData.generateFilterRect(tmpBData.rect, clipFilters[j]);
				tmpBData.dispose();
				
				while (++j < clipFiltersLength)
				{
					tmpBData = new BitmapData(filterRect.width, filterRect.height, true, 0);
					filterRect = tmpBData.generateFilterRect(tmpBData.rect, clipFilters[j]);
					_realBounds = _realBounds.union(filterRect);
					tmpBData.dispose();
				}
			}
			
			_realBounds.offset(_bounds.x, _bounds.y);
			_realBounds.width = Math.max(_realBounds.width, 1);
			_realBounds.height = Math.max(_realBounds.height, 1);
			
			_bData = new BitmapData(_realBounds.width, _realBounds.height, true, 0);
			
			_mat = clip.transform.matrix;
			_mat.translate(-_realBounds.x + _margin, -_realBounds.y + _margin);
			
			_bData.draw(clip, _mat, _preserveColor ? clipColorTransform : null);
			
			//_realBounds.offset(-_x - _margin, -_y - _margin);
			
			var label:String = "";
			
			if (clip.currentLabel != _currentLab && clip.currentLabel != null)
			{
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
		
		static protected function appendIntToString(num:int, numOfPlaces:int):String
		{
			var numString:String = num.toString();
			var outString:String = "";
			for (var i:int = 0; i < numOfPlaces - numString.length; i++)
			{
				outString += "0";
			}
			return outString + numString;
		}
	
	}

}