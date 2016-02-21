
function TActionBarButtonCallbackFactory(callback) {
    this.get = function(id) {
        return function () {
            callback(id);
        }
    }
}

function TActionBar(Game, GameWorld, callback, buttonWidth) {
    this.border_margin = 40;
    this.create = function (ids) {
        var actionBarHeight = GameWorld.GetActionBarHeight();
        var graphics = Game.add.graphics(0, 0);
        graphics.beginFill(0x000000, 0.5); // black rounded rect -- background for buttons
        var rect = graphics.drawRoundedRect(GameWorld.GetFieldX(), window.innerHeight - actionBarHeight, 
                                            GameWorld.GetFieldSizeX() , actionBarHeight);
        rect.fixedToCamera = true;

        var n = ids.length;
        var factory = new TActionBarButtonCallbackFactory(callback);
        var start_posX = Game.width / 2 - buttonWidth * n / 2;

        for (var i = 0; i < parseInt(n); i++) {
            var posX = start_posX + buttonWidth * i;
            var posY = window.innerHeight - actionBarHeight;
            var button = Game.add.button(posX, posY, ids[i][1], factory.get(ids[i][0]), this);
            button.fixedToCamera = true;
        }
    }
}

/*
function AlertManager (id) {
    alert('Clicked on ' + id);
}

*/
/* Usage:

 var actionbar = new ActionBar(0,0, AlertManager, 128);
 actionbar.create([['first','button1'], ['second', 'button2'], ['third', 'button3']]);
*/
