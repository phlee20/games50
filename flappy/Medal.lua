Medal = Class{}

function Medal:init()
    -- load bank of medals
    self.images = {
        ['medal1'] = love.graphics.newImage('medal1.png'),
        ['medal2'] = love.graphics.newImage('medal2.png'),
        ['medal3'] = love.graphics.newImage('medal3.png')
    }

    self.width  = self.images['medal1']:getWidth()
    self.height = self.images['medal1']:getHeight()

    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT / 2 - self.height / 2
end

function Medal:render(medalType)
    love.graphics.draw(self.images[medalType], self.x, self.y)
end