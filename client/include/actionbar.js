
function TActionBarButtonCallbackFactory(callback) {
    this.get = function(id) {
        return function () {
            callback(id);
        }
    }
}

function TActionBar(Game, start_posX, start_posY, callback, button_width) {
    this.border_margin = 40;
    this.create = function (ids) {
        var n = ids.length;
        var factory = new TActionBarButtonCallbackFactory(callback);
        
        for (var i = 0; i < parseInt(n); i++) {
            var posX = this.border_margin + (Game.world.width - 2 * this.border_margin)/n*i;
            var posY = 0;
            //alert('posx: ' + posX + ', posY: ' + posY);
            var button = Game.add.button(posX, posY, ids[i][1], factory.get(ids[i][0]), this)
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
