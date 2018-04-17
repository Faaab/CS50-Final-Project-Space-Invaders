--[[
    GD50
    Space Invaders – Fabian edition

    Skeleton code for project0 by Colton Ogden
    cogden@cs50.harvard.edu
    Implementation of project0 and added features by Fabian van Dijk
    fabiancvandijk@gmail.com

    Utility functions for our game engine.
]]

--[[
    Given an "atlas" (a texture with multiple sprites), as well as a
    width and a height for the tiles therein, split the texture into
    all of the quads by simply dividing it evenly.
]]
function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spritesheet[sheetCounter] =
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
                tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end

function LevelMaker(level)
    alien_table = {}

    -- return boss every 5 levels
    if level % 5 == 0 then
        -- Create first bossfight
        alien_table[1] = BossOne(level)
    else
        -- decide how many rows based on level. Start with 3, and do 1 more every two levels,
        -- with at most 8 Rows
        local numRows = 0

        if level < 3 then
            numRows = 3
        elseif level >= 3 and level < 8 then
            numRows = 4
        elseif level >= 8 and level < 13 then
            numRows = 5
        elseif level >= 13 and level < 23 then
            numRows = 6
        elseif level >= 23 and level < 31 then
            numRows = 7
        else
            -- For the real hardcore players :) (this is nearly impossible)
            numRows = 8
        end

        for i = 1, numRows do
            -- decide which skin this Row will have. Possible values: 2 - 256
            local skin = math.random(2, 256)
            local Row_y = 32 + i * 20

            -- set x-coordinate for first alien
            local alien_x = 32

            -- initialize 8 aliens for this Row with a skin, x and y. Put them in a table
            for j = 1, 8 do
                new_alien = Alien(skin, alien_x, Row_y)

                -- make sure each alien knows whether they're in the last Row (for firing logic)
                if i == numRows then
                    new_alien.lowest = true
                else
                    new_alien.lowest = false
                end

                table.insert(alien_table, new_alien)

                alien_x = alien_x + 24
            end
        end
    end

    return alien_table
end
