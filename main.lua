local suit = require("lib.suit")
local inspect = require("lib.inspect")
local camera = require("lib.camera")
local pap = require("pap")

local state = "main"

local g  = love.graphics
local m  = love.mouse
local fs = love.filesystem

local DRAW_AREA_X   = 110
local DRAW_AREA_Y   = 40
local DRAW_AREA_W   = g.getWidth()  - 115
local DRAW_AREA_H   = g.getHeight() - 45
local MAX_CELL_SIZE = 256
local MIN_CELL_SIZE = 3
local TILE_COLOR    = {255,255,255, 50}

local input = {text = "", value = 64, min = MIN_CELL_SIZE, max = MAX_CELL_SIZE} --for text input and cell size
local input2 = {text = ""} --for map width
local input3 = {text = ""} --for map height

local map = pap.fromData {
    brushes = {},
    width = 16,
    height = 16,
    data = {}
}

local selectedBrush = 1
local cellSize = 64
local showCellSizeError = false
local gridOn = true

local fileName = "untitled"

local function inDrawArea()
    --returns true if mouse is in draw area
    local x,y = m.getX(), m.getY()
    return
        x >= DRAW_AREA_X and
        x <= DRAW_AREA_W + DRAW_AREA_X and
        y >= DRAW_AREA_Y and
        y <= DRAW_AREA_H + DRAW_AREA_Y
end

function love.load()
    love.keyboard:setKeyRepeat(true)
end

----------------------------
----------------------------
------UPDATE FUNCTION-------
----------------------------
----------------------------

function love.update(dt)
    suit.layout:reset(5, 5)
    suit.layout:padding(10,10)

    -------------
    --BASIC GUI--
    -------------

    if suit.Button("New brush", suit.layout:col(80, 30)).hit then
        print("new brush")
        input.text = ""
        state = state == "new brush" and "main" or "new brush"
    end
    if suit.Button("Save", suit.layout:col(50, 30)).hit then
        print("save menu")
        input.text = fileName
        state = state == "saving" and "main" or "saving"
    end
    if suit.Button("Open", suit.layout:col(50, 30)).hit then
        print("open menu")
        input.text = ""
        state = state == "opening" and "main" or "opening"
    end
    if suit.Button("Cell size", suit.layout:col(60, 30)).hit then
        print("cell size change")
        input.text = tostring(cellSize)
        state = state == "cell size" and "main" or "cell size"
    end
    if suit.Button("Map size", suit.layout:col(60, 30)).hit then
        print("Map size change")
        state = state == "map size" and "main" or "map size"
        input2.text = tostring(map.width)
        input3.text = tostring(map.height)
    end
    if suit.Button("Toggle grid", suit.layout:col(80, 30)).hit then
        print("toggle grid")
        gridOn = not gridOn
    end
    if suit.Button("Clear", suit.layout:col(50, 30)).hit then
        print("clear")
        map.data = {}
    end
    if #map.brushes > 0 and suit.Button("Remove selected brush", suit.layout:col(160, 30)).hit then
        print("remove brush")

        map:removeBrush(selectedBrush)
        if not map.brushes[selectedBrush] then
            selectedBrush = selectedBrush - 1
        end
    end
    if suit.Button("Quit", g.getWidth()-55, 5, 50, 30).hit then
        print("quit")
        love.event.quit()
    end

    suit.layout:reset(15, 40)
    suit.layout:padding(10,10)
    suit.Label("Brushes:", suit.layout:row(80, 30))

    for k,v in ipairs(map.brushes) do
        if suit.Button(selectedBrush == k and "> "..v or v, suit.layout:row(80, 20)).hit then
            print("select brush "..v)
            selectedBrush = k
        end
    end

    --start states

    if state == "main" then
        if inDrawArea() then
            local x = math.floor((m.getX() + camera.getX() - DRAW_AREA_X) / cellSize)
            local y = math.floor((m.getY() + camera.getY() - DRAW_AREA_Y) / cellSize)

            if #map.brushes > 0 and m.isDown(1) and x >= 0 and y >= 0 and x < map.width and y < map.height then
                --Draw something
                map:setData(x,y, selectedBrush, 1)

            elseif m.isDown(2) then
                --Erase
                map:setData(x,y, selectedBrush, nil)
            end
        end

    elseif state == "new brush" then
        suit.layout:reset(155,60)
        suit.layout:padding(10,10)

        suit.Label("Enter brush name:", suit.layout:row(130, 20))
        suit.Input(input, suit.layout:row(140, 20))
        if input.text ~= "" and suit.Button("OK", 300, 90, 25, 20).hit then
            print("ok")
            state = "main"
            map:newBrush(input.text)
            if #map.brushes == 1 then
                selectedBrush = 1
            end
        end
        if suit.Button("Cancel", suit.layout:row(60, 20)).hit then
            print("cancel")
            state = "main"
        end
        if input.text == "" then
            suit.Label("Brush name can't be empty", suit.layout:row(180, 20))
        end

    elseif state == "saving" then
        suit.layout:reset(155,60)
        suit.layout:padding(10,10)

        suit.Label("Enter file path:", suit.layout:row(120, 20))
        suit.Input(input, suit.layout:row(140, 20))
        if input.text ~= "" and suit.Button("OK", 300, 90, 25, 20).hit then
            print("saving")
            local data = "return " .. inspect {
                brushes = map.brushes,
                width = map.width,
                height = map.height,
                data = map.data
            }

            print("data: '"..data.."'")
            local fp, err = io.open(input.text, "w")
            if fp then
                fp:write(data)
                fileName = input.text
                love.window.setTitle("Pap editor - " .. fileName)
                state = "main"
                fp:close()
            else
                state = "error"
                errCode = err
            end
        end
        if suit.Button("Cancel", suit.layout:row(60, 20)).hit then
            print("cancel")
            state = "main"
        end

    elseif state == "opening" then
        suit.layout:reset(155,60)
        suit.layout:padding(10,10)

        suit.Label("Enter file path:", suit.layout:row(120, 20))
        suit.Input(input, suit.layout:row(140, 20))
        if input.text ~= "" and suit.Button("OK", 300, 90, 25, 20).hit then
            print("opening")

            local newmap, err = pap.fromFile(input.text, false)

            if not newmap then
                print("error")
                state = "error"
                errCode = err
            else
                map = newmap
                state = "main"
                fileName = input.text
                love.window.setTitle("Pap editor - " .. fileName)
            end
        end
        if suit.Button("Cancel", suit.layout:row(60, 20)).hit then
            print("cancel")
            state = "main"
        end

    elseif state == "error" then
        if suit.Button("Error: "..errCode, 175,60,190,40).hit then
            state = "main"
        end

    elseif state == "cell size" then
        suit.layout:reset(155,60)
        suit.layout:padding(10,10)

        suit.Label("Enter cell size:", suit.layout:row(100, 20))

        suit.Slider(input, suit.layout:row(130, 20))

        local val = math.floor(input.value)

        local tmp = {suit.layout:nextCol()}
        suit.Label(val, tmp[1], tmp[2])
        tmp = nil

        cellSize = val


        if suit.Button("Cancel", suit.layout:row(60, 20)).hit then
            print("cancel")
            state = "main"
        end

    elseif state == "map size" then
        suit.layout:reset(155,60)
        suit.layout:padding(5,10)

        suit.Label("Map width:", suit.layout:row(75, 20))
        suit.Input(input2, suit.layout:row(140, 20))

        local w = tonumber(input2.text)
        local tmp = {suit.layout:nextCol()}

        if w and suit.Button("Set", tmp[1], tmp[2], 30, 20).hit then
            print("set width")
            map.width = w
        end

        suit.Label("Map height:", suit.layout:row(80, 20))
        suit.Input(input3, suit.layout:row(140, 20))

        local h = tonumber(input3.text)
        tmp = {suit.layout:nextCol()}

                               --the space is intentional
        if h and suit.Button("Set ", tmp[1], tmp[2], 30, 20).hit then
            print("set width")
            map.height = h
        end
    end
