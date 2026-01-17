package;

import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.system.System;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

// WHO THOUGHT A HF SMALL GAME WILL HAVE SUCH BIG ENTRY POINT FILE.
class Main extends Sprite {
	private var fpsCounter:FPS;
	private var infoText:TextField;

	public function new() {
		super();
		addChild(new FlxGame(0, 0, MenuState));

		var format = new TextFormat("_sans", 12, 0xFFFFFF);
		format.align = TextFormatAlign.RIGHT;

		fpsCounter = new FPS(10, 10, 0xFFFFFF);
		fpsCounter.defaultTextFormat = format;
		fpsCounter.width = 200;
		addChild(fpsCounter);

		infoText = new TextField();
		infoText.selectable = false;
		infoText.mouseEnabled = false;
		infoText.defaultTextFormat = format;
		infoText.width = 200;
		infoText.height = 50;
		infoText.multiline = true;
		addChild(infoText);

		addEventListener(Event.ENTER_FRAME, updateStats);
		addEventListener(Event.RESIZE, onResize);

		onResize(null);
	}

	private function updateStats(e:Event):Void {
		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
		var ver:String = Std.string(Lib.application.meta.get('version'));

		infoText.text = "MEM: " + mem + " MB\nVER: v" + ver;
	}

	private function onResize(e:Event):Void {
		var stageWidth = Lib.current.stage.stageWidth;
		var margin = 10;

		fpsCounter.x = stageWidth - fpsCounter.width - margin;
		fpsCounter.y = margin;

		infoText.x = stageWidth - infoText.width - margin;
		infoText.y = fpsCounter.y + 15;
	}
}
