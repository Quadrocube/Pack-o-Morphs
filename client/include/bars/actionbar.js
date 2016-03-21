
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
    this.isLock = false;
    this.actionBarPosX = 100;
    this.actionBarWidth = 100;
    this.actionBarHeight = 128;
    this.buttonWidth = buttonWidth;
    this.lockRect;
    this.barRect;
    this.game = Game;
    this.gameWorld = GameWorld;
    this.callback = callback;

    this.Init();
}

TActionBar.prototype = {
    Init : function () {
        this.actionBarHeight = this.gameWorld.actionBarHeight;
        this.isLock = false;
        this.create([]);
    },
    
    create : function (ids) {
        if (this.isLock) {
            return;
        }
        var n = ids.length;
        var startPosX = this.game.width / 2 - this.buttonWidth * n / 2;
        
        // black rounded rect -- background for buttons
        this.graphicsBar = this.game.add.graphics(0, 0);
        this.graphicsBar.beginFill(0x01579B, 0.5); 
        this.actionBarWidth = Math.max(this.gameWorld.fieldSizeX, this.buttonWidth * n + this.borderMargin );
        this.actionBarPosX = Math.min(this.gameWorld.fieldPosX, startPosX - this.borderMargin / 2);
        this.barRect = this.graphicsBar.drawRoundedRect(this.actionBarPosX, window.innerHeight - this.actionBarHeight, 
                                            this.actionBarWidth , this.actionBarHeight);
        this.barRect.fixedToCamera = true;

        var factory = new TActionBarButtonCallbackFactory(this.callback);
        for (var i = 0; i < parseInt(n); i++) {
            var posX = startPosX + this.buttonWidth * i;
            var posY = window.innerHeight - this.actionBarHeight;
            var button;
            if(ids[i][1] === 'button_replicate' 
                || ids[i][1] === 'button_spec_ability' 
                || ids[i][1] === 'button_feed'
                || ids[i][1] === 'button_yield'
                || ids[i][1] === 'button_morph') {
                button = this.game.add.button(posX, posY, ids[i][1], factory.get(ids[i][0]), this, 0, 1, 1);           
                } else {
                    button = this.game.add.button(posX, posY, ids[i][1], factory.get(ids[i][0]), this);
                }
            this.buttons.push(button);
            button.fixedToCamera = true;
        };
    },
    
    update : function (actionList) {
        if (this.isLock) {
            return;
        }
        
        this.barRect.destroy();
        this.buttons.forEach(function (item, i, arr) {
            item.destroy();
        });
        this.buttons = [];
        
        var ids = [];
        var self = this;
        actionList.forEach(function (item, i, arr) {
            ids.push(GetCreatureActionFuncAndButton(item));
        });
        this.create(ids);
    },
    
    lock : function () {
        this.isLock = true;

        this.graphicsLock = this.game.add.graphics(0, 0);        
        this.graphicsLock.beginFill(0xFFFFFF, 0.5); 
        this.lockRect = this.graphicsLock.drawRoundedRect(this.actionBarPosX, window.innerHeight - this.actionBarHeight, 
                                            this.actionBarWidth , this.actionBarHeight);
        this.lockRect.fixedToCamera = true;
        this.graphicsLock.endFill();

        this.buttons.forEach(function (item, i, arr) {
            item.inputEnabled = false;
        });
    },
    
    unlock : function () {
        this.isLock = false;

        this.graphicsLock.destroy();

        this.buttons.forEach(function (item, i, arr) {
            item.inputEnabled = true;
        });
    },
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
