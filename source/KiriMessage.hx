import flixel.FlxG;
import flixel.addons.ui.FlxUISubState;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIAssets;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;

class KiriMessage extends FlxUISubState {
	var titleStr:String;
	var message:String;
	var yesAction:Void->Void;
	var noAction:Void->Void;

	public function new(title:String, message:String, yesAction:Void->Void, noAction:Void->Void) {
		super();
		this.titleStr = title;
		this.message = message;
		this.yesAction = yesAction;
		this.noAction = noAction;
	}

	override public function create():Void {
		super.create();

		var bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		add(bg);

		var boxWidth = 300;
		var boxHeight = 180;
		var boxX = Std.int((FlxG.width - boxWidth) / 2);
		var boxY = Std.int((FlxG.height - boxHeight) / 2);

		var boxBg = new FlxUI9SliceSprite(boxX, boxY, FlxUIAssets.IMG_CHROME, new Rectangle(0, 0, boxWidth, boxHeight), [6, 6, 12, 12]);
		add(boxBg);

		var titleText = new FlxUIText(boxX + 10, boxY + 15, boxWidth - 20, titleStr);
		titleText.setFormat(null, 16, FlxColor.WHITE, CENTER);
		titleText.bold = true;
		add(titleText);

		var msgText = new FlxUIText(boxX + 20, boxY + 60, boxWidth - 40, message);
		msgText.setFormat(null, 12, FlxColor.WHITE, CENTER);
		add(msgText);

		var yesBtn = new FlxUIButton(boxX + 40, boxY + 125, "Yes", function() {
			yesAction();
			close();
		});
		add(yesBtn);

		var noBtn = new FlxUIButton(boxX + boxWidth - 100, boxY + 125, "No", function() {
			noAction();
			close();
		});
		add(noBtn);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE) {
			noAction();
			close();
		}
	}
}
