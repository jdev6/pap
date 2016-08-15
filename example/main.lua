package.path = package.path .. ";../?.lua" --to require from parent directory

local pap = require("pap")

local map

local xOffset = 0
local yOffset = 0

function love.load()
    map = pap.fromFile("map.dat")
    love.window.setTitle("Pap example")
end

local k = love.keyboard.isDown
function love.update(dt)

    move = dt * -200

    if k "up" then
        yOffset = yOffset - move
    end if k "down" then
        yOffset = yOffset + move
    end if k "left" then
        xOffset = xOffset - move
    end if k "right" then
        xOffset = xOffset + move
    end
end

local g = love.graphics
local fmt = string.format
function love.draw()
    g.setColor(255,0,0)
    map:forEach("red", function(x,y)
        --print each tile with brush red as a red square
        g.rectangle("fill", xOffset + x*64, yOffset + y*64, 64, 64)
    end)

    g.setColor(0,255,0)
    map:forEach("green", function(x,y)
        --print each tile with brush green as a green square
        g.rectangle("fill", xOffset + x*64, yOffset + y*64, 64, 64)
    end)

    g.setColor(255,255,255)
    g.print(fmt("move with arrow keys\nx offset: %i\ny offset: %i", -xOffset, -yOffset))
end