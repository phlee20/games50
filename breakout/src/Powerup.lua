Powerup = Class{}

function Powerup:init(x, y)
    self.width = 16
    self.height = 16

    self.x = x
    self.y = y

    self.dy = 40

    -- how to select random number from (1, 2, 3, 7, 10)
    self.type = math.random(4)

    self.remove = false
end

function Powerup:collides(target)
    -- same collision logic as in the Ball class
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    return true
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt

    if self.y > VIRTUAL_HEIGHT then
        self.remove = true
    end
end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type],
        self.x, self.y)
end