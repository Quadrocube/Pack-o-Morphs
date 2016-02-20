
function ActionBarButtonCallbackFactory(callback) {
    this.get = function(id) {
        return function () {
            callback(id);
        }
    }
}

function ActionBar(start_posX, start_posY, callback) {
    border_margin = 40,
    button_width = 128,
    this.create = function (ids) {
        n = ids.length;
        var factory = new ActionBarButtonCallbackFactory(callback);
        
        for (var i = 0; i < parseInt(n); i++) {
            posX = border_margin + (game.world.width - 2 * border_margin)/n*i;
            posY = 0;
            //alert('posx: ' + posX + ', posY: ' + posY);
            game.add.button(posX, posY, ids[i][1], factory.get(ids[i][0]), this);
        }
    }
}

//var actionbar = new ActionBar(0,0, AlertManager);
//actionbar.button_width = 128;
//actionbar.create([['first','button1'], ['second', 'button2'], ['third', 'button3']]);