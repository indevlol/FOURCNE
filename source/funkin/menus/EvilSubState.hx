package funkin.menus;

import funkin.editors.charter.Charter;
import funkin.backend.scripting.events.MenuChangeEvent;
import funkin.options.OptionsMenu;
import funkin.backend.scripting.events.PauseCreationEvent;
import funkin.backend.scripting.events.NameEvent;
import funkin.backend.scripting.Script;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.options.keybinds.KeybindsOptions;
import funkin.menus.StoryMenuState;
import funkin.backend.utils.FunkinParentDisabler;

class EvilSubState extends MusicBeatSubstate
{
	public static var script:String = "";

	var grpMenuShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Controls', 'Change Options', 'Exit to menu', "Exit to charter"];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public var pauseScript:Script;

	public var game:PlayState = PlayState.instance; // shortcut

	private var __cancelDefault:Bool = false;

	public function new(x:Float = 0, y:Float = 0) {
		super();
	}

	var SelectionSpr:FlxSprite;

	var parentDisabler:FunkinParentDisabler;
	override function create()
	{
		super.create();

		if (menuItems.contains("Exit to charter") && !PlayState.chartingMode)
			menuItems.remove("Exit to charter");

		add(parentDisabler = new FunkinParentDisabler());

		pauseScript = Script.create(Paths.script(script));
		pauseScript.setParent(this);
		pauseScript.load();

		var event = EventManager.get(PauseCreationEvent).recycle('breakfast', menuItems);
		pauseScript.call('create', [event]);

		menuItems = event.options;


		pauseMusic = FlxG.sound.load(Paths.music(event.music), 0, true);
		pauseMusic.persist = false;
		pauseMusic.group = FlxG.sound.defaultMusicGroup;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		if (__cancelDefault = event.cancelled) return;

		var bg:FlxSprite = new FlxSprite().makeSolid(FlxG.width + 100, FlxG.height + 100, FlxColor.BLACK);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);


		SelectionSpr = new FlxSprite(0, 0).makeGraphic(FlxG.width, 20, FlxColor.WHITE);
		SelectionSpr.x = (FlxG.width - SelectionSpr.width) / 2;
		add(SelectionSpr);

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		var TitleText:FlxText = new FlxText(0, 0 + 30, 500, "The Evil Leafy Maze Game", 28, false);
		TitleText.color = FlxColor.RED;
		TitleText.x = (FlxG.width - TitleText.width) / 2;
		add(TitleText);

		for (i in 0...menuItems.length)
		{
			var w = 0;
			if (menuItems[i] == "Resume")
				w = 128;
			else
				w = 160;

			var songText:FlxText = new FlxText(0, 100 + (50 * i) + 30, w, menuItems[i], 12, false);
			songText.color = FlxColor.RED;
			songText.x = (FlxG.width - songText.width) / 2;
			grpMenuShit.add(songText);

		}


		changeSelection();

		camera = new FlxCamera();
		camera.bgColor = 0;
		FlxG.cameras.add(camera, false);

		pauseScript.call("postCreate");

		game.updateDiscordPresence();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		SelectionSpr.y = grpMenuShit.members[curSelected].y;

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		pauseScript.call("update", [elapsed]);

		if (__cancelDefault) return;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);
		if (accepted)
			selectOption();
	}

	public function selectOption() {
		var event = EventManager.get(NameEvent).recycle(menuItems[curSelected]);
		pauseScript.call("onSelectOption", [event]);

		if (event.cancelled) return;

		var daSelected:String = event.name;

		switch (daSelected)
		{
			case "Resume":
				close();
			case "Restart Song":
				parentDisabler.reset();
				game.registerSmoothTransition();
				FlxG.resetState();
			case "Change Controls":
				persistentDraw = false;
				openSubState(new KeybindsOptions());
			case "Change Options":
				FlxG.switchState(new OptionsMenu());
			case "Exit to charter":
				FlxG.switchState(new funkin.editors.charter.Charter(PlayState.SONG.meta.name, PlayState.difficulty, false));
			case "Exit to menu":
				if (PlayState.chartingMode && Charter.undos.unsaved)
					game.saveWarn(false);
				else {
					PlayState.resetSongInfos();
					if (Charter.instance != null) Charter.instance.__clearStatics();

					CoolUtil.playMenuSong();
					FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
				}

		}
	}
	override function destroy()
	{
		if(FlxG.cameras.list.contains(camera))
			FlxG.cameras.remove(camera, true);
		pauseScript.call("destroy");
		pauseScript.destroy();

		if (pauseMusic != null)
			@:privateAccess {
				FlxG.sound.destroySound(pauseMusic);
			}

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		var event = EventManager.get(MenuChangeEvent).recycle(curSelected, FlxMath.wrap(curSelected + change, 0, menuItems.length-1), change, change != 0);
		pauseScript.call("onChangeItem", [event]);
		if (event.cancelled) return;

		curSelected = event.value;

	}
}