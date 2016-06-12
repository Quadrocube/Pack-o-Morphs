# Автор: Гусев Илья.
# Описание: Класс-предок панелей.

class window.Bar
    Draw: (game, x, y, width, height) ->
        @Destroy()
        @graphics = game.add.graphics(0, 0)
        @graphics.beginFill(0x01579B, 0.5)
        @rect = @graphics.drawRoundedRect(x, y, width, height, 5)
        @rect.fixedToCamera = true
        @graphics.endFill()
        return

    Destroy: () ->
        if @graphics?
            @graphics.destroy()
            @graphics = undefined
        return