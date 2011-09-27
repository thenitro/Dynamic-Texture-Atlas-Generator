Dynamic Texture Atlas Generator (Starling framework Extension)
========

# version 0.7 #

This tool will convert any MovieClip containing Other MovieClips, Sprites or Graphics into a starling Texture Atlas, all in runtime. 
By using it, you won't have to statically create your spritesheets. Just take a regular MovieClip containing all the display objects you wish to put into your Altas, and convert everything from vectors to bitmap textures. 
This extension could save you a lot of time specially if you'll be coding mobile apps with the [starling framework](http://www.starling-framework.org/).

### Features ###

* Dynamic creation of a Texture Altas from a MovieClip (flash.display.MovieClip) container that could act as a sprite sheet
* Filters made to the objects are captured
* Automatically detects the objects bounds so you don't necesarily have to set the registration points to TOP LEFT

### TODO List ###

* Scaling all the objects based on a parameter before taking snapshots (for optimal memory usage)
* Further code optimization
* Documentation (?)

### Whish List ###
* Optional division of the process into small intervals (for smooth performance of the app)

### Usage ###
	Use the static method DynamicAtlas.fromMovieClipContainer.
	
	DynamicAtlas.fromMovieClipContainer(swf:flash.display.MovieClip):starling.textures.TextureAtlas
	
	Params:
		* swf:flash.display.MovieClip - The MovieClip sprite sheet you wish to convert into a TextureAtlas. It should contain named instances of all the MovieClips that will become the subtextures of your Atlas.
	
	Returns:
		* A TextureAtlas.
		
	Enclose inside a try/catch for error handling:
		try {
				var atlas:TextureAtlas = DynamicAtlas.fromMovieClipContainer(mc);
			} catch (e:Error) {
				trace("There was an error in the creation of the texture Atlas. Please check if the dimensions of your clip exceeded the maximun allowed texture size. -", e.message);
			}

### Steps to make your own Dynamic Texture Atlas ###
#### Base Sprite sheet creation (Inside Flash IDE) ####
Create a new fla and make sure it is minimum flash 9 using as3.
Start creating movieclips that you want to be written to a sprite sheet. Be sure to avoid using actionscript, and if you have sub clips use graphics as opposed to movieclips so that they get picked up.
Drag all the movieclips you want rendered to the main stage and name them.
Export the swf.

You can also drag all the MovieClips inside another Clip and assign a class to it if you prefer not to load an external swf.

#### TextureAtlas conversion ####
Load the sprite sheet swf or create an instance of it as a MovieClip
Use the DynamicAtlas.fromMovieClipContainer() static method to convert your flash.display.MovieClip to a starling.textures.TextureAtlas.
(don't forget to destroy your now useless MovieClip)

### Using the sample included in the package ###
The sample included is a simple FlashDevelop project which uses a library item as base MovieClip to create a TextureAtlas at runtime.
If you plan to use it, you need to add the Classpaths of your copy of the starling framework and of this extension (dynamicTextureAtlasGenerator).
#### Requirements ####
Please refer to the [starling documentation](http://doc.starling-framework.org/core/) or to the [starling tutorial](http://www.bytearray.org/?p=3371) for requirements and setup.

This project began as a fork of the [Texture Atlas Generator](https://github.com/pixelrevision/texture_atlas_generator) by pixelrevision