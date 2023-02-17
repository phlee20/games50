Enemy = Object:extend()

function Enemy:new()
    self.image = love.graphics.newImage('snake.png')
    self.x = 300
    self.y = 450
    self.dx = 100
    self.dy = 100
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

function Enemy:update(player, dt)
    if self.x + self.width / 2 > player.x + player.width / 2 then
        self.dx = -self.dx
    end
    if self.x + self.width / 2 < player.x + player.width / 2 then
        self.dx = 100
    end

    if self.y + self.height / 2 > player.y + player.height / 2 then    
        self.dy = -100
    end
    if self.y + self.height / 2 < player.y + player.height / 2 then
        self.dy = 100
    end

    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

end

function Enemy:draw()
    love.graphics.draw(self.image, self.x, self.y)
end