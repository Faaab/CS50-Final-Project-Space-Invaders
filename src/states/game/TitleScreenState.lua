--[[
    GD50
    Space Invaders Distro

    TitleScreenState Class

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The TitleScreenState simply displays the title of the game and waits for the player
    to press Enter in order to commence with the PlayState. It also shows the highest
    level the player has reached, if higher than 1. If the player has reached a checkpoint,
    the player can choose to start there by pressing the left or right arrow keys.
]]

TitleScreenState = Class{__includes = BaseState}

function TitleScreenState:enter(params)
    self.player = Player()

    -- load high scores if the file exists
    if love.filesystem.exists('highscore.txt') then
        local savegame = love.filesystem.read('highscore.txt')

        -- read serialized data from save file
        local data_generator = loadstring(savegame)
        local data = data_generator()

        -- get data from savefile
        self.highScore = data['highScore']
        if data['highestLevel'] then
            self.highestLevel = data['highestLevel']
            if self.highestLevel % 5 == 0 then
                self.highestCheckpoint = self.highestLevel - 4
            else
                self.highestCheckpoint = self.highestLevel - (self.highestLevel % 5) + 1
            end
        else
            self.highestLevel = 1
        end
    else
        -- if the file does not exist, we set the bar low
        self.highScore = 42
        self.highestLevel = 1
    end

    self.startingLevel = 1
end

function TitleScreenState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play', {
            highScore = self.highScore,
            player = self.player,
            highestLevel = self.highestLevel,
            startingLevel = self.startingLevel
        })
    end

    -- for handling level selection: you can choose any level >= 1
    if love.keyboard.wasPressed('right') then
        self.startingLevel = math.min(self.startingLevel + 5, self.highestCheckpoint)
    end

    if love.keyboard.wasPressed('left') then
        self.startingLevel = math.max(1, self.startingLevel - 5)
    end
end

function TitleScreenState:render()
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf('Space Invaders', 0, 25, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter', 0, 75, VIRTUAL_WIDTH, 'center')
    -- render 'High Score: [self.highScore]'
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf('High Score: ' .. tostring(self.highScore), 0, 150, VIRTUAL_WIDTH, 'center')

    -- Only render 'highest level' and level selection if player has achieved a level higher than 1
    if self.highestLevel > 1 then
        love.graphics.printf('Highest Level: ' .. tostring(self.highestLevel), 0, 160, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Starting level: ' .. tostring(self.startingLevel), 0, 170, VIRTUAL_WIDTH, 'center')
    end

    --render player at the bottom of the screen
    self.player:render()
end
