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

	var menuItems:Array<String> = ['Resume', 'Main Menu'];
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
		bg.alpha = 0.5;
		add(bg);


		SelectionSpr = new FlxSprite(0, 0).makeGraphic(FlxG.width, 40, FlxColor.WHITE);
		SelectionSpr.x = (FlxG.width - SelectionSpr.width) / 2;
		add(SelectionSpr);

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		var TitleText:FlxText = new FlxText(0, 0 + 30, 500, "Pause", 42, false);
		// TitleText.color = FlxColor.WHITE;
		TitleText.setFormat(Paths.font("bookantiqua_bold.ttf"), 42, FlxColor.WHITE);
		TitleText.x = (FlxG.width - 130) / 2;
		// TitleText.screenCenter(X);
		add(TitleText);

		for (i in 0...menuItems.length)
		{
			var w = 0;
			if (menuItems[i] == "Resume")
				w = 128;
			else
				w = 160;

			var songText:FlxText = new FlxText(0, 100 + (50 * i) + 30, w, menuItems[i], 12, false);
			// songText.color = FlxColor.WHITE;
			songText.setFormat(Paths.font("bookantiqua_bold.ttf"), 28, FlxColor.WHITE);
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
			case "Main Menu":
				FlxG.switchState(new MainMenuState());

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
		grpMenuShit.members[curSelected].color = FlxColor.WHITE;
		var event = EventManager.get(MenuChangeEvent).recycle(curSelected, FlxMath.wrap(curSelected + change, 0, menuItems.length-1), change, change != 0);
		pauseScript.call("onChangeItem", [event]);
		if (event.cancelled) return;

		curSelected = event.value;


		
		grpMenuShit.members[curSelected].color = FlxColor.BLACK;
		
		// if (curSelected == 0) {
		// 	grpMenuShit.members[curSelected + 1].color = FlxColor.WHITE;
		// }
		// else if (curSelected == grpMenuShit.members.length - 1) {
		// 	grpMenuShit.members[curSelected - 1].color = FlxColor.WHITE;
		// } else {
		// 	grpMenuShit.members[curSelected + 1].color = FlxColor.WHITE;
		// 	grpMenuShit.members[curSelected + 1].color = FlxColor.WHITE;
		// }
	}
}