Player = Object:extend()

local image = love.graphics.newImage('panda.png')

function Player:new()
    self.x = 300
    self.y = 20
    self.speed = 500
    self.width = image:getWidth() / 2
    self.height = image:getHeight() / 2

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
    if love.keyboard.isDown('up') then
        self.y = self.y - self.speed * dt
    end
    if love.keyboard.isDown('down') then
        self.y = self.y + self.speed * dt
    end 

    if self.x < 0 then
        self.x = 0
    elseif self.x + self.width > WINDOW_WIDTH then
        self.x = WINDOW_WIDTH - self.width
    end
    if self.y < 0 then
        self.y = 0
    elseif self.y + self.height > WINDOW_HEIGHT then
        self.y = WINDOW_HEIGHT - self.height
    end
end

function Player:draw()
    love.graphics.draw(image, self.x, self.y, 0, 0.5, 0.5)
end