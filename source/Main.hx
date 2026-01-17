package;

import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.display.FPS;
import openfl.Lib;

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(0, 0, MenuState));

		var fps = new FPS(Lib.current.stage.stageWidth - 70, 10, 0xFFFFFF);
		addChild(fps);
	}
}
