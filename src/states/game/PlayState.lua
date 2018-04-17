--[[
    GD50
    Space Invaders – Fabian edition

    Skeleton code for project0 by Colton Ogden
    cogden@cs50.harvard.edu
    Implementation of project0 and added features by Fabian van Dijk
    fabiancvandijk@gmail.com

    During the PlayState, the Player gets to move their ship around and shoot at the aliens
    descending upon them (or on every 5th level: at the boss). When the Player takes damage
    by colliding with a bullet or an alien, they lose a life and the aliens are reset to
    their original position.

    For debugging purposes, I have given the player the option to transition to the
    ScoreState by pressing 'q'.
]]

PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    -- take params
    self.player = params.player
    self.highScore = params.highScore
    self.highestLevel = params.highestLevel
    self.level = params.startingLevel

    -- initialize variables for new game
    self.score = 0
    self.lives = 3

    -- on entering PlayState, generate a level
    self.alien_table = LevelMaker(self.level)

    -- make a table with projectiles
    self.projectiles = {}

    -- for keeping track of whether the player has won a level
    self.victory = false
end

function PlayState:update(dt)
    if self.victory == false then
        -- if no lives are left, transition to ScoreState
        -- For debugging: press 'q' also lets you transition to ScoreState
        if self.lives == 0 or love.keyboard.wasPressed('q') then
            gStateMachine:change('score', {
                score = self.score,
                highScore = self.highScore,
                level = self.level,
                highestLevel = self.highestLevel
            })
        end

        -- update player
        self.player:update(dt)

        -- variable for checking victory
        self.aliens_exist = false

        -- update aliens
        for k, alien in pairs(self.alien_table) do
            if not alien.health then
                -- for regular aliens
                alien:update(dt, self.projectiles, self.level)
            else
                -- for bosses
                alien:update(dt, self.projectiles)
            end
            if alien.inPlay == true then
                self.aliens_exist = true
            end

            -- For non-boss aliens: if an alien is left-/rightmost and collides with the edge, reverse horizontal speed and shift all aliens down
            if not alien.health then
                if alien:edgeCollide() then
                    for key, alien in pairs(self.alien_table) do
                        alien.dx = -alien.dx
                        alien.y = alien.y + ALIEN_DOWNSHIFT
                    end
                end
            end

            -- handle collision between normal/boss aliens and player
            if alien:collides(self.player) and alien.inPlay == true and self.player.died == false then
                -- handle alien-side of collision
                if not alien.health then
                    -- normal aliens die after collision
                    alien.inPlay = false
                elseif alien.vulnerable then
                    -- bosses lose 1 health, if vulnerable
                    alien.health = alien.health - 1
                end

                -- normal aliens reset to original position on y-axis
                if not alien.health then
                    for key, alien in pairs(self.alien_table) do
                        alien.x = alien.original_x
                        alien.y = alien.original_y
                    end
                end

                -- handle player-side of collision
                gSounds['death']:play()
                self.lives = self.lives - 1
                self.player.died = true
                self.player.respawnCounter = 0
            end
        end

        -- if we get here and aliens do not exist, we've won
        if self.aliens_exist == false then
            self.victory = true
            self.victoryCountdown = 0
            self.level = self.level + 1
            self.alien_table = LevelMaker(self.level)
            self.projectiles = {}
        end

        -- update all projectiles
        for k, projectile in pairs(self.projectiles) do
            projectile:update(dt)
            if projectile.y > VIRTUAL_HEIGHT or projectile.y < -PROJECTILE_HEIGHT then
                -- despawn projectile when it goes above or below the edge of the screen
                projectile.inPlay = false
            end

            -- handle collision detection of projectiles with player
            if projectile:collides(self.player) and projectile.origin == 'alien' and self.player.died == false then
                gSounds['death']:play()
                self.lives = self.lives - 1
                projectile.inPlay = false
                self.player.died = true
                self.player.respawnCounter = 0
            end

            -- handle collision detection of projectiles with aliens
            for key, alien in pairs(self.alien_table) do
                if alien.inPlay == true then
                    if projectile:collides(alien) and projectile.origin == 'player' then
                        if alien.health then
                            -- for bosses
                            if alien.vulnerable == true then
                                alien.health = alien.health - 1
                                self.score = self.score + 10
                                gSounds['bosshurt']:play()
                            else
                                gSounds['nothurt']:play()
                            end

                            if alien.health < 1 then
                                -- boss is defeated; add score and 1 life
                                alien.inPlay = false
                                self.score = self.score + 2500 + self.level * 500
                                self.lives = self.lives + 1
                                self.bossDefeated = true
                            end
                        else
                            --for normal enemies
                            alien.inPlay = false
                            self.score = self.score + 100 + self.level * 10
                            gSounds['explosion']:play()
                        end


                        projectile.inPlay = false

                        -- make sure that all aliens know if they're the lowest
                        if alien.lowest == true then
                            alien.lowest = false
                            -- detect if there is a lower alien
                            for i = key, 1, -8 do
                                if self.alien_table[i].inPlay == true then
                                    self.alien_table[i].lowest = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end

        for i = #self.projectiles, 1, -1 do
            if self.projectiles[i].inPlay == false then
                table.remove(self.projectiles, i)
            end
        end

        --input handling for shooting
        if love.keyboard.wasPressed('space') and self.player.died == false then
            -- create new projectile
            table.insert(self.projectiles, Projectile(self.player.x + self.player.width / 2 - PROJECTILE_WIDTH / 2, self.player.y + 1, 'player'))
            gSounds['fire']:play()
        end
    else
        -- if player has won: handle countdown to next level
        self.victoryCountdown = self.victoryCountdown + dt
        if self.victoryCountdown >= SECONDS_BETWEEN_LEVELS then
            self.victory = false
            self.bossDefeated = false
        end
    end
