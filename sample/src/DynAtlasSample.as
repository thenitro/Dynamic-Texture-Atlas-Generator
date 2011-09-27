package {
	
	import com.emibap.textureAtlas.DynamicAtlas;
	import starling.core.Starling;
	
	import starling.display.MovieClip;
	
	import starling.textures.TextureAtlas;
	import starling.display.Sprite;

	public class DynAtlasSample extends Sprite{
		
		public function DynAtlasSample(){
			super();
			init();
		}
		
		private function init():void{
			var mc:SheetMC = new SheetMC();
			try {
				
				var atlas:TextureAtlas = DynamicAtlas.fromMovieClipContainer(mc);
				trace("atlas:", atlas);
				var mario_mc:MovieClip = new MovieClip(atlas.getTextures("mario"));
				addChild(mario_mc);
				mario_mc.x = mario_mc.y = 50;
				Starling.juggler.add(mario_mc);
				
			} catch (e:Error) {
				trace("There was an error in the creation of the texture Atlas. Please check if the dimensions of your clip exceeded the maximun allowed texture size. -", e.message);
			}
		}
	}
}