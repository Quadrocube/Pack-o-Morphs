wfconfig =
    active: () ->
        init()
    google:
        families: ['Comfortaa']

WebFont.load(wfconfig);

init = () ->
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
        hexWidth = 35
        rowNum = 20
        colNum = 16

        # Присоеднияемся к серверу
        @serverConnection = new window.ServerTalk()

        # Сервер нашёл противника
        @serverConnection.initCallback = (order) =>
            @turnState = new window.TurnState(order)
            data = new window.FieldData(rowNum, colNum)
            grid = new window.THexGrid(hexWidth, rowNum, colNum)
            @logic = new window.Logic(grid, data)
            @field = new window.DrawField(@game, data, grid, @logic, @turnState)

            @actionBar = new window.ActionBar(@game, grid)
            @infoBar = new window.InfoBar(@game)
            @playerBar = new window.PlayerBar(@game)

            @game.input.mouse.mouseDownCallback = @field.OnClick(@actionBar, @infoBar, @playerBar)

            if @turnState.IsClientTurn()
                @field.Unlock()
                @actionBar.Unlock()
            else
                @field.Lock()
                @actionBar.Lock()
            @playerBar.DisplayPlayerInfo(@turnState)

        # Противник походил
        @serverConnection.turnCallback = (data) =>
            @logic.Upkeep()
            @turnState.ChangeTurn()
            @playerBar.DisplayPlayerInfo(@turnState)
            @field.data.Load(data)
            @field.Unlock()
            @actionBar.Unlock()

        # Клиент походил
        @game.input.keyboard.onDownCallback = (key) =>
            if key.keyCode == Phaser.Keyboard.SPACEBAR && @turnState.IsClientTurn()
                @field.Lock()
                @actionBar.Lock()
                @turnState.ChangeTurn()
                @playerBar.DisplayPlayerInfo(@turnState)
                @serverConnection.Send('new-turn', @field.data)
        return

    onUpdate = () =>
        return

    @game = new Phaser.Game('100%', '100%', Phaser.CANVAS, '', {preload: onPreload, create: onCreate, update: onUpdate})

    window.onresize = () =>
        setTimeout( () ->
            # resize game
            @game.scale.scaleMode = Phaser.ScaleManager.RESIZE
            @game.scale.pageAlignHorizontally = true
            @game.scale.pageAlignVertically = true
            @game.scale.forceLandscape = true
            @game.scale.parentIsWindow = true
            @game.scale.refresh()
            if field?
                @field.Draw()
        , 1000)

    return


