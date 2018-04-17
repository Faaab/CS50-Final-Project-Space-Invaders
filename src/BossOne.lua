--[[
    BossOne Class

    Author: Fabian van Dijk

    BossOne is the boss that is encountered at level 5, 15, 25, etc. It can shoot BossProjectiles
    in four patterns. It has health and is vulnerable to the player's projectiles during
    attack patterns.
]]

BossOne = Class{}

function BossOne:init(level)
    -- initialize boss (speed increases with level)
    self.x = 32
    self.y = 30
    self.dx = ALIEN_DX + level
    self.original_dx = self.dx
    self.dy = 0
    self.width = gTextures['boss1']:getWidth()
    self.height = gTextures['boss1']:getHeight()
    self.level = level
    self.pattern = 0
    self.nextAttack = 0
    self.health = math.min(5 + 2 * level, 80)
    self.inPlay = true

    -- self.timers is a table of tables, where each of the latter holds one timer.
    -- This nesting of tables is necessary for Timer.clear to clear a specific timer
    self.timers = {}

    -- determine base projectile speed based on level
    self.projectileSpeed = PROJECTILE_SPEED / 2 + self.level * 2
end

function BossOne:collides(target)
    if self.x > target.x + target.width or self.x + self.width < target.x then
        return false
    elseif self.y > target.y + target.height or self.y + self.height < target.y then
        return false
    else
        return true
    end
end

