package;

import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.ui.FlxVirtualPad;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.util.FlxSave;

class PlayState extends FlxState {
	var fire:FlxSprite;
	var ship:FlxSprite;
	var pad:FlxVirtualPad;
	var toggleBtn:FlxButton;
	var turnFs:FlxButton;
	var starsBack:FlxBackdrop;
	var starsMid:FlxBackdrop;
	var bullets:FlxTypedGroup<FlxSprite>;
	var enemies:FlxTypedGroup<FlxSprite>;

	var useTouch:Bool = false;
	var baseScrollSpeed:Float = 100;
	var enemySpeed:Float = 200;
	var spawnTimer:Float = 0;
	var speedMultiplier:Float = 1.0;
	var isBoosting:Bool = false;

	var score:Int = 0;
	var highScore:Int = 0;
	var scored:FlxText;
	var highScored:FlxText;
	var accuracyText:FlxText;

	// Stats tracking
	var totalShots:Int = 0;
	var boostHits:Int = 0;
	var normalHits:Int = 0;
	var missedShots:Int = 0;

	var gameSave:FlxSave;

	override public function create() {
		super.create();

		// Initialize save system
		gameSave = new FlxSave();
		gameSave.bind("SpaceShooterSave");
		loadGame();

		starsBack = new FlxBackdrop("assets/images/stars.png", XY);
		starsBack.velocity.set(-baseScrollSpeed * 0.4, 0);
		starsBack.color = 0xFF444444;
		add(starsBack);

		starsMid = new FlxBackdrop("assets/images/stars.png", XY);
		starsMid.velocity.set(-baseScrollSpeed * 0.8, 0);
		starsMid.color = 0xFF777777;
		add(starsMid);

		bullets = new FlxTypedGroup<FlxSprite>();
		add(bullets);

		enemies = new FlxTypedGroup<FlxSprite>();
		add(enemies);

		fire = new FlxSprite(0, 0);
		fire.loadGraphic("assets/images/fire.png", true, 85, 85);
		fire.animation.add("burn", [0, 1, 2, 3, 4, 5, 6], 12, true);
		fire.animation.play("burn");

		ship = new FlxSprite(100, FlxG.height / 2);
		ship.loadGraphic("assets/images/ship.png");
		ship.scale.set(0.565, 0.565);
		ship.updateHitbox();
		add(ship);
		add(fire);

		scored = new FlxText(10, 70, 0, "Score: 0", 28);
		add(scored);

		highScored = new FlxText(10, 100, 0, "High Score: " + highScore, 24);
		highScored.color = FlxColor.YELLOW;
		add(highScored);

		accuracyText = new FlxText(10, 125, 0, "Accuracy: 0.00% D", 24);
		accuracyText.color = FlxColor.CYAN;
		add(accuracyText);

		pad = new FlxVirtualPad(FULL, A_B);
		pad.visible = useTouch;
		pad.alpha = 0.45;
		add(pad);

		setupPad();

		toggleBtn = new FlxButton(10, 10, "", onToggle);
		add(toggleBtn);
		turnFs = new FlxButton(10, 40, "Fullscreen", goFullscreen);
		add(turnFs);
		updateButtonLabel();
		FlxG.fixedTimestep = false;
	}

	function setupPad() {
		var bScale:Float = 2.75;
		var bSize:Float = 44 * bScale;
		var padX:Float = 20;
		var padY:Float = FlxG.height - (bSize * 3) - 20;

		pad.getButton(UP).scale.set(bScale, bScale);
		pad.getButton(UP).updateHitbox();
		pad.getButton(UP).setPosition(padX + bSize, padY);

		pad.getButton(DOWN).scale.set(bScale, bScale);
		pad.getButton(DOWN).updateHitbox();
		pad.getButton(DOWN).setPosition(padX + bSize, padY + (bSize * 2));

		pad.getButton(LEFT).scale.set(bScale, bScale);
		pad.getButton(LEFT).updateHitbox();
		pad.getButton(LEFT).setPosition(padX, padY + bSize);

		pad.getButton(RIGHT).scale.set(bScale, bScale);
		pad.getButton(RIGHT).updateHitbox();
		pad.getButton(RIGHT).setPosition(padX + (bSize * 2), padY + bSize);

		pad.getButton(A).scale.set(bScale, bScale);
		pad.getButton(A).updateHitbox();
		pad.getButton(A).setPosition(FlxG.width - (bSize * 2) - 20, FlxG.height - bSize - 20);

		pad.getButton(B).scale.set(bScale, bScale);
		pad.getButton(B).updateHitbox();
		pad.getButton(B).setPosition(FlxG.width - bSize - 20, FlxG.height - (bSize * 2) - 20);
	}

	function shoot() {
		var bullet = bullets.recycle(FlxSprite);
		bullet.loadGraphic("assets/images/roles.png", true, 80, 80);
		bullet.animation.frameIndex = 0;
		bullet.reset(ship.x + ship.width - 20, ship.y + (ship.height / 2) - 40);
		bullet.velocity.x = 800;
		bullet.scale.set(0.5, 0.5);
		bullet.updateHitbox();

		totalShots++;

		if (score < 6500) {
			score -= 15;
		} else {
			score -= 15 * Std.int((score / 6500));
		}
		scored.text = 'Score: $score';
	}

