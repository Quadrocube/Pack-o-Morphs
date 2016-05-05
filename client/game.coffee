window.onload = () ->
    onPreload = () =>
        images =
            'bubble': 'arts/bubble.png'
            'hexagon': 'arts/hexagon.png'
            'hexagon_me': 'arts/hexagon_me.png'
            'hexagon_opponent': 'arts/hexagon_opponent.png'
            'marker': 'arts/marker.png'
            'button_morph_vector': 'arts/button_size/amoeba1.png'
            'button_morph_cocoon': 'arts/button_size/amoeba2.png'
            'button_morph_plant': 'arts/button_size/amoeba3.png'
            'button_morph_spawn': 'arts/button_size/amoeba4.png'
            'button_morph_daemon': 'arts/button_size/amoeba5.png'
            'button_morph_turtle': 'arts/button_size/amoeba6.png'
            'button_morph_rhino': 'arts/button_size/amoeba7.png'
            'button_morph_wasp': 'arts/button_size/amoeba8.png'
            'button_morph_spider': 'arts/button_size/amoeba9.png'
            'button_morph_cancel': 'arts/button_size/cancel.png'
            'hex_vector': 'arts/small/amoeba.png'
            'hex_cocoon': 'arts/small/amoeba2.png'
            'hex_plant': 'arts/small/amoeba3.png'
            'hex_spawn': 'arts/small/amoeba4.png'
            'hex_daemon': 'arts/small/amoeba5.png'
            'hex_turtle': 'arts/small/amoeba6.png'
        spritesheets =
            'button_replicate': 'arts/buttons/button_replicate_spritesheet.png'
            'button_spec_ability': 'arts/buttons/button_spec_ability_spritesheet.png'
            'button_feed': 'arts/buttons/button_feed_spritesheet.png'
            'button_morph': 'arts/buttons/button_morph_spritesheet.png'
            'button_yield': 'arts/buttons/button_yield_spritesheet.png'
        for name, image of images
            @game.load.image(name, image)
        for name, spritesheet of spritesheets
            @game.load.spritesheet(name, spritesheet, 128, 128)

        @game.scale.scaleMode = Phaser.ScaleManager.RESIZE;
        @game.scale.pageAlignHorizontally = true;
        @game.scale.pageAlignVertically = true;
        @game.scale.forceLandscape = true;
        @game.scale.parentIsWindow = true;
        @game.scale.refresh();
        return

    onCreate = () =>
        @game.stage.backgroundColor = '#B3E5FC'
        @game.world.setBounds(0, 0, @game.width, @game.height)

        grass = [[17,12],[0,7],[1,8],[2,8],[2,7],[2,6],[1,6],[1,10],[0,11],[1,12],[2,12],[2,11],[2,10],
            [13,11],[14,11],[15,10],[14,9],[13,9],[13,10],[13,7],[14,7],[15,6],[14,5],[13,5],[13,6]]
        playerOne = [[7,0],[6,1],[7,2],[8,2],[8,1],[8,0]]
        playerTwo = [[7,18],[6,17],[7,16],[8,16],[8,17],[8,18]]
        data = new window.FieldData(35, 20)
        for cell in grass
            data.obstaclesField[cell[1]][cell[0]] = new window.FieldObject(cell[1], cell[0], "GRASS")
        for cell in playerOne
            data.creaturesField[cell[1]][cell[0]] = new window.FieldObject(cell[1], cell[0], "VECTOR")
        for cell in playerTwo
            data.creaturesField[cell[1]][cell[0]] = new window.FieldObject(cell[1], cell[0], "VECTOR", true, 1)
        @field = new window.DrawField(@game, 35, 20, 16, data)
        return

    onUpdate = () =>
        return

    @game = new Phaser.Game('100%', '100%', Phaser.CANVAS, '', {preload: onPreload, create: onCreate, update: onUpdate})

    $(window).resize( () =>
        #clearTimeout(timeoutResize)
        timeoutResize = setTimeout( () ->
            # resize game
            @game.scale.scaleMode = Phaser.ScaleManager.RESIZE
            @game.scale.pageAlignHorizontally = true
            @game.scale.pageAlignVertically = true
            @game.scale.forceLandscape = true
            @game.scale.parentIsWindow = true
            @game.scale.refresh()
            @field.Draw();
        , 1000)
    )

    return


