function TInfoBar(Game, GameWorld) {
    this.text = "Default text!\n";
    this.width = 300;
    this.margin = 40;
    this.height = 500;
    this.x = window.innerWidth - this.width;
    this.y = 0;
    this.textHandler;
    this.create = function(text) {
        this.text = text;
        var infoGroup = Game.add.group();
        
        var graphics = Game.add.graphics(0, 0);
        graphics.beginFill(0x000000, 0.5); 
        var rect = graphics.drawRoundedRect(this.x, this.y, this.width, this.height);
        rect.fixedToCamera = true;
        infoGroup.add(rect);
        
        var style = { font: "32px Arial", fill: "#ffffff", wordWrap: true, wordWrapWidth: this.width - this.margin, align: "left"};        
        this.textHandler = Game.add.text(this.x + this.margin / 2, this.y + this.margin/2, this.text, style);
        infoGroup.add(this.textHandler);
        this.textHandler.fixedToCamera = true;            
    }
    this.displayInfoCreature = function(creature) {
        var stats = "";
        
        if (creature == null) {
            stats = 'type: ' + '0' + '\n'
                  + 'att: ' + '0' + '\n'
                  + 'def: ' + '0' + '\n'
                  + 'dam: ' + '0' + '\n'
                  + 'hpp: ' + '0' + '\n'
                  + 'mov: ' + '0' + '\n'
                  + 'nut: ' + '0' + '\n';
        } else {
            stats = 'type: ' + creature.type + '\n'
                  + 'att: ' + creature.ATT + '\n'
                  + 'def: ' + creature.DEF + '\n'
                  + 'dam: ' + creature.DAM + '\n'
                  + 'hpp: ' + creature.HPP + '\n'
                  + 'mov: ' + creature.MOV + '\n'
                  + 'nut: ' + creature.NUT + '\n';
        }         
                    
        this.textHandler.setText(stats);
        
    }
}