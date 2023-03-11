--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level
    self.recoverPoints = params.recoverPoints

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)

    -- init table of powerups
    self.powerups = {}

    -- init bank of keys
    self.keys = 0
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end

    for k, powerup in pairs(self.powerups) do
        powerup:update(dt)

        -- trigger powerup if it collides with paddle
        if powerup:collides(self.paddle) then

            -- set powerup to be removed
            powerup.remove = true
            
            -- trigger powerup effect (change paddle size)
            if powerup.type == pType['paddle-shrink'] or powerup.type == pType['paddle-grow'] then
                self.paddle:change(powerup.type)
            end

            -- trigger powerup effect (spawn more balls)
            if powerup.type == pType['balls'] then
                for i = 1, 2 do
                    local newBall = Ball(math.random(7))
                    newBall:spawnBall(self.paddle)
                    table.insert(self.balls, newBall)
                end
            end

            -- trigger powerup effect (recovery heart)
            if powerup.type == pType['heart'] then
                self.health = math.min(3, self.health + 1)
                gSounds['recover']:play()
            end

            -- trigger powerup effect (key drop)
            if powerup.type == pType['key'] then
                -- store upto 3 keys
                self.keys = math.min(3, self.keys + 1)
                gSounds['recover']:play()
            end
        end
    end

    -- second loop to remove powerup if collides with paddle or it leaves the screen
    for k, powerup in pairs(self.powerups) do
        if powerup.remove then
            table.remove(self.powerups, k)
        end
    end

    -- loop through all balls
    for k, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- bonus score for destroying locked brick and reset key
                if brick.locked and self.keys > 0 then
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                    self.keys = math.max(0, self.keys - 1)
                    brick.locked = false
                end
                
                if not brick.locked then

                    -- add to score
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)

                    -- trigger the brick's hit function, which removes it from play
                    brick:hit()

                    -- trigger powerup chance on brick hit (increasing probability in higher levels)
                    if math.random(math.max(3, math.floor((60 - self.level) / 10))) == 1 then
                        table.insert(self.powerups, Powerup(brick.x + 8, brick.y + 16))
                        
                        -- check for locked bricks
                        local lockedExist = false

                        for k, brick in pairs(self.bricks) do
                            if brick.locked then
                                lockedExist = true
                            end
                        end

                        -- remove key powerup if no locked bricks in level or remove heart powerup if full health
                        if (self.powerups[#self.powerups].type == pType['key'] and not lockedExist) or 
                            (self.powerups[#self.powerups].type == pType['heart'] and self.health == 3) then
                            table.remove(self.powerups, #self.powerups)
                        end
                    end
                else
                    -- skip brick hit and score if locked without key
                    gSounds['wall-hit']:play()
                end

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        -- ball = self.ball,
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end

        -- if ball goes below bounds, set ball to be removed
        if ball.y >= VIRTUAL_HEIGHT then
            ball.remove = true
        end
    end

    -- second loop to remove balls marked to be removed
    for k, ball in pairs(self.balls) do
        if ball.remove then
            table.remove(self.balls, k)
        end
    end

    -- if no balls remaining, revert to serve state and decrease health
    if #self.balls == 0 then
        self.health = self.health - 1
        gSounds['hurt']:play()

        -- reset paddle
        self.paddle:reset()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    -- render all balls
    for k, ball in pairs(self.balls) do
        ball:render()
    end

    -- render all powerups
    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    -- render collected keys
    if self.keys > 0 then
        for i = 1, self.keys do
            love.graphics.draw(gTextures['main'], gFrames['powerups'][pType['key']], 300 - 10 * i, 3, 0, 0.6, 0.6)
        end
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end