function love.load()
    Object = require 'classic'
    require 'shape'
    require 'rectangle'
    require 'circle'
    r1 = Rectangle(100, 100, 200, 150)
    c1 = Circle(300, 300, 100)
end

function love.keypressed(key)
    if key == 'space' then
        x = math.random(100, 500)
        y = math.random(100, 500)
    end
end

function love.update(dt)
    r1:update(dt)
    c1:update(dt)
end

function love.draw()
    r1:draw()
    c1:draw()
end
