WINDOW_WIDTH = love.graphics.getWidth()
WINDOW_HEIGHT = love.graphics.getHeight()

Object = require 'classic'
require 'player'
require 'enemy'
require 'bullet'

function love.load()

    love.window.setTitle('Shoot')

    player = Player()
    enemy = Enemy()
    listOfBullets = {}

    sounds = {
        ['hit'] = love.audio.newSource('paddle_hit.wav', 'static')
    }

    score = 0

end

function love:keypressed(key)
    player:keypressed(key)
end

function love.update(dt)
    player:update(dt)
    enemy:update(dt)

    for k, v in pairs(listOfBullets) do
        v:update(dt)
        v:checkCollision(enemy)

        if v.dead == true then
            table.remove(listOfBullets, k)
            score = score + 1
        end
    end
end

function love.draw()
    player:draw()
    enemy:draw()
    
    for k, v in pairs(listOfBullets) do
        v:draw()
    end

    love.graphics.print('Score: ' .. tostring(score), 0, 0)

end