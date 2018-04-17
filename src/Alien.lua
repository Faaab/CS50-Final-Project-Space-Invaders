--[[
    GD50
    Space Invaders – Fabian edition

    Skeleton code for project0 by Colton Ogden
    cogden@cs50.harvard.edu
    Implementation of project0 and added features by Fabian van Dijk
    fabiancvandijk@gmail.com
]]

Alien = Class{}

function Alien:init(skin, x, y)
    -- initialize alien at determined position with determined skin
    self.skin = skin
    self.x = x
    self.original_x = x
    self.y = y
    self.original_y = y
    self.dx = ALIEN_DX
    self.width = ALIEN_WIDTH
    self.height = ALIEN_HEIGHT
    self.inPlay = true
end

function Alien:update(dt, projectiles, level)
    if self.inPlay == true then
        -- alien movement speed gets faster based on level
        if self.dx > 0 then
            self.x = self.x + (self.dx + level) * dt
        else
            self.x = self.x + (self.dx - level) * dt
        end

        if self.lowest == true then
            -- there is a chance of 1 in SHOOT_CHANCE of shooting
            local c = math.random(SHOOT_CHANCE - level * level)

            if c == 1 then
                -- shoot
                projectiles[#projectiles+1] = Projectile(self.x + self.width / 2 - PROJECTILE_WIDTH, self.y + self.height + 1, 'alien')
                gSounds['alien_shot']:play()
            end
        end
    end
end

function Alien:collides(target)
    if self.x > target.x + target.width or self.x + self.width < target.x then
        return false
    elseif self.y > target.y + target.height or self.y + self.height < target.y then
        return false
    else
        return true
    end
end

function Alien:edgeCollide()
    -- if alien is in play and hits the edge, return true
    if self.inPlay == true and self.dx > 0 and self.x + self.width >= VIRTUAL_WIDTH then
        return true
    elseif self.inPlay == true and self.dx < 0 and self.x <= 0 then
        return true
    else
        return false
    end
end

function Alien:render()
    if self.inPlay == true then
        love.graphics.draw(gTextures['mainsheet'], gFrames['spaceships'][self.skin], self.x, self.y)
    end
end
