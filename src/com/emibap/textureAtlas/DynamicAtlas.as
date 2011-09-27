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
	 * ...
	 * @author Emibap
	 */
	public class DynamicAtlas
	{
		
		
		static private const DEFAULT_CANVAS_WIDTH:Number = 640;
		
		static private var _items:Array;
		static private var _canvas:Sprite;
		
		static private var _currentLab:String = "";
		
		static private var _x:Number;
		static private var _y:Number;
		
		static private var _bounds:Rectangle;
		static private var bData:BitmapData;
		static private var mat:Matrix;
		static private var _margin:Number = 0;
		static private var _preserveColor:Boolean = true;
		
		
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
			var matrix:Matrix;
			
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
		
		/*static private function drawItem(clip:MovieClip, name:String = "", baseName:String =""):TextureItem{
			var label:String = "";
			var bounds:Rectangle = clip.getBounds(clip);
			var itemW:Number = Math.ceil(bounds.x + bounds.width);
			var itemH:Number = Math.ceil(bounds.y + bounds.height);
			var bmd:BitmapData = new BitmapData(itemW, itemH, true, 0x00000000);
			bmd.draw(clip);
			if(clip.currentLabel != _currentLab && clip.currentLabel != null){
				_currentLab = clip.currentLabel;
				label = _currentLab;
			}
			var item:TextureItem = new TextureItem(bmd, name, label, baseName);
			addItem(item);
			return item;
		}*/
		static private function drawItem(clip:MovieClip, name:String = "", baseName:String ="", clipColorTransform:ColorTransform=null):TextureItem{
			
			
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
				
				// initialisation du bData pour le premier filtre
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
			
			bData = new BitmapData(realBounds.width, realBounds.height, true, 0);
			
			mat = clip.transform.matrix;
			mat.translate(-realBounds.x + _margin, -realBounds.y + _margin);
			
			bData.draw(clip, mat, _preserveColor ? clipColorTransform : null);
			
			//_allBitmaps[i-1] = bData;
			realBounds.offset(-_x - _margin, -_y - _margin);
			//_allBounds[bData] = realBounds;
			
			
			
			
			
			
			
			
			
			
			var label:String = "";
			//var bounds:Rectangle = clip.getBounds(clip);
			//var itemW:Number = Math.ceil(bounds.x + bounds.width);
			//var itemH:Number = Math.ceil(bounds.y + bounds.height);
			//var bmd:BitmapData = new BitmapData(itemW, itemH, true, 0x00000000);
			//bmd.draw(clip);
			if(clip.currentLabel != _currentLab && clip.currentLabel != null){
				_currentLab = clip.currentLabel;
				label = _currentLab;
			}
			//var item:TextureItem = new TextureItem(bmd, name, label, baseName);
			var item:TextureItem = new TextureItem(bData, name, label, baseName);
			addItem(item);
			
			
			tmpBData = null;
			bData = null;

			
			return item;
		}
		
		static private function addItem(item:TextureItem):void{
			_items.push(item);
			_canvas.addChild(item);
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
		
		static private function appendIntToString(num:int, numOfPlaces:int):String{
			var numString:String = num.toString();
			var outString:String = "";
			for(var i:int=0; i<numOfPlaces - numString.length; i++){
				outString += "0";
			}
			return outString + numString;
		}
		
	}

}