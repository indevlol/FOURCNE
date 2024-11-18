package funkin.menus;

import funkin.savedata.FunkinSave;
import haxe.io.Path;
import funkin.backend.scripting.events.*;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.backend.FunkinText;
import haxe.xml.Access;
import flixel.text.FlxText;

class StoryMenuState extends MusicBeatState {

	//public var charFrames:Map<String, FlxFramesCollection> = [];
	public var lerpScore:Float = 0;
	public var intendedScore:Int = 0;

	public var curWeek:Int = 0;

	public var canSelect:Bool = true;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var selectThing:FlxSprite;

	var thumbnails:FlxTypedGroup<FlxSprite>;

	public var weeks:Array<WeekData> = [];

	public override function create() {
		loadXMLs();
		super.create();

		persistentUpdate = persistentDraw = true;

		// // // WEEK INFO
		// // blackBar = new FlxSprite(0, 0).makeSolid(FlxG.width, 56, 0xFFFFFFFF);
		// // blackBar.color = 0xFF000000;
		// // blackBar.updateHitbox();

		// // weekTitle = new FlxText(10, 10, FlxG.width - 20, "", 32);
		// // weekTitle.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// // weekTitle.alpha = 0.7;

		// // DUMBASS ARROWS
		// var assets = Paths.getFrames('menus/storymenu/assets');
		// var directions = ["left", "right"];

		//1280 / 2 = 640 / 2 = 320 * 3 = 960
		leftArrow = new FlxSprite(100, 500).loadGraphic(Paths.image("game/menus/story/arrow"));
		rightArrow = new FlxSprite(700, 500).loadGraphic(Paths.image("game/menus/story/arrow"));
		leftArrow.angle += 180;

		selectThing = new FlxSprite(-400, -200).loadGraphic(Paths.image("game/menus/story/select"));
		selectThing.scale.x = 0.5;
		selectThing.scale.y = 0.5;
		add(selectThing);

		for(k=>arrow in [leftArrow, rightArrow]) {
			arrow.scale.x = 0.8;
			arrow.scale.y = 0.8;
			// var dir = directions[k];

			// arrow.frames = assets;
			// arrow.animation.addByPrefix('idle', 'arrow $dir');
			// arrow.animation.addByPrefix('press', 'arrow push $dir', 24, false);
			// arrow.animation.play('idle');
			// arrow.antialiasing = true;
			add(arrow);
		}

		thumbnails = new FlxTypedGroup<FlxSprite>();
		add(thumbnails);

		for(i=>week in weeks) {
			var thumbnail:FlxSprite = new FlxSprite(-185 + (i * 600), -100 - (i * 10)).loadGraphic(Paths.image('game/menus/story/thumbnails/${week.sprite}'));
			thumbnail.scale.x = 0.5 - (i / 4);
			thumbnail.scale.y = 0.5 - (i / 4);
			thumbnails.add(thumbnail);
		}

		changeWeek(0, true);

		DiscordUtil.call("onMenuLoaded", ["Story Menu"]);
		CoolUtil.playMenuSong();
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		lerpScore = lerp(lerpScore, intendedScore, 0.5);
		//scoreText.text = 'SCORE:${Math.round(lerpScore)}';

		if (canSelect) {
			// if (leftArrow != null && leftArrow.exists) leftArrow.animation.play(controls.LEFT ? 'press' : 'idle');
			// if (rightArrow != null && rightArrow.exists) rightArrow.animation.play(controls.RIGHT ? 'press' : 'idle');

			if (controls.BACK) {
				goBack();
			}

			//changeDifficulty((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
			changeWeek((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));

			if (controls.ACCEPT)
				selectWeek();

		} else {
			// for(e in [leftArrow, rightArrow])
			// 	if (e != null && e.exists)
			// 		e.animation.play('idle');
		}
	}

	public function goBack() {
		var event = event("onGoBack", new CancellableEvent());
		if (!event.cancelled)
			FlxG.switchState(new MainMenuState());
	}

