function love.load()
    circle = {}

    circle.x = 100
    circle.y = 100
    circle.radius = 25
    circle.speed = 200
end

function getDistance(x1, y1, x2, y2)
    local h_dist = x1 - x2
    local v_dist = y1 - y2

    local a = h_dist ^2
    local b = v_dist ^2

    local c = a + b
    local dist = math.sqrt(c)
    return dist
end

function love.update(dt)
    mouse_x, mouse_y = love.mouse.getPosition()

    angle = math.atan2(mouse_y - circle.y, mouse_x - circle.x)

    cos = math.cos(angle)
    sin = math.sin(angle)

    local dist = getDistance(circle.x, circle.y, mouse_x, mouse_y)
    
    if dist < 400 then
        circle.x = circle.x + circle.speed * cos * (dist / 100) * dt
        circle.y = circle.y + circle.speed * sin * (dist / 100) * dt
    end
end

function love.draw()
    love.graphics.circle('line', circle.x, circle.y, circle.radius)

    love.graphics.print('angle: ' .. angle, 10, 10)
    love.graphics.line(circle.x, circle.y, mouse_x, mouse_y)
    love.graphics.line(circle.x, circle.y, mouse_x, circle.y)
    love.graphics.line(mouse_x, mouse_y, mouse_x, circle.y)


    local dist = getDistance(circle.x, circle.y, mouse_x, mouse_y)
    love.graphics.circle('line', circle.x, circle.y, dist)
end