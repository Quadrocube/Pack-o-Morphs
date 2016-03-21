function TGameWorld(Game, hexagonWidth, hexagonHeight, gridSizeX, gridSizeY, initialNutrition) {
    this.hexagonWidth = hexagonWidth || 35;
    this.hexagonHeight = hexagonHeight || 40;
    this.gridSizeX = gridSizeX || 2 * 16;
    this.gridSizeY = gridSizeY || 20;
    this.initialNutrition = initialNutrition || 15;
    this.actionBarHeight = 128; // must be changed if buttons change

    this.columns = [Math.ceil(this.gridSizeX / 2),Math.floor(this.gridSizeX / 2)];
    this.sectorWidth = this.hexagonWidth;
    this.sectorHeight = this.hexagonHeight / 4 * 3;
    this.gradient = (this.hexagonHeight / 4) / (this.hexagonWidth / 2);
    this.game = Game;

    this.fieldPosX = (Game.width - this.hexagonWidth * Math.ceil(this.gridSizeX / 2)) / 2;
    if (this.gridSizeX % 2 === 0) {
        this.fieldPosX -= this.hexagonWidth / 4;
    }

    this.fieldPosY = (Game.height - Math.ceil(this.gridSizeY / 2) * this.hexagonHeight -
                 Math.floor(this.gridSizeY / 2) * this.hexagonHeight / 2 ) /2;
    if (this.gridSizeY % 2 === 0) {
        this.fieldPosY -= this.hexagonHeight / 8;
    }

    this.fieldSizeX = this.hexagonWidth * Math.ceil(this.gridSizeX / 2);
    if (this.gridSizeX % 2 === 0) {
       this.fieldSizeX += this.hexagonWidth / 2;
    }
}

TGameWorld.prototype = {
    IsValidCoordinate : function (posX, posY) {
        return posX >= 0 && posY >= 0 && posY < this.gridSizeY && posX <= this.columns[posY % 2] - 1;
    },

    ColRow2Ind : function(posX, posY) {
        return this.gridSizeX * Math.floor(posY / 2) + 2 * posX + (posY % 2);
    },

    FindHex : function () {
        var candidateX = Math.floor((this.game.input.worldX - this.fieldPosX) / this.sectorWidth);
        var candidateY = Math.floor((this.game.input.worldY- this.fieldPosY) / this.sectorHeight);
        var deltaX = (this.game.input.worldX - this.fieldPosX) % this.sectorWidth;
        var deltaY = (this.game.input.worldY - this.fieldPosY) % this.sectorHeight;
        if(candidateY%2===0){
            if (deltaY < ((this.hexagonHeight / 4) - deltaX * this.gradient)){
                candidateX--;
                candidateY--;
            }
            if(deltaY < ((-this.hexagonHeight / 4) + deltaX * this.gradient)){
                candidateY--;
            }
        } else {
            if(deltaX >= this.hexagonWidth / 2){
                if(deltaY < (this.hexagonHeight / 2 - deltaX * this.gradient)){
                   candidateY--;
                }
            } else {
                if(deltaY < deltaX * this.gradient){
                   candidateY--;
                } else {
                   candidateX--;
                }
            }
        }
        return {
            x: candidateX,
            y: candidateY
        };
    },
}