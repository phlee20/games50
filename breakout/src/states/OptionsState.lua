OptionsState = Class{__includes = BaseState}

-- whether we're highlighting 'On' or 'Off'
local highlighted = 1

function OptionsState:enter(params)
    self.highScores = params.highScores
end

function OptionsState:update(dt)
    -- toggle highlighted option if we press an arrow key
    if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
        highlighted = highlighted == 1 and 2 or 1
        gSounds['paddle-hit']:play()
    end

    -- confirm option to change screen back to start state
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['confirm']:play()

        if highlighted == 1 then
            -- music on
            gSounds['music']:play()
            gSounds['music']:setLooping(true)
        else
            -- music off
            gSounds['music']:pause()
        end

        gStateMachine:change('start', {
            highScores = self.highScores
        })
    end
    
    -- return to the start screen if we press escape
    if love.keyboard.wasPressed('escape') then
        gSounds['wall-hit']:play()
        
        gStateMachine:change('start', {
            highScores = self.highScores
        })
    end
end

function OptionsState:render()
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('MUSIC', 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])

    -- set color if highlighted
    if highlighted == 1 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("ON", 0, VIRTUAL_HEIGHT / 2 + 20, VIRTUAL_WIDTH, 'center')

    -- reset color
    love.graphics.setColor(1, 1, 1, 1)

    -- set color if highlighted
    if highlighted == 2 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("OFF", 0, VIRTUAL_HEIGHT / 2 + 40, VIRTUAL_WIDTH, 'center')

    -- reset color
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("Press Escape to return to the main menu!",
        0, VIRTUAL_HEIGHT - 18, VIRTUAL_WIDTH, 'center')
end