function BossOne:update(dt, projectiles)
    if self.pattern == 1 then
        -- determine length of pattern by creating a reset timer
        if not self.timers['reset'] then
            self.timers['reset'] = { Timer.after(5, function()
                self.pattern = 0
            end) }
        end

        -- boss is vulnerable during this pattern
        if not self.vulnerable then
            self.vulnerable = true
        end

        -- Attack every 0.5 seconds
        if not self.timers['attack'] then
            -- Attack delay decreases every time you encounter the boss, down to 0.25 seconds
            self.timers['attack'] = { Timer.every(math.max(0.25, 0.8 - (self.level / 5 - 1) / 40), function()
                -- Switch beteen 1.1 and 1.2; set self.switched to true so it does each once
                if self.nextAttack == 2 then
                    self.nextAttack = 1
                else
                    self.nextAttack = 2
                end
                self.switched = true
            end) }
        end

        -- NB: at the start of the pattern, nextAttack == 0
        if self.switched then
            -- Attack 1.1: /*******.....*******/ (where * = bullet, . = 8px space, / = 1px space)
            if self.nextAttack == 1 then
                -- Shoot left 7 bullets
                for i=1,7 do
                    -- BossProjectile needs x, y, dx and dy
                    -- Notes on dx formula: 50 is horizontal travel in px over the course of projectile's vertical travel time (which is travel distance, 133px, divided by speed)
                    -- But only the outer bullet travels that much, the innermost goes straight down
                    table.insert(projectiles, BossProjectile(self.x + 1 + (i - 1) * 6, self.y + self.height - 8, -50 / (133/self.projectileSpeed) * ((7 - i) / 6), self.projectileSpeed))
                end

                -- Shoot right 7 bullets
                for i=1,7 do
                    table.insert(projectiles, BossProjectile(self.x + 81 + (i - 1) * 6, self.y + self.height - 8, 50 / (133/self.projectileSpeed) * ((i - 1) / 6), self.projectileSpeed))
                end

                gSounds['explosion']:play()
                self.switched = false
            else
                -- Attack 1.2: /....*******..../
                for i=1,7 do
                    table.insert(projectiles, BossProjectile(self.x + 33 + (i - 1) * 8, self.y + self.height - 8, 0, self.projectileSpeed))
                end

                gSounds['explosion']:play()
                self.switched = false
            end
        end
    elseif self.pattern == 2 then
        -- same pattern as 1, but BossOne is moving
        if not self.timers['reset'] then
            self.timers['reset'] = { Timer.after(5, function()
                self.pattern = 0
            end) }
        end

        -- boss is vulnerable during this pattern
        if not self.vulnerable then
            self.vulnerable = true
        end

        -- Attack every 0.5 seconds
        if not self.timers['attack'] then
            -- Attack delay decreases every time you encounter the boss, down to 0.25 seconds
            self.timers['attack'] = { Timer.every(math.max(0.25, 0.8 - (self.level / 5 - 1) / 40), function()
                -- Switch beteen 1.1 and 1.2; set self.switched to true so it does each once
                if self.nextAttack == 2 then
                    self.nextAttack = 1
                else
                    self.nextAttack = 2
                end
                self.switched = true
            end) }
        end

        --update position
        self.x = self.x + self.dx * dt

        -- if boss went past edge of screen, reset to edge and go other direction
        if self.x + self.width > VIRTUAL_WIDTH then
            self.x = VIRTUAL_WIDTH - self.width
            self.dx = -self.dx
        elseif self.x < 0 then
            self.x = 0
            self.dx = -self.dx
        end

        if self.switched then
            if self.nextAttack == 1 then
                -- Attack 1.1
                -- Shoot left 7 bullets
                for i=1,7 do
                    table.insert(projectiles, BossProjectile(self.x + 1 + (i - 1) * 6, self.y + self.height - 8, -50 / (133/self.projectileSpeed) * ((7 - i) / 6), self.projectileSpeed))
                end

                -- Shoot right 7 bullets
                for i=1,7 do
                    table.insert(projectiles, BossProjectile(self.x + 81 + (i - 1) * 6, self.y + self.height - 8, 50 / (133/self.projectileSpeed) * ((i - 1) / 6), self.projectileSpeed))
                end

                gSounds['explosion']:play()
                self.switched = false
            else
                -- Attack 1.2
                for i=1,7 do
                    table.insert(projectiles, BossProjectile(self.x + 33 + (i - 1) * 8, self.y + self.height - 8, 0, self.projectileSpeed))
                end

                gSounds['explosion']:play()
                self.switched = false
            end
        end
    elseif self.pattern == 3 then
        -- first branch for setting up attack, second for ending attack
        if not self.timers['attack'] then
            -- Step 3.1: Move to closest edge. Max time for this step: 5,3333 seconds
            if self.x < VIRTUAL_WIDTH / 2 then
                self.dx = math.min(self.dx, -self.dx)
            else
                self.dx = math.max(self.dx, -self.dx)
            end

            -- Step 3.2: When at the edge, become vulnerable, start moving to opposite edge and set up attack timer
            if self.x < 2 or self.x + self.width > VIRTUAL_WIDTH - 2 then
                self.vulnerable = true
                self.dx = -self.dx

                -- make sure there is 24px between the top of each bullet and the next
                local shot_time = 1 / (self.projectileSpeed / 24)
                self.timers['attack'] = { Timer.every(shot_time, function()
                    for i=1, 15 do
                        table.insert(projectiles, BossProjectile(self.x + 1 + (i - 1) * 8, self.y + self.height - 8, 0, self.projectileSpeed))
                    end

                    gSounds['explosion']:play()
                end) }
            end
        else
            --
            -- End pattern 17px before the edge of the screen, so the player always has a chance to avoid
            if self.dx > 0 and self.x + self.width >= VIRTUAL_WIDTH - 18 then
                self.pattern = 0
                Timer.clear(self.timers['attack'])
            elseif self.dx < 0 and self.x <= 18 then
                self.pattern = 0
                Timer.clear(self.timers['attack'])
            end
        end

        --update position
        self.x = self.x + self.dx * dt

        -- if boss went past edge of screen, reset to edge and go other direction
        if self.x + self.width > VIRTUAL_WIDTH then
            self.x = VIRTUAL_WIDTH - self.width
            self.dx = -self.dx
        elseif self.x < 0 then
            self.x = 0
            self.dx = -self.dx
        end
    elseif self.pattern == 4 or self.pattern == 42 then

        if not self.vulnerable then
            self.vulnerable = true
        end

        -- Choose place on x-axis from which to attack (at least 12px from each side, for difficulty reasons
        local destination = destination or math.random(12, VIRTUAL_WIDTH - 12 - self.width)


        -- Go to destination
        if self.x < destination - 1 then
            self.dx = math.max(self.dx, -self.dx)
        elseif self.x > destination + 1 then
            self.dx = math.min(self.dx, -self.dx)
        end

        -- First branch: when arrived at destination. Second: moving to destination
        if (self.x >= destination - 1 or self.x <= destination + 1) and self.dx ~= 0 and self.dy >= 0 then
            --stop moving
            self.dx = 0

            -- shoot warning bullets
            for i=1,2 do
                local cannon = math.random(2)
                table.insert(projectiles, BossProjectile(self.x + (self.width / 3) * cannon, self.y + self.height - 8, math.random(-40, 40), self.projectileSpeed))
            end

            -- determine how long to wait before attacking (shorter on higher levels)
            local pause_time = math.max(0.2, 1.3 - self.level / 50)
            self.timers['attack'] = { Timer.after(pause_time, function()
                gSounds['ram']:play()
                self.dy = self.projectileSpeed
                Timer.clear(self.timers['attack'])
            end) }
        else
            self.x = self.x + self.dx * dt
        end

        if self.dy ~= 0 then
            -- during attack, update y-position
            self.y = self.y + self.dy * dt

            -- when at the bottom of the screen, return to the top
            if self.y + self.height > VIRTUAL_HEIGHT then
                self.y = VIRTUAL_HEIGHT - self.height
                self.dy = -self.dy
            end

            -- when returned to the top, reset to pattern 0
            if self.dy < 0 and self.y <= 30 then
                self.dy = 0
                self.y = 30
                self.dx = self.original_dx
                destination = nil
                self.pattern = 0
            end
        end
    else
        -- branch for self.pattern == 0
        -- reset pattern-specific timers
        if self.timers['reset'] then
            Timer.clear(self.timers['reset'])
            self.timers['reset'] = nil
        end

        if self.timers['attack'] then
            Timer.clear(self.timers['attack'])
            self.timers['attack'] = nil
        end

        -- Choose new pattern after 1.0-3.0 seconds
        local wait_time = math.random(10, 30) / 10
        if not self.timers['pattern'] then
            self.timers['pattern'] = { Timer.after(wait_time, function()
                self.pattern = math.random(4)
                Timer.clear(self.timers['pattern'])
                self.timers['pattern'] = nil
            end)}
        end

        -- boss is invulnerable during this pattern
        self.vulnerable = false

        --update position
        self.x = self.x + self.dx * dt

        -- if boss went past edge of screen, reset to edge and go other direction
        if self.x + self.width > VIRTUAL_WIDTH then
            self.x = VIRTUAL_WIDTH - self.width
            self.dx = -self.dx
        elseif self.x < 0 then
            self.x = 0
            self.dx = -self.dx
        end
    end

    --Update all timers
    for k, timer in pairs(self.timers) do
        Timer.update(dt, timer)
    end
end

function BossOne:render()
    if self.vulnerable then
        love.graphics.setColor(255, 128, 128)
    end
    love.graphics.draw(gTextures['boss1'], self.x, self.y)
    love.graphics.setColor(255, 255, 255)
end
