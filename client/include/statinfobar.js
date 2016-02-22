function TStatInfoBar(Game, GameWorld) {
    this.text = "Default text!\n";
    this.width = 300;
    this.margin = 40;
    this.height = 300;
    this.x = 0;
    this.y = 0;
    this.textHandler;
    this.create = function(text) {
        this.text = text;
        var infoGroup = Game.add.group();
        
        var graphics = Game.add.graphics(0, 0);
        graphics.beginFill(0x01579B, 0.5); 
        var rect = graphics.drawRoundedRect(this.x, this.y, this.width, this.height);
        rect.fixedToCamera = true;
        infoGroup.add(rect);
        
        var style = { font: "32px Comfortaa", fill: "#B3E5FC", wordWrap: true, wordWrapWidth: this.width - this.margin, align: "left"};        
        this.textHandler = Game.add.text(this.x + this.margin / 2, this.y + this.margin/2, this.text, style);
        infoGroup.add(this.textHandler);
        this.textHandler.fixedToCamera = true;            
    }
    this.displayStatInfo = function(nutrition, nMyCreatures, nOpponentCreature) {
        var stats = 'my nutrition: ' + nutrition + '\n'
                  + 'all my creatures: ' + nMyCreatures + '\n'
                  + 'all opponent creatures: ' + nOpponentCreature + '\n';
                
        this.textHandler.setText(stats);
        
    }
}