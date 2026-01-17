package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;
import flixel.ui.FlxVirtualPad;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSave;

class MenuState extends FlxState {
	var starsBack:FlxBackdrop;
	var starsMid:FlxBackdrop;
	var titleText:FlxText;
	var instructionsText:FlxText;
	var controlModeText:FlxText;
	var gameControlsText:FlxText;
	var highScoreText:FlxText;
	var pad:FlxVirtualPad;

	var resetSettingsBtn:FlxButton;
	var resetStatsBtn:FlxButton;

	var useTouch:Bool = true;
	var baseScrollSpeed:Float = 100;
	var gameSave:FlxSave;
	var highScore:Int = 0;

	override public function create() {
		super.create();

		// Initialize save system and load settings
		gameSave = new FlxSave();
		gameSave.bind("SpaceShooterSave");
		loadSettings();

		// Background stars
		starsBack = new FlxBackdrop("assets/images/stars.png", XY);
		starsBack.velocity.set(-baseScrollSpeed * 0.4, 0);
		starsBack.color = 0xFF444444;
		add(starsBack);

		starsMid = new FlxBackdrop("assets/images/stars.png", XY);
		starsMid.velocity.set(-baseScrollSpeed * 0.8, 0);
		starsMid.color = 0xFF777777;
		add(starsMid);

		// Title
		titleText = new FlxText(0, FlxG.height * 0.15, FlxG.width, "CuteDefender :3", 64);
		titleText.alignment = CENTER;
		titleText.color = FlxColor.PINK;
		titleText.setBorderStyle(OUTLINE, FlxColor.WHITE, 3);
		add(titleText);

		// High Score
		highScoreText = new FlxText(0, FlxG.height * 0.3, FlxG.width, "High Score: " + highScore, 36);
		highScoreText.alignment = CENTER;
		highScoreText.color = FlxColor.YELLOW;
		highScoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		add(highScoreText);

		// Control mode indicator
		controlModeText = new FlxText(0, FlxG.height * 0.45, FlxG.width, "", 32);
		controlModeText.alignment = CENTER;
		add(controlModeText);

		// Game controls display
		gameControlsText = new FlxText(0, FlxG.height * 0.55, FlxG.width, "", 24);
		gameControlsText.alignment = CENTER;
		gameControlsText.color = FlxColor.CYAN;
		add(gameControlsText);

		// Menu instructions
		instructionsText = new FlxText(0, FlxG.height * 0.75, FlxG.width, "", 28);
		instructionsText.alignment = CENTER;
		instructionsText.color = FlxColor.YELLOW;
		add(instructionsText);

		// Reset buttons
		resetSettingsBtn = new FlxButton(10, 10, "Reset Settings", onResetSettings);
		resetSettingsBtn.label.size = 12;
		add(resetSettingsBtn);

		resetStatsBtn = new FlxButton(10, 45, "Reset Stats", onResetStats);
		resetStatsBtn.label.size = 12;
		add(resetStatsBtn);

		// Virtual pad
		pad = new FlxVirtualPad(NONE, A_B_C);
		pad.visible = useTouch;
		pad.alpha = 0.45;
		add(pad);

		setupPad();
		updateTexts();

		FlxG.fixedTimestep = false;
	}

	function setupPad() {
		var bScale:Float = 2.75;
		var bSize:Float = 44 * bScale;
		var rightX:Float = FlxG.width - (bSize * 2) - 20;
		var bottomY:Float = FlxG.height - (bSize * 3) - 20;

		// A button - bottom right
		pad.getButton(A).scale.set(bScale, bScale);
		pad.getButton(A).updateHitbox();
		pad.getButton(A).setPosition(rightX + bSize, bottomY + (bSize * 2));

		// B button - middle right
		pad.getButton(B).scale.set(bScale, bScale);
		pad.getButton(B).updateHitbox();
		pad.getButton(B).setPosition(rightX + bSize, bottomY + bSize);

		// C button - top right
		pad.getButton(C).scale.set(bScale, bScale);
		pad.getButton(C).updateHitbox();
		pad.getButton(C).setPosition(rightX + bSize, bottomY);
	}

	function updateTexts() {
		// Update control mode text
		controlModeText.text = "Control Mode: " + (useTouch ? "TOUCH" : "KEYBOARD");
		controlModeText.color = useTouch ? FlxColor.GREEN : FlxColor.ORANGE;

		// Update game controls based on mode
		if (useTouch) {
			gameControlsText.text = "Game Controls:\nD-Pad - Move | A - Shoot | B - Boost";
		} else {
			gameControlsText.text = "Game Controls:\nWASD - Move | SPACE - Shoot | SHIFT - Boost";
		}

		// Update menu instructions based on mode
		if (useTouch) {
			instructionsText.text = "A - Start Game\nB - Toggle Controls\nC - Fullscreen";
		} else {
			instructionsText.text = "SPACE - Start Game\nSHIFT - Toggle Controls\nCTRL - Fullscreen";
		}

		// Update high score display
		highScoreText.text = "High Score: " + highScore;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		// Handle input
		var startPressed = false;
		var togglePressed = false;
		var fullscreenPressed = false;

		if (useTouch) {
			if (pad.getButton(A).justPressed)
				startPressed = true;
			if (pad.getButton(B).justPressed)
				togglePressed = true;
			if (pad.getButton(C).justPressed)
				fullscreenPressed = true;
		} else {
			if (FlxG.keys.justPressed.SPACE)
				startPressed = true;
			if (FlxG.keys.justPressed.SHIFT)
				togglePressed = true;
			if (FlxG.keys.justPressed.CONTROL)
				fullscreenPressed = true;
		}

		// Start game
		if (startPressed) {
			FlxG.switchState(PlayState.new);
		}

		// Toggle control mode
		if (togglePressed) {
			useTouch = !useTouch;
			pad.visible = useTouch;
			updateTexts();
			saveSettings();
		}

		// Fullscreen - try multiple methods
		if (fullscreenPressed) {
			if (!FlxG.fullscreen) {
				FlxG.fullscreen = true;
			}
		}
	}

	function onResetSettings() {
		useTouch = true;
		pad.visible = useTouch;
		gameSave.data.useTouch = useTouch;
		gameSave.flush();
		updateTexts();
	}

	function onResetStats() {
		highScore = 0;
		gameSave.data.highScore = 0;
		gameSave.flush();
		updateTexts();
	}

	function loadSettings() {
		if (gameSave.data.useTouch != null) {
			useTouch = gameSave.data.useTouch;
		}
		if (gameSave.data.highScore != null) {
			highScore = gameSave.data.highScore;
		}
	}

	function saveSettings() {
		gameSave.data.useTouch = useTouch;
		gameSave.flush();
	}
}
