// string, HexType, TCreature
function TFieldObject(Game, GameWorld, HexagonField, type, initCreature, TurnState) {
    // row = y, col = x
    this.col = 0;
    this.row = 0;
    this.objectType = type;
    this.creature = initCreature;
    this.hexActive = null;
    this.game = Game;
    this.gameWorld = GameWorld;
    this.hexagonField = HexagonField;
    this.turnState = TurnState;
    this.Init();
}

TFieldObject.prototype = {
    Init : function(){
        var spriteName = GetSpriteName(this.objectType, this.creature);
        this.marker = this.game.add.sprite(0,0,spriteName);
        this.marker.visible = true;
        if (this.objectType === HexType.CREATURE &&
            this.creature.player === this.hexagonField.PlayerId.ME)
        {
            this.marker.inputEnabled = true;
            this.marker.input.enableDrag();
            this.marker.events.onDragStart.add(this.OnDragStart, this);
            this.marker.events.onDragStop.add(this.OnDragStop, this);
        }

        this.marker.anchor.setTo(0.5);
        this.marker.visible = false;
        this.hexagonField.Add(this);
    },

    colrow : function () {
        return [this.col, this.row];
    },

    OnDragStart : function (sprite, pointer) {
        var hex = this.gameWorld.FindHex();
        if (this.turnState.SelectField(this.hexagonField.GetAt(hex.x, hex.y)) === true) {
            this.hexagonField.HighlightOff();
            this.hexagonField.Highlight(this.col, this.row, this.MoveRange());
        }
    },

    OnDragStop : function (sprite, pointer) {
        var hex = this.gameWorld.FindHex();
        if (!this.gameWorld.IsValidCoordinate(hex.x, hex.y)) { // out of field
           this.SetNewPosition(this.col, this.row);
        } else {
            var target = this.hexagonField.GetAt(hex.x, hex.y);
            if (target.objectType === HexType.CREATURE &&
                this.turnState.SelectAction(ActionType.ATTACK) === true &&
                this.turnState.SelectField(target) === true) {
                this.SetNewPosition(this.col, this.row);
            } else if (this.turnState.SelectAction(ActionType.MOVE) === true &&
                       this.turnState.SelectField(target) === true) {
                // moved as side-effect
            } else {
                this.SetNewPosition(this.col, this.row);
            }
            this.turnState.SelectField(this);
        }

        this.hexagonField.HighlightOff();
    },

    SetNewPosition : function (posX, posY) {
        this.hexagonField.Move([this.col, this.row], [posX, posY], this);
        this.row = posY;
        this.col = posX;
        if (!this.gameWorld.IsValidCoordinate(posX, posY)) {
            this.marker.visible = false;
            if (this.hexActive) {
                this.hexActive.visible = false;
            }
        } else {
            this.marker.visible = true;
            if (this.hexActive) {
                this.hexActive.visible = true;
            }

            var newX = this.gameWorld.hexagonWidth * posX + this.gameWorld.hexagonWidth/ 2 + (this.gameWorld.hexagonWidth / 2) * (posY % 2);
            var newY = 0.75 * this.gameWorld.hexagonHeight * posY + this.gameWorld.hexagonHeight / 2;

            if (this.hexActive) {
                this.hexActive.x = newX - 16;
                this.hexActive.y = newY - 20;
            }

            this.marker.x = newX;
            this.marker.y = newY;
        }

        return this;
    },

    GetCreaturesInRadius : function (radius) {
        return this.hexagonField.GetCreaturesInRadius(this.col, this.row, radius);
    },

    MoveRange : function () {
        if (this.objectType !== HexType.CREATURE || this.creature == null)
            return 0;
        if (this.creature.type === CreatureType.PLANT || this.creature.type === CreatureType.COCOON)
            return 0;
        var neigh = this.GetCreaturesInRadius(1);
        for (var cr in neigh) {
            if (neigh[cr] === this)
                continue;
            if (neigh[cr].creature.type === CreatureType.TURTLE) {
                return 1;
            }
        }
        if (this.creature.type === CreatureType.SPAWN) {
            return 4;
        }
        return 2;
    }
}