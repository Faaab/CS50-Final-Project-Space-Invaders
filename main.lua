--[[
    GD50
    Space Invaders – Fabian edition

    Skeleton code for project0 by Colton Ogden
    cogden@cs50.harvard.edu
    Implementation of project0 and added features by Fabian van Dijk
    fabiancvandijk@gmail.com

    ----------
    Original description of project0 by Colton Ogden:
    Space Invaders was an Atari classic released in 1978 by Taito. The game pits
    the player, a lone starship, against hordes of alien creatures that slowly descend
    upon him/her, shooting bullets along the way. The player has a limited number of lives,
    where each life is the ability to take one point of damage (by either taking a bullet
    or by colliding with an alien). The original version of the game included shields the
    player could hide behind, but this version of the game doesn't require them.
    ----------

    Works under LÖVE2D 0.10.2

    ----------

    To make this into a final project for Harvard's CS50x, I (Fabian) have added several features
    on top of completing project0 as described in https://cs50.github.io/games/projects/0/

    1. The major feature added is the boss fight, which repeats every 5th level and becomes gradually
    more difficult. Code can be found in BossOne.lua.

    2. I upgraded the save system using Knife.serialize, to keep track of the highest level
    the player has reached (as well as the high score). This gives player a second
    measure of success: highest cleared level.

    3. The player is now able to choose a checkpoint at which to start.
    Checkpoints are set after each boss fight.

    4. Difficulty scaling based on level. On higher levels:
    a. Aliens not only move more quickly (as specified in project0) but also shoot more often
    b. BossOne moves and shoots more quickly
    c. LevelMaker spawns more rows of aliens (up to 8 rows on level 31+)

    5. I have balanced the game's difficulty curve around the boss fights, with the idea in mind that a player who likes the game will play ~25 levels (although some parts of my code will scale after that).

    I have also included some new assets:
    Visual: Boss_Projectile.png and boss1.png – both from public domain
    Audio: bosshurt.wav, nothurt.wav and ram.wav – made with bfxr
]]

require 'src/Dependencies'

function love.load()
    -- load sounds
    gSounds = {
        ['alien_shot'] = love.audio.newSource('sounds/alien_shot.wav', 'static'),
        ['death'] = love.audio.newSource('sounds/death.wav', 'static'),
        ['explosion'] = love.audio.newSource('sounds/explosion.wav', 'static'),
        ['fire'] = love.audio.newSource('sounds/fire.wav', 'static'),
        ['nothurt'] = love.audio.newSource('sounds/nothurt.wav', 'static'),
        ['bosshurt'] = love.audio.newSource('sounds/bosshurt.wav', 'static'),
        ['ram'] = love.audio.newSource('sounds/ram.wav', 'static')
    }

    -- load graphics
    love.graphics.setDefaultFilter('nearest', 'nearest')

    gTextures = {
        ['mainsheet'] = love.graphics.newImage('graphics/sprites.png'),
        ['boss_projectile'] = love.graphics.newImage('graphics/Boss_Projectile.png'),
        ['boss1'] = love.graphics.newImage('graphics/boss1.png')
    }

    gFrames = {
        ['spaceships'] = GenerateQuads(gTextures['mainsheet'], 16, 16)
    }

    -- load font tables
    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
    }
    love.graphics.setFont(gFonts['small'])

    -- set up push
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- set seed for math.random
    math.randomseed(os.time())

    -- window title
    love.window.setTitle('Fabian Invader')

    -- set up StateMachine
    gStateMachine = StateMachine {
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end,
        ['title'] = function() return TitleScreenState() end
    }
    gStateMachine:change('title')

    -- initiate table to handle inputs
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- keep track of kees pressed
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)
    -- delegate update logic to StateMachine
    gStateMachine:update(dt)

    -- reset keysPressed table
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:apply('start')

    -- set background color to dark purple
    love.graphics.clear(0, 0, 0, 255)

    -- let the state machine do its thing
    gStateMachine:render()

    push:apply('end')
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end