end

function PlayState:render()
    -- only render projectiles and aliens if player has not won yet
    if self.victory == false then
        -- render projectiles in red, then reset draw color to white
        love.graphics.setColor(255, 79, 51, 255)
        for k, laser in pairs(self.projectiles) do
            self.projectiles[k]:render()
        end
        love.graphics.setColor(255, 255, 255, 255)

        -- render aliens
        for k, alien in pairs(self.alien_table) do
            self.alien_table[k]:render()
        end
    else
        -- render grey textbox with 'next level: ' and 'score: '
        love.graphics.setColor(128, 128, 128, 255)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 5, 100, VIRTUAL_WIDTH / 5 * 3, 50)
        love.graphics.setColor(255, 255, 255, 255)

        if self.bossDefeated then
            love.graphics.setColor(128, 128, 128, 255)
            love.graphics.rectangle('fill', VIRTUAL_WIDTH / 5, 150, VIRTUAL_WIDTH / 5 * 3, 16)
            love.graphics.setColor(255, 255, 255, 255)
        end

        love.graphics.setFont(gFonts['medium'])
        love.graphics.printf('Next level: ' .. tostring(self.level), VIRTUAL_WIDTH / 5 + 4, 104, VIRTUAL_WIDTH / 5 * 4, 'left')
        love.graphics.printf('Score: ' .. tostring(self.score), VIRTUAL_WIDTH / 5 + 4, 124, VIRTUAL_WIDTH / 5 * 4, 'left')

        if self.bossDefeated then
            love.graphics.printf('Checkpoint!', VIRTUAL_WIDTH / 5 + 4, 142, VIRTUAL_WIDTH, 'left')
        end
    end

    -- render player
    self.player:render()

    -- render UI text in white
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 0, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('Level: ' .. tostring(self.level), 0, 0, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Lives: ' .. tostring(self.lives), VIRTUAL_WIDTH / 4 * 3, 0, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('High Score: ' .. tostring(self.highScore), 0, 16, VIRTUAL_WIDTH, 'left')
end