	function spawnEnemy(elapsed:Float) {
		spawnTimer -= elapsed;
		if (spawnTimer <= 0) {
			var enemy = enemies.recycle(FlxSprite);
			enemy.loadGraphic("assets/images/roles.png", true, 80, 80);
			enemy.animation.frameIndex = 1;
			enemy.reset(FlxG.width + 80, FlxG.random.float(50, FlxG.height - 100));
			enemy.scale.set(0.8, 0.8);
			enemy.updateHitbox();
			spawnTimer = FlxG.random.float(0.8, 2.5);
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (score > 6500) {
			speedMultiplier = score / 5500;
		}
		spawnEnemy(elapsed);
		fire.y = ship.y + (ship.height / 2) - (fire.height / 2);
		fire.x = ship.x - 40;

		handleInput(elapsed);

		bullets.forEachAlive(function(b:FlxSprite) {
			if (b.x > FlxG.width) {
				b.kill();
				missedShots++;
				updateAccuracy();
			}
		});

		enemies.forEachAlive(function(e:FlxSprite) {
			if (e.x < -e.width)
				e.kill();
			var currentSpeed = FlxG.keys.pressed.SHIFT || (useTouch && pad.getButton(B).status == PRESSED) ? enemySpeed * 3 : enemySpeed;
			e.velocity.x = -currentSpeed * speedMultiplier;
		});

		FlxG.overlap(bullets, enemies, function(b:FlxSprite, e:FlxSprite) {
			b.kill();
			e.kill();
			FlxG.camera.shake(0.01, 0.05);
			if (isBoosting) {
				if (score < 6500) {
					score += 450;
				} else {
					score += 450 * Std.int((score / 6500));
				}
				boostHits++;
			} else {
				if (score < 6500) {
					score += 120;
				} else {
					score += 120 * Std.int((score / 6500));
				}
				normalHits++;
			}
			scored.text = 'Score: $score';
			updateAccuracy();
		});

		FlxG.overlap(ship, enemies, function(s:FlxSprite, e:FlxSprite) {
			saveHighScore();
			FlxG.switchState(MenuState.new);
		});
	}

	function handleInput(elapsed:Float) {
		var speed:Float = 300;
		ship.velocity.set(0, 0);
		isBoosting = false;
		if (useTouch) {
			if (pad.getButton(UP).status == PRESSED)
				ship.velocity.y = -speed;
			if (pad.getButton(DOWN).status == PRESSED)
				ship.velocity.y = speed;
			if (pad.getButton(LEFT).status == PRESSED)
				ship.velocity.x = -speed;
			if (pad.getButton(RIGHT).status == PRESSED)
				ship.velocity.x = speed;
			if (pad.getButton(B).status == PRESSED)
				isBoosting = true;
			if (pad.getButton(A).justPressed)
				shoot();
		} else {
			if (FlxG.keys.pressed.W)
				ship.velocity.y = -speed;
			if (FlxG.keys.pressed.S)
				ship.velocity.y = speed;
			if (FlxG.keys.pressed.A)
				ship.velocity.x = -speed;
			if (FlxG.keys.pressed.D)
				ship.velocity.x = speed;
			if (FlxG.keys.pressed.SHIFT)
				isBoosting = true;
			if (FlxG.keys.justPressed.SPACE)
				shoot();
		}

		// Keep ship in bounds
		if (ship.x < 0)
			ship.x = 0;
		if (ship.x > FlxG.width - ship.width)
			ship.x = FlxG.width - ship.width;
		if (ship.y < 0)
			ship.y = 0;
		if (ship.y > FlxG.height - ship.height)
			ship.y = FlxG.height - ship.height;

		if (isBoosting) {
			starsBack.velocity.x = -baseScrollSpeed * 2.5;
			starsMid.velocity.x = -baseScrollSpeed * 5;
			fire.animation.curAnim.frameRate = 24;
			FlxG.camera.shake(0.003, 0.05);
			if (score < 6500) {
				score += 2;
			} else {
				score += 2 * Std.int((score / 6500));
			}
			scored.text = 'Score: $score';
		} else {
			starsBack.velocity.x = -baseScrollSpeed * 0.4;
			starsMid.velocity.x = -baseScrollSpeed * 0.8;
			fire.animation.curAnim.frameRate = 12;
		}
	}

	function updateAccuracy() {
		if (totalShots == 0) {
			accuracyText.text = "Accuracy: 0.00% D";
			return;
		}

		var totalHits = boostHits + normalHits;
		var accuracy = (totalHits / totalShots) * 100;
		var rank = getRank(accuracy);

		accuracyText.text = 'Accuracy: ${Math.round(accuracy * 100) / 100}% $rank';
	}

	function getRank(accuracy:Float):String {
		if (accuracy >= 95)
			return "SSS";
		if (accuracy >= 90)
			return "SS";
		if (accuracy >= 85)
			return "S";
		if (accuracy >= 75)
			return "A";
		if (accuracy >= 65)
			return "B";
		if (accuracy >= 50)
			return "C";
		return "D";
	}

	function onToggle() {
		useTouch = !useTouch;
		pad.visible = useTouch;
		updateButtonLabel();
		saveSettings();
	}

	function goFullscreen() {
		if (!FlxG.fullscreen) {
			FlxG.fullscreen = true;
		}
	}

	function updateButtonLabel() {
		toggleBtn.text = "Touch: " + (useTouch ? "On" : "Off");
		toggleBtn.label.color = useTouch ? FlxColor.GREEN : FlxColor.RED;
	}

	function loadGame() {
		if (gameSave.data.highScore != null) {
			highScore = gameSave.data.highScore;
		}
		if (gameSave.data.useTouch != null) {
			useTouch = gameSave.data.useTouch;
		}
	}

	function saveSettings() {
		gameSave.data.useTouch = useTouch;
		gameSave.flush();
	}

	function saveHighScore() {
		if (score > highScore) {
			highScore = score;
			gameSave.data.highScore = highScore;
			gameSave.flush();
		}
	}
}