end

---------------------------
---------------------------
-------DRAW FUNCTION-------
---------------------------
---------------------------

function love.draw()
    g.setBackgroundColor(40,40,40)
    
    camera:set()

    DRAW_AREA_W = g.getWidth()  - 115
    DRAW_AREA_H = g.getHeight() - 45

    if gridOn then
        --Draw grid

        local w = map.width * cellSize
        local h = map.height * cellSize

        --vertical
        for x = 0, w, cellSize do
            g.line(DRAW_AREA_X + x, DRAW_AREA_Y, DRAW_AREA_X + x, DRAW_AREA_Y + h)
        end

        --horizontal
        for y = 0, h, cellSize do
            g.line(DRAW_AREA_X, DRAW_AREA_Y + y, DRAW_AREA_X + w, DRAW_AREA_Y + y)
        end
    end

    g.setColor(TILE_COLOR)
    for brushName,b in pairs(map.data) do
        for y,t in pairs(b) do
            for x,_ in pairs(t) do
                if x <= map.width and y <= map.height then
                    --draw cell
                    g.rectangle("fill", DRAW_AREA_X + x * cellSize, DRAW_AREA_Y + y * cellSize, cellSize, cellSize)
                    g.setColor(0,0,0)
                    --print text
                    g.print(map.brushes[brushName], DRAW_AREA_X + x * cellSize + 5, DRAW_AREA_Y + y * cellSize + cellSize/2 - 5)
                    g.setColor(TILE_COLOR)
                end
            end
        end
    end

    camera:unset()

    if state == "new brush" or state == "map size" then
        g.setColor(80, 80, 80)
        g.rectangle("fill", 145,50,190,130, 4)

    elseif state == "saving" or state == "opening" or state == "cell size" then
        g.setColor(80, 80, 80)
        g.rectangle("fill", 145,50,190,100, 4)
    end
    g.setColor(80, 80, 80)
    g.rectangle("fill", 5, 40, 100, g.getHeight() - 45, 4)
    g.rectangle("line", DRAW_AREA_X, DRAW_AREA_Y, DRAW_AREA_W, DRAW_AREA_H, 4)
    g.setColor(255,255,255)

    suit.draw()
end

function love.mousemoved(x,y, dx,dy)
    --Move in the draw area with the middle mouse button
    if inDrawArea() and m.isDown(3) then
        camera.move(-dx, -dy)
    end
end

function love.wheelmoved(x,y)
    --Zoom in/out
    if inDrawArea() and
      (state == "main" or state == "cell size") and
      (y + cellSize > MIN_CELL_SIZE) and
      (y + cellSize < MAX_CELL_SIZE) then

        cellSize = cellSize + y
        input.value = cellSize
    end
end

function love.filedropped(file)
    --open a file when dropped

    print("opening")

    local path = file:getFilename()

    local newmap, err = pap.fromFile(path, true)

    if not newmap then
        print("error")
        state = "error"
        errCode = err
    else
        map = newmap
        state = "main"
        fileName = path
        love.window.setTitle("Pap editor - " .. fileName)
    end
end

function love.textinput(t)
    suit.textinput(t)
end

function love.keypressed(key)
    if key == "escape" then
        print("cancel")
        state = "main"
    else
        suit.keypressed(key)
    end
end
