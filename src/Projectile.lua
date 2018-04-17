--[[
    GD50
    Space Invaders – Fabian edition

    Skeleton code for project0 by Colton Ogden
    cogden@cs50.harvard.edu
    Implementation of project0 and added features by Fabian van Dijk
    fabiancvandijk@gmail.com

    This class represents the shots fired from either the Player or an Alien. Only
    projectiles fired by the player can damage aliens, and vice versa.
]]

Projectile = Class{}

function Projectile:init(x, y, origin)
    -- set coordinates and whether projectile is moving up or down
    self.x = x
    self.y = y
    self.origin = origin
    self.inPlay = true
    self.width = PROJECTILE_WIDTH
end

function Projectile:collides(target)
    -- simple AABB collision detection, but 'up' projectiles can only hit aliens, and
    -- 'down' projectiles can only hit the player
    if self.x > target.x + target.width or self.x + PROJECTILE_WIDTH < target.x then
        return false
    elseif self.y > target.y + target.height or self.y + PROJECTILE_HEIGHT < target.y then
        return false
    else
        return true
    end
end

function Projectile:update(dt)
    if self.origin == 'player' then
        self.y = self.y + -PROJECTILE_SPEED * dt
    else
        self.y = self.y + PROJECTILE_SPEED * dt
    end
end

function Projectile:render()
    -- render logic
    love.graphics.rectangle('fill', self.x, self.y, PROJECTILE_WIDTH, PROJECTILE_HEIGHT)
end
