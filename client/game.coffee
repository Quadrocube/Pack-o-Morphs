class Game extends Phaser.State
    constructor: () -> 
		game = new Phaser.Game 640, 320, Phaser.AUTO, 'game', this

    preload: ()->
        @game.load.image('logo', 'arts/bubble.png')

    create: ()->
        @logo = @game.add.sprite(@game.world.centerX, @game.world.centerY, 'logo')
        @logo.anchor.x = 0.5
        @logo.anchor.y = 0.5
        @logo.update = ()->
            @angle++


    update: ()->
        @logo.angle++
window.onload = () ->
	new Game