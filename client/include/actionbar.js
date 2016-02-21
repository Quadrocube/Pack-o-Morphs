
function TActionBarButtonCallbackFactory(callback) {
    this.get = function(id) {
        return function () {
            callback(id);
        }
    }
}

function TActionBar(Game, GameWorld, callback, buttonWidth) {
    this.borderMargin = 40;
    this.buttons = [];
    
    this.create = function (ids) {
        var n = ids.length;
        var startPosX = Game.width / 2 - buttonWidth * n / 2;
        
        var actionBarHeight = GameWorld.GetActionBarHeight();
        // black rounded rect -- background for buttons
        this.graphics = Game.add.graphics(0, 0);
        this.graphics.beginFill(0x000000, 0.5); 
        var actionBarWidth = Math.max(GameWorld.GetFieldSizeX(), buttonWidth * n + this.borderMargin );
        var actionBarPosX = Math.min(GameWorld.GetFieldX(), startPosX - this.borderMargin / 2);
        var rect = this.graphics.drawRoundedRect(actionBarPosX, window.innerHeight - actionBarHeight, 
                                            actionBarWidth , actionBarHeight);
        rect.fixedToCamera = true;

        var factory = new TActionBarButtonCallbackFactory(callback);

        for (var i = 0; i < parseInt(n); i++) {
            var posX = startPosX + buttonWidth * i;
            var posY = window.innerHeight - actionBarHeight;
            var button = Game.add.button(posX, posY, ids[i][1], factory.get(ids[i][0]), this);
            this.buttons.push(button);
            button.fixedToCamera = true;
        }
    }
    
    this.update = function (actionList) {
        this.graphics.destroy();
        this.buttons.forEach(function (item, i, arr) {
            item.destroy();
        });
        this.buttons = [];
        
        var ids = [];
        actionList.forEach(function (item, i, arr) {
            ids.push(GameWorld.GetCreatureActionFuncAndButton(item));
        });
        this.create(ids);
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
