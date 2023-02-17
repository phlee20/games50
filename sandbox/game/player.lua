Player = Object:extend()

function Player:new()
    self.image = love.graphics.newImage('panda.png')
    self.x = 300
    self.y = 20
    self.speed = 500
    self.width = self.image:getWidth()

end

function Player:keypressed(key)
    if key == 'space' then
        table.insert(listOfBullets, Bullet(self.x + self.width / 2, self.y))
    end
end

function Player:update(dt)
    if love.keyboard.isDown('left') then
        self.x = self.x - self.speed * dt
    end
    if love.keyboard.isDown('right') then
        self.x = self.x + self.speed * dt
    end

    if self.x < 0 then
        self.x = 0
    elseif self.x + self.width > WINDOW_WIDTH then
        self.x = WINDOW_WIDTH - self.width
    end
end

function Player:draw()
    love.graphics.draw(self.image, self.x, self.y)
end