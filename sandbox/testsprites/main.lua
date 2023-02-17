function love.load()
    image = love.graphics.newImage('round_nodetails.png')
end

function love.draw()
    love.graphics.draw(image, 100, 100)
end