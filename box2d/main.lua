VIRTUAL_WIDTH = 640
VIRTUAL_HEIGHT = 360

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

DEGREES_TO_RADIANS = 0.0174532925199432957

WHEELS = 3
BALLS = 500

push = require 'push'

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('box2D sandbox')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    world = love.physics.newWorld(0, 300)

    -- dynamic balls
    boxBodies = {}
    boxFixtures = {}
    boxShape = love.physics.newCircleShape(5)

    for i = 1, BALLS do
        table.insert(boxBodies, {
            love.physics.newBody(world,
                math.random(VIRTUAL_WIDTH), 0, 'dynamic'),
            r = math.random(255) / 255,
            g = math.random(255) / 255,
            b = math.random(255) / 255
            })
        table.insert(boxFixtures, love.physics.newFixture(boxBodies[i][1], boxShape))
    end

    -- bodies
    groundBody = love.physics.newBody(world, 0, VIRTUAL_HEIGHT - 30, 'static')
    leftWallBody = love.physics.newBody(world, 0, 0, 'static')
    rightWallBody = love.physics.newBody(world, VIRTUAL_WIDTH, 0, 'static')

    -- shapes
    edgeShape = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH, 0)
    wallShape = love.physics.newEdgeShape(0, 0, 0, VIRTUAL_HEIGHT)

    -- fixtures
    groundFixture = love.physics.newFixture(groundBody, edgeShape)
    leftWallFixture = love.physics.newFixture(leftWallBody, wallShape)
    rightWallFixture = love.physics.newFixture(rightWallBody, wallShape)

    -- kinematic wheels
    kinematicBodies = {}
    kinematicFixtures = {}
    kinematicShape = love.physics.newRectangleShape(20, 20)

    for i = 1, WHEELS do
        table.insert(kinematicBodies, love.physics.newBody(world,
            VIRTUAL_WIDTH / 2 - (30 * (WHEELS / 2 + 1 - i)), math.random(50, 200), 'kinematic'))
        table.insert(kinematicFixtures, love.physics.newFixture(kinematicBodies[i], kinematicShape))
        kinematicBodies[i]:setAngularVelocity(360 * DEGREES_TO_RADIANS)
    end
end

function push.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)
    world:update(dt)
end

function love:draw()
    push:start()

    love.graphics.setColor(0, 0, 1, 1)
    for i = 1, WHEELS do
        love.graphics.polygon('fill', kinematicBodies[i]:getWorldPoints(kinematicShape:getPoints()))
    end

    for i = 1, BALLS do
        love.graphics.setColor(boxBodies[i].r, boxBodies[i].g, boxBodies[i].b, 1)
        love.graphics.circle('fill', boxBodies[i][1]:getX(), boxBodies[i][1]:getY(), boxShape:getRadius())
    end

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(groundBody:getWorldPoints(edgeShape:getPoints()))
    
    push:finish()
end