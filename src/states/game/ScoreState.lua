--[[
    GD50
    Space Invaders – Fabian edition

    Skeleton code for project0 by Colton Ogden
    cogden@cs50.harvard.edu
    Implementation of project0 and added features by Fabian van Dijk
    fabiancvandijk@gmail.com

    The ScoreState is designed to do two things:

        1) Display the score from the last round played update the high score if it's
        now such.

        2) Save the new high score if so to disk for persistence, along with the highest
        level the player has reached.
]]

ScoreState = Class{__includes = BaseState}

function ScoreState:enter(params)
    -- set score and high score
    self.score = params.score
    self.highScore = params.highScore
    self.level = params.level
    self.highestLevel = params.highestLevel

    if self.level > self.highestLevel then
        self.highestLevel = self.level
    end

    if self.score > self.highScore then
        self.newHighScore = true
        self.highScore = self.score
    else
        self.newHighScore = false
    end

    -- create save file
    local data = { highScore = self.highScore, highestLevel = self.highestLevel }
    local savegame = Serialize(data)

    -- write new high score in save file
    love.filesystem.write('highscore.txt', savegame)
end

function ScoreState:update(dt)
    -- go to Title if enter is presses
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('title')
    end
end

function ScoreState:render()
    -- render different text based on whether a new high score was set
    love.graphics.setFont(gFonts['medium'])
    if self.newHighScore == true then
        -- congratulate player
        love.graphics.printf('You set a new High Score!', 0, 30, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Oof! You lost!', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('High Score: ' .. tostring(self.highScore), 0, 56, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.printf('Score: ' .. tostring(self.score), 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'center')
end
