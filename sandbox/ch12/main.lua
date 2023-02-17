function love.load()
    myImage = love.graphics.newImage('sheep.png')
    width = myImage:getWidth()
    height = myImage:getHeight()

    love.graphics.setBackgroundColor(50/255, 75/255, 200/255, 255/255)

end

function love.draw()
    love.graphics.setColor(255/255, 0/255, 155/255, 255/255)
    love.graphics.draw(myImage, 200, 200, 0, 2, 2, width/2, height/2)

end