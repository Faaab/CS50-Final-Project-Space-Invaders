--[[
    Boss Projectile Class

    Author: Fabian van Dijk

    This class represents the shots fired from the boss enemies. They cause
    damage to the player upon collision.
]]

BossProjectile = Class{}

function BossProjectile:init(x, y, dx, dy)
    -- set coordinates and whether projectile is moving up or down
    self.x = x
    self.y = y
    self.dx = dx
    self.dy = dy
    self.inPlay = true
    self.width = BOSS_PROJECTILE_WIDTH
    self.height = BOSS_PROJECTILE_WIDTH
    self.origin = 'alien'
end

function BossProjectile:collides(target)
    -- simple AABB collision detection, with smaller hitbox (4 * 4 instead of 8 * 8)
    if self.x + 2 > target.x + target.width or self.x + self.width - 2 < target.x then
        return false
    elseif self.y + 2 > target.y + target.height or self.y + self.height - 2 < target.y then
        return false
    else
        return true
    end
end

function BossProjectile:update(dt)
    -- Update X and Y positions
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function BossProjectile:render()
    -- render logic
    love.graphics.draw(gTextures['boss_projectile'], self.x, self.y)
end
