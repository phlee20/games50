Bullet = Object:extend()

function Bullet:new(x, y)
    self.image = love.graphics.newImage('bullet.png')
    self.x = x
    self.y = y
    self.speed = 700
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.dead = false
end

function Bullet:checkCollision(obj)
    if self.x < obj.x + obj.width and self.x + self.width > obj.x
    and self.y < obj.y + obj.height and self.y + self.height > obj.y then
        self.dead = true
        if obj.speed > 0 then
            obj.speed = obj.speed + 50
        else
            obj.speed = obj.speed - 50
        end
        sounds['hit']:play()
    end
    if self.y + self.height > WINDOW_HEIGHT then
        love.load()
    end
end

function Bullet:update(dt)
    self.y = self.y + self.speed * dt
end

function Bullet:draw()
    love.graphics.draw(self.image, self.x, self.y) 
end