local camera = {}
camera._x = 0
camera._y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0

function camera.set()
  love.graphics.push()
  love.graphics.rotate(-camera.rotation)
  love.graphics.scale(1 / camera.scaleX, 1 / camera.scaleY)
  love.graphics.translate(-camera._x, -camera._y)
end

function camera.unset()
  love.graphics.pop()
end

function camera.move(dx, dy)
  camera._x = camera._x + (dx or 0)
  camera._y = camera._y + (dy or 0)
end

function camera.rotate(dr)
  camera.rotation = camera.rotation + dr
end

function camera.scale(sx, sy)
  sx = sx or 1
  camera.scaleX = camera.scaleX * sx
  camera.scaleY = camera.scaleY * (sy or sx)
end

function camera.setX(value)
  if camera._bounds then
    camera._x = math.clamp(value, camera._bounds.x1, camera._bounds.x2)
  else
    camera._x = value
  end
end

function camera.setY(value)
  if camera._bounds then
    camera._y = math.clamp(value, camera._bounds.y1, camera._bounds.y2)
  else
    camera._y = value
  end
end

function camera.setPosition(x, y)
  if x then camera.setX(x) end
  if y then camera.setY(y) end
end

function camera.getX()
    return camera._x
end

function camera.getY()
    return camera._y
end

function camera.getPosition()
    return {camera.getX(), camera.getY()}

end

function camera.setScale(sx, sy)
  camera.scaleX = sx or camera.scaleX
  camera.scaleY = sy or camera.scaleY
end

function camera.getBounds()
  return unpack(camera._bounds)
end

function camera.setBounds(x1, y1, x2, y2)
  camera._bounds = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end

return camera
