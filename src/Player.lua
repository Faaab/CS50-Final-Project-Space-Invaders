--[[
    GD50
    Space Invaders – Fabian edition

    Skeleton code for project0 by Colton Ogden
    cogden@cs50.harvard.edu
    Implementation of project0 and added features by Fabian van Dijk
    fabiancvandijk@gmail.com

    The Player is a ship that remains at the very bottom of the screen, facing toward
    the top, the same direction they can fire bullets to hit Aliens. The Player starts
    with three lives; upon colliding with an enemy or their bullets, the Player will
    lose a life and restart the level. Game over is reached when all lives are depleted.
]]

Player = Class{}

function Player:init()
    -- Player skin is hardcoded to first sprite in mainsheet
    self.skin = 1

    --initialize player dimensions. Starting in the middle of the screen!
    self.width = PLAYER_WIDTH
    self.height = PLAYER_HEIGHT
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT - 16
    self.dx = 0

    -- to handle player disappearing for a little while when hit
    self.died = false
end

function Player:update(dt, projectiles)
    if self.died == false then
        -- process player input
        if love.keyboard.isDown('left') then
            -- go left
            self.dx = -PLAYER_SPEED
        elseif love.keyboard.isDown('right') then
            -- go right
            self.dx = PLAYER_SPEED
        else
            self.dx = 0
        end

        if self.dx < 0 then
            -- handle going left, not letting player go past left edge of screen
            self.x = math.max(0, self.x + self.dx * dt)
        elseif self.dx > 0 then
            -- handle going right, not letting player go past right edge of screen
            self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
        end
    else
        self.respawnCounter = self.respawnCounter + dt

        if self.respawnCounter > 1.5 then
            self.died = false
        end
    end
end

function Player:render()
    if self.died == false then
        love.graphics.draw(gTextures['mainsheet'], gFrames['spaceships'][self.skin], self.x, self.y)
    end
end