	public function changeWeek(change:Int, force:Bool = false) {
		if (change == -1) {
			thumbnails.members[curWeek].x = -1000;
			thumbnails.members[curWeek].y = 0;
		}
		else if (change == 1) {
			if (curWeek < thumbnails.members.length) {
				thumbnails.members[curWeek + 1].x = -185 + (thumbnails.members.indexOf(thumbnails.members[curWeek]) * 400);
				thumbnails.members[curWeek + 1].y = -100 - (thumbnails.members.indexOf(thumbnails.members[curWeek]) * 10);
				thumbnails.members[curWeek + 1].scale.x = 0.3;
				thumbnails.members[curWeek + 1].scale.y = 0.3;
			}
			// 		thumbnails.members[curWeek].alpha = 0.8 - (thumbnails.members.indexOf(thumbnails.members[curWeek]) / 6);
		} 

		
		
		if (change == 0 && !force) return;
		
		var event = event("onChangeWeek", EventManager.get(MenuChangeEvent).recycle(curWeek, FlxMath.wrap(curWeek + change, 0, weeks.length-1), change));
		if (event.cancelled) return;
		curWeek = event.value;
		trace(curWeek);

		if (!force) CoolUtil.playMenuSFX();

		thumbnails.members[curWeek].x = -185;
		thumbnails.members[curWeek].y = -100;
		thumbnails.members[curWeek].scale.x = 0.5;
		thumbnails.members[curWeek].scale.y = 0.5;
		thumbnails.members[curWeek].alpha = 1;
	

		// for(k=>e in weekSprites.members) {
		// 	e.targetY = k - curWeek;
		// }
		// // tracklist.text = 'TRACKS\n\n${[for(e in weeks[curWeek].songs) if (!e.hide) e.name.toUpperCase()].join('\n')}';
		// weekTitle.text = weeks[curWeek].name.getDefault("");

		// changeDifficulty(0, true);

		MemoryUtil.clearMinor();
	}

	// public function changeDifficulty(change:Int, force:Bool = false) {
	// 	if (change == 0 && !force) return;

	// 	var event = event("onChangeDifficulty", EventManager.get(MenuChangeEvent).recycle(curDifficulty, FlxMath.wrap(curDifficulty + change, 0, weeks[curWeek].difficulties.length-1), change));
	// 	if (event.cancelled) return;
	// 	curDifficulty = event.value;

	// 	if (__oldDiffName != (__oldDiffName = weeks[curWeek].difficulties[curDifficulty].toLowerCase())) {
	// 		for(e in difficultySprites) e.visible = false;

	// 		var diffSprite = difficultySprites[__oldDiffName];
	// 		if (diffSprite != null) {
	// 			diffSprite.visible = true;

	// 			if (__lastDifficultyTween != null)
	// 				__lastDifficultyTween.cancel();
	// 			diffSprite.alpha = 0;
	// 			diffSprite.y = leftArrow.y - 15;

	// 			__lastDifficultyTween = FlxTween.tween(diffSprite, {y: leftArrow.y, alpha: 1}, 0.07);
	// 		}
	// 	}

	// 	intendedScore = FunkinSave.getWeekHighscore(weeks[curWeek].name, weeks[curWeek].difficulties[curDifficulty]).score;
	// }

	public function loadXMLs() {
		// CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		var weeks:Array<String> = [];
		if (getWeeksFromSource(weeks, MODS))
			getWeeksFromSource(weeks, SOURCE);

		for(k=>weekName in weeks) {
			var week:Access = null;
			try {
				week = new Access(Xml.parse(Assets.getText(Paths.xml('weeks/weeks/$weekName'))).firstElement());
			} catch(e) {
				Logs.trace('Cannot parse week "$weekName.xml": ${Std.string(e)}`', ERROR);
			}

			if (week == null) continue;

			if (!week.has.name) {
				Logs.trace('Story Menu: Week at index ${k} has no name. Skipping...', WARNING);
				continue;
			}
			var weekObj:WeekData = {
				name: week.att.name,
				id: weekName,
				sprite: week.getAtt('sprite').getDefault(weekName),
				chars: [null, null, null],
				songs: [],
				difficulties: ['easy', 'normal', 'hard']
			};

			var diffNodes = week.nodes.difficulty;
			if (diffNodes.length > 0) {
				var diffs:Array<String> = [];
				for(e in diffNodes) {
					if (e.has.name) diffs.push(e.att.name);
				}
				if (diffs.length > 0)
					weekObj.difficulties = diffs;
			}

			if (week.has.chars) {
				for(k=>e in week.att.chars.split(",")) {
					if (e.trim() == "" || e == "none" || e == "null")
						weekObj.chars[k] = null;
					else {
						// addCharacter(weekObj.chars[k] = e.trim());
					}
				}
			}
			for(k2=>song in week.nodes.song) {
				if (song == null) continue;
				try {
					var name = song.innerData.trim();
					if (name == "") {
						Logs.trace('Story Menu: Song at index ${k2} in week ${weekObj.name} has no name. Skipping...', WARNING);
						continue;
					}
					weekObj.songs.push({
						name: name,
						hide: song.getAtt('hide').getDefault('false') == "true"
					});
				} catch(e) {
					Logs.trace('Story Menu: Song at index ${k2} in week ${weekObj.name} cannot contain any other XML nodes in its name.', WARNING);
					continue;
				}
			}
			if (weekObj.songs.length <= 0) {
				Logs.trace('Story Menu: Week ${weekObj.name} has no songs. Skipping...', WARNING);
				continue;
			}
			this.weeks.push(weekObj);
		}
	}

	// public function addCharacter(charName:String) {
	// 	var char:Access = null;
	// 	try {
	// 		char = new Access(Xml.parse(Assets.getText(Paths.xml('weeks/characters/$charName'))).firstElement());
	// 	} catch(e) {
	// 		Logs.trace('Story Menu: Cannot parse character "$charName.xml": ${Std.string(e)}`', ERROR);
	// 	}
	// 	if (char == null) return;

	// 	if (characters[charName] != null) return;
	// 	var charObj:MenuCharacter = {
	// 		spritePath: Paths.image(char.getAtt('sprite').getDefault('menus/storymenu/characters/${charName}')),
	// 		scale: Std.parseFloat(char.getAtt('scale')).getDefault(1),
	// 		xml: char,
	// 		offset: FlxPoint.get(
	// 			Std.parseFloat(char.getAtt('x')).getDefault(0),
	// 			Std.parseFloat(char.getAtt('y')).getDefault(0)
	// 		)
	// 	};
	// 	characters[charName] = charObj;
	// }

	public function getWeeksFromSource(weeks:Array<String>, source:funkin.backend.assets.AssetsLibraryList.AssetSource) {
		var path:String = Paths.txt('freeplaySonglist');
		var weeksFound:Array<String> = [];
		if (Paths.assetsTree.existsSpecific(path, "TEXT", source)) {
			var trim = "";
			weeksFound = CoolUtil.coolTextFile(Paths.txt('weeks/weeks'));
		} else {
			weeksFound = [for(c in Paths.getFolderContent('data/weeks/weeks/', false, source)) if (Path.extension(c).toLowerCase() == "xml") Path.withoutExtension(c)];
		}

		if (weeksFound.length > 0) {
			for(s in weeksFound)
				weeks.push(s);
			return false;
		}
		return true;
	}

	// public override function destroy() {
	// 	super.destroy();
	// 	for(e in characters)
	// 		if (e != null && e.offset != null)
	// 			e.offset.put();
	// }

	public function selectWeek() {
		var event = event("onWeekSelect", EventManager.get(WeekSelectEvent).recycle(weeks[curWeek], weeks[curWeek].difficulties[1], curWeek, 1));
		if (event.cancelled) return;

		canSelect = false;
		CoolUtil.playMenuSFX(CONFIRM);

		// for(char in characterSprites)
		// 	if (char.animation.exists("confirm"))
		// 		char.animation.play("confirm");

		PlayState.loadWeek(weeks[curWeek], weeks[curWeek].difficulties[1]);

		// new FlxTimer().start(1, function(tmr:FlxTimer)
		// {
		// 	FlxG.switchState(new PlayState());
		// });
		// weekSprites.members[curWeek].startFlashing();
	}
}

typedef WeekData = {
	var name:String;
	var id:String;
	var sprite:String;
	var chars:Array<String>;
	var songs:Array<WeekSong>;
	var difficulties:Array<String>;
}

typedef WeekSong = {
	var name:String;
	var hide:Bool;
}

typedef MenuCharacter = {
	var spritePath:String;
	var xml:Access;
	var scale:Float;
	var offset:FlxPoint;
	// var frames:FlxFramesCollection;
}

class MenuCharacterSprite extends FlxSprite
{
	public var character:String;

	var pos:Int;

	public function new(pos:Int) {
		super(0, 70);
		this.pos = pos;
		visible = false;
		antialiasing = true;
	}

	public var oldChar:MenuCharacter = null;

	public function changeCharacter(data:MenuCharacter) {
		visible = (data != null);
		if (!visible)
			return;

		if (oldChar != (oldChar = data)) {
			CoolUtil.loadAnimatedGraphic(this, data.spritePath);
			for(e in data.xml.nodes.anim) {
				if (e.getAtt("name") == "idle")
					animation.remove("idle");

				XMLUtil.addXMLAnimation(this, e);
			}
			animation.play("idle");
			scale.set(data.scale, data.scale);
			updateHitbox();
			offset.x += data.offset.x;
			offset.y += data.offset.y;

			x = (FlxG.width * 0.25) * (1 + pos) - 150;
		}
	}
}
class MenuItem extends FlxSprite
{
	public var targetY:Float = 0;

	public function new(x:Float, y:Float, path:String)
	{
		super(x, y);
		CoolUtil.loadAnimatedGraphic(this, Paths.image(path, null, true));
		screenCenter(X);
		antialiasing = true;
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	// var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	// hi ninja muffin
	// i have found a more efficient way
	// dw, judging by how week 7 looked you prob know how to do maths
	// goodbye
	var time:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		time += elapsed;
		y = CoolUtil.fpsLerp(y, (targetY * 120) + 480, 0.17);

		if (isFlashing)
			color = (time % 0.1 > 0.05) ? FlxColor.WHITE : 0xFF33ffff;
	}
}
