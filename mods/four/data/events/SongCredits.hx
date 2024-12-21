import funkin.game.PlayState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;


var SongCredit:FlxSprite;

function create() {
    SongCredit = new FlxSprite();
    SongCredit.cameras = [camHUD];
    SongCredit.alpha = 0;
    add(SongCredit);
       

}

function onEvent(e:EventGameEvent){
    if (e.event.name == "SongCredits"){
        var e = e;
        SongCredit.loadGraphic(Paths.image('game/SongCredits/' + e.event.params[0]));
        SongCredit.screenCenter();
        FlxTween.tween(SongCredit, {alpha: 1}, 0.2, {startDelay: 0});
        FlxTween.tween(SongCredit, {alpha: 0}, 0.2, {startDelay: 2});
    }
}