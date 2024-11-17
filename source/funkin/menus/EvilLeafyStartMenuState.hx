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
// import Sys;

class EvilLeafyStartMenuState extends MusicBeatState {
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String> = ['Play', 'How To Play', 'Why'];
	
	var SelectionSpr:FlxSprite;

	var curSelected:Int = 0;

	override function create() {
		FlxG.sound.pause();
		SelectionSpr = new FlxSprite(0, 0).makeGraphic(FlxG.width, 40, FlxColor.WHITE);
		SelectionSpr.x = (FlxG.width - SelectionSpr.width) / 2;
		add(SelectionSpr);

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		var TitleText:FlxText = new FlxText(0, 0 + 30, 600, "The Evil Leafy Maze Game", 42, false);
		// TitleText.color = FlxColor.WHITE;
		TitleText.setFormat(Paths.font("bookantiqua_bold.ttf"), 42, FlxColor.WHITE);
		TitleText.x = (FlxG.width - 550) / 2;
		// TitleText.screenCenter(X);
		add(TitleText);

		for (i in 0...menuItems.length)
		{
			var w = 0;
			if (menuItems[i] == "Play" || menuItems[i] == "Why")
				w = 128;
			else
				w = 220;

			var songText:FlxText = new FlxText(0, 100 + (50 * i) + 30, w, menuItems[i], 12, false);
			// songText.color = FlxColor.WHITE;
			songText.setFormat(Paths.font("bookantiqua_bold.ttf"), 28, FlxColor.WHITE);
			songText.x = (FlxG.width - songText.width) / 2;
			grpMenuShit.add(songText);

		}
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed); 
		SelectionSpr.y = grpMenuShit.members[curSelected].y;


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

		if (event.cancelled) return;

		var daSelected:String = event.name;

		switch (daSelected)
		{
			case "Play":
				PlayState.loadSong("bewilderment", "normal", false, false);
				FlxG.switchState(new PlayState());
			case "How To Play":
				Sys.command('start ' + Paths.txt("HowToPlay"));

			case "Why":
				Sys.command('start ' + Paths.txt("Why"));

		}
	}


	
	function changeSelection(change:Int = 0):Void
	{
		grpMenuShit.members[curSelected].color = FlxColor.WHITE;
		var event = EventManager.get(MenuChangeEvent).recycle(curSelected, FlxMath.wrap(curSelected + change, 0, menuItems.length-1), change, change != 0);

		if (event.cancelled) return;

		curSelected = event.value;


		
		grpMenuShit.members[curSelected].color = FlxColor.BLACK;
		
	}
}