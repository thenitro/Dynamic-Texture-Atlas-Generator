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
			//try {
				var atlas:TextureAtlas = DynamicAtlas.fromMovieClipContainer(mc, 3);
				trace("atlas:", atlas);
				//var mario_mc:MovieClip = new MovieClip(atlas.getTextures("mario"));
				//var morph_mc:MovieClip = new MovieClip(atlas.getTextures("morph"));
				var quad_mc:MovieClip = new MovieClip(atlas.getTextures("quad"));
				var quad2_mc:MovieClip = new MovieClip(atlas.getTextures("chicoquad"));
				//mario_mc.x = mario_mc.y = 20;
				//morph_mc.x = morph_mc.y = 50;
				quad_mc.x = quad_mc.y = 10;
				quad2_mc.x = quad2_mc.y = 100;
				//addChild(mario_mc);
				//addChild(morph_mc);
				addChild(quad_mc);
				addChild(quad2_mc);
				//Starling.juggler.add(mario_mc);
				//Starling.juggler.add(morph_mc);
				
			//} catch (e:Error) {
				//trace("There was an error in the creation of the texture Atlas. Please check if the dimensions of your clip exceeded the maximun allowed texture size. -", e.message);
			//}
		}
	}
}