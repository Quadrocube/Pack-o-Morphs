
function TActionBarButtonCallbackFactory(callback) {
    this.get = function(id) {
        return function () {
            callback(id);
        }
    }
}

function TActionBar(Game, GameWorld, callback, button_width) {
    this.border_margin = 40;
    this.create = function (ids) {
        var n = ids.length;
        var factory = new TActionBarButtonCallbackFactory(callback);
        var start_posX = Game.width / 2 - button_width * n / 2;
        for (var i = 0; i < parseInt(n); i++) {
            var posX = start_posX + button_width * i;
            var posY = Game.height - button_width;
            //alert('posx: ' + posX + ', posY: ' + posY);
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
