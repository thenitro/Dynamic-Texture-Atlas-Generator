package com.emibap.textureAtlas
{
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import com.pixelrevision.textureAtlas.TextureItem;
	
	/**
	 * ...
	 * @author Emibap
	 */
	public class DynamicAtlas
	{
		
		
		static private var _canvasWidth:Number = 640;
		static private var _canvasHeight:Number = 640;
		
		static private var _items:Array;
		static private var _canvas:Sprite;
		
		static private var _currentLab:String = "";
		
		public function DynamicAtlas()
		{
		
		}
		
		
		static public function fromMovieClipContainer(swf:MovieClip):TextureAtlas
		{
			var parseFrame:Boolean = false;
			var selected:MovieClip;
			var itemW:Number;
			var itemH:Number;
			var bounds:Rectangle;
			
			var children:uint = swf.numChildren;
			var framesLen:uint;
			
			var canvasData:BitmapData;
			var matrix:Matrix;
			
			var texture:Texture;
			var xml:XML;
			var subText:XML;
			var atlas:TextureAtlas;
			
			var itemsLen:int;
			var itm:TextureItem;
			_items = [];
			
			if (!_canvas) _canvas = new Sprite();
			
			swf.gotoAndStop(1);
			
			for (var i:uint = 0; i < children; i++)
			{
				selected = MovieClip(swf.getChildAt(i));
				// check for frames
				if (selected.totalFrames > 1)
				{
					framesLen = selected.totalFrames;
					for (var m:uint = 0; m < framesLen; m++)
					{
						selected.gotoAndStop(m + 1);
						drawItem(selected, selected.name + "_" + appendIntToString(m, 5), selected.name);
					}
				}
				else
				{
					drawItem(selected, selected.name, selected.name);
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
				
				//matrix = new Matrix();
				//matrix.tx = itm.x;
				//matrix.ty = itm.y;
				//canvasData.draw(itm, matrix);
				
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
		
		static private function drawItem(clip:MovieClip, name:String = "", baseName:String =""):TextureItem{
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
				if ((xPos + itm.width) > _canvasWidth)
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