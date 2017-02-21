-- Copyright (c) 2016 jdev6

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files(the
-- "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
-- following conditions:

-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
-- OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local pap = {}

local mapMt = { --map object metatable
    __index = {
        forEach = function(self, brush, cb)
            --executes cb() for each tile in brush

            if not cb and type(brush) == "function" then cb = brush; brushes = self.brushes
            else brushes = {brush}
            end

            for _,brush in ipairs(brushes) do
                local i = self:brushIndex(brush) --brush index

                print(i,brush)

                local data = self.data[i]

                for y,t in ipairs(data) do
                    for x,v in ipairs(t) do
                        cb(x,y,brush,v)
                    end
                end
            end
        end,

        setData = function(self, x,y, b, v)
            b = self:brushIndex(b)
 
            local data = self.data

            data[b] = data[b] or {}
            data[b][y] = data[b][y] or {}

            data[b][y][x] = v

            if data[b][y] == {} then
                --if y is empty remove it to save memory
                data[b][y] = nil
            end

            self.data = data
            return data
        end,

        getData = function(self, x,y, b)
            b = self:brushIndex(b)

            local data = self.data

            if data[b] and data[b][y] then
                return data[b][y][x]
            end
        end,

        newBrush = function(self, brush)
            table.insert(self.brushes, brush)
        end,

        brushIndex = function(self, brush)
            --returns brush index from brush name
            local i

            if type(brush) == "string" then
                for b,v in ipairs(self.brushes) do
                    if v == brush then
                        i = b
                    end
                end

            elseif type(brush) == "number" then
                i = brush
            end

            if not brush then
                error("No brush provided")
            end
            if not i then
                error("Brush "..brush.." doesn't exist")
            end
            return i
        end,

        removeBrush = function(self, brush)
            brush = self:brushIndex(brush)
            table.remove(self.brushes, brush)
            table.remove(self.data, brush)
        end
    }
}

function pap.fromFile(path, useLfs)
    --Use love.filesystem's load function when love is available and useLfs isn't set to false
    useLfs = useLfs ~= false and true

    local load = (love and useLfs) and love.filesystem.load or loadfile

    local chunk, err = load(path)
    if chunk then
        local ok, res = pcall(chunk)
        if ok then
            return pap.fromData(res)
        end
        err = res
    end
    return nil, err
end

function pap.fromData(data)
    local ok, map = pcall(setmetatable, data, mapMt)

    if type(map) ~= "table" then
        return
    end

    map.width = map.width or 16
    map.height = map.height or 16
    map.data = map.data or {}
    map.brushes = map.brushes or {}
    return map
end

function pap.new()
    return setmetatable({brushes = {}, data = {}, width = 16, height = 16}, mapMt)
end

setmetatable(pap, {
    __call = function(self, ...)
        --alias pap() to pap.new()
        return self.new(...)
    end
})

return pap