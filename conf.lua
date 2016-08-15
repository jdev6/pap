io.stdout:setvbuf("no") --For sublimetext output

function love.conf(t)
    t.window.title     = "Pap editor - untitled"
    t.window.width     = 800
    t.window.height    = 600
    t.window.minwidth  = 560
    t.window.minheight = 256
    t.window.resizable = true

    t.modules.physics = false
    t.modules.audio = false
    t.modules.image = false
    t.modules.joystick = false
    t.modules.video = false
end