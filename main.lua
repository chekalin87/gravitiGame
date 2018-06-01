io.stdout:setvbuf("no")
local menu = require("menu")
local windowHeight = love.graphics.getHeight()
local windowWidth = love.graphics.getWidth()
local gravity = 2000
local fullscreen = false
local obj = {}
local bul = {}
local sunX = windowWidth/2            --абсолютные координаты солнца
local sunY = windowHeight/2
local swingCam = false
local follow = false
local mouseX
local mouseY
local pause = false
local speedUp = 0.01
local speedDown = -0.01
local background = love.graphics.newImage("images/background.jpg")
local pointerSkin = love.graphics.newImage("images/pointer.png")
local soundTrack = love.audio.newSource("sounds/Rainstep.mp3", "static")
local backgroundWidth = background:getWidth()
local backgroundHeight = background:getHeight()
print(backgroundWidth, backgroundHeight)
local points = {}

local function getRelX(x) return x - sunX end
local function getAbsX(x) return x + sunX end
local function getRelY(y) return y - sunY end
local function getAbsY(y) return y + sunY end

function love.load()
  
  menu.boo()
  soundTrack:setLooping(true)
  soundTrack:play()
  love.window.setTitle("Gravity")
  love.window.setFullscreen(fullscreen, "desktop")
  print(windowHeight, windowWidth)
  obj.sun = {x = getRelX(sunX), y = getRelY(sunY)}
  
  obj.ship = {x = obj.sun.x,
    y = obj.sun.y - 100,
    sx = 4.5,
    sy = 0,
    r = 45,
    skin = love.graphics.newImage("images/ship.png"),
    track = 1000}
  
  obj.planet3 = {x = obj.sun.x, y = obj.sun.y - 200, sx = 3.2, sy = 0, track = 400}
  obj.planet2 = {x = 41.26, y = -130.61, sx = 3.9, sy = 0.83, track = 400}
  obj.planet1 = {x = 24.798, y = -51.2347, sx = 5.5987, sy = 2.2719, track = 400}
end

function love.keyreleased(key)
  if key ~= nil then print(key) end
  if key == "f11" then
    local tsX, tsY = sunX - windowWidth/2, sunY - windowHeight/2
    fullscreen = not fullscreen
    love.window.setFullscreen(fullscreen, "desktop")
    windowHeight = love.graphics.getHeight()
    windowWidth = love.graphics.getWidth()
    sunX = tsX + windowWidth/2
    sunY = tsY + windowHeight/2
    obj.sun = {x = getRelX(sunX), y = getRelY(sunY)}
  elseif key == "space" then 
    pause = not pause
  elseif key == "f" then 
    follow = not follow
  elseif key == "escape" then 
    love.event.quit()
  end
end

local function changeSpeed(obJ)
  local dist = math.sqrt((obj.sun.x - obJ.x)^2 + (obj.sun.y - obJ.y)^2)
  local distX = obJ.x - obj.sun.x
  local distY = obJ.y - obj.sun.y
  local grav = gravity/dist^2
  local coof = dist/grav
  obJ.sx = obJ.sx - distX/coof
  obJ.sy = obJ.sy - distY/coof
end

local function changePos(t)
  changeSpeed(t)
  t.x = t.x + t.sx
  t.y = t.y + t.sy
end

local function mouseIsDuwn()
  if love.mouse.isDown(2) then
    if swingCam then 
      sunX = mouseX + love.mouse.getX()
      sunY = mouseY + love.mouse.getY()
    end
  end
end

function love.mousepressed(x, y, button)
  if button == 1 and not pause then 
    x = getRelX(x)
    y = getRelY(y)
    local speed = 1
    local dist = math.sqrt((obj.ship.x - x)^2 + (obj.ship.y - y)^2)
    local coof = dist/speed
    local distX = x - obj.ship.x
    local distY = y - obj.ship.y
    bul[#bul+1] = {x = obj.ship.x, y = obj.ship.y, sx = (distX / coof)+obj.ship.sx, sy = (distY / coof)+obj.ship.sy}
  end
  if button == 2 then
    follow = false
    mouseX = sunX - x
    mouseY = sunY - y
    swingCam = true
  end
end

function love.mousereleased(x, y, button)
  if button == 2 then
      swingCam = false
  end
end

local function acceleration(direction)
  local sy
  if direction == "w" then
    sy = math.sin(math.rad(obj.ship.r)) * speedUp
  elseif direction == "s" then
    sy = math.sin(math.rad(obj.ship.r)) * speedDown
  end
  local sx = sy / math.tan(math.rad(obj.ship.r))
  obj.ship.sx = obj.ship.sx + sx
  obj.ship.sy = obj.ship.sy + sy
end

local function trackPoints()
  for k,v in pairs(obj) do
    if v.track ~= nil then
      if points[k] == nil then points[k] = {} end
      points[k][#points[k]+1] = {1,2}
      points[k][#points[k]][1] = v.x
      points[k][#points[k]][2] = v.y
      if #points[k] > v.track then table.remove(points[k], 1) end
    end
  end
end

local function followTheShip()
  if follow then 
    sunX = obj.sun.x - obj.ship.x + windowWidth/2
    sunY = obj.sun.y - obj.ship.y + windowHeight/2
  end
end

local function drawPointer()
  if sunX < 0 or sunX > windowWidth or sunY < 0 or sunY > windowHeight then
    local centreX = windowWidth/2
    local centreY = windowHeight/2
    local dx, dy = sunX - centreX, sunY - centreY
    local angleA = math.deg(math.atan2(0 - centreX, 0 - centreY))
    local angleB = math.deg(math.atan2(windowWidth - centreX, 0 - centreY))
    local angleC = math.deg(math.atan2(windowWidth - centreX, windowHeight - centreY))
    local angleD = math.deg(math.atan2(0 - centreX, windowHeight - centreY))
    local angleSun = math.deg(math.atan2(dx, dy))
    local indent = 20
    local x,y
    
    if angleSun < angleA or angleSun > angleB then                                              -- AB
      x = - (math.tan(math.rad(angleSun)) * (centreY - indent)) + centreX
      love.graphics.draw(pointerSkin, x, indent, math.rad(-angleSun), 1, 1, 10, 10)
      
    elseif angleSun < angleB and angleSun > angleC then                                         -- BC
      y = - ((indent - centreX) / math.tan(math.rad(angleSun))) + centreY
      love.graphics.draw(pointerSkin, windowWidth - indent, y, math.rad(-angleSun), 1, 1, 10, 10)
      
    elseif angleSun < angleC and angleSun > angleD then                                         -- CD
      x = (math.tan(math.rad(angleSun)) * (centreY - indent)) + centreX
      love.graphics.draw(pointerSkin, x, windowHeight - indent, math.rad(-angleSun), 1, 1, 10, 10)
      
    elseif angleSun < angleD and angleSun > angleA then                                         -- DA
      y = ((indent - centreX) / math.tan(math.rad(angleSun))) + centreY
      love.graphics.draw(pointerSkin, indent, y, math.rad(-angleSun), 1, 1, 10, 10)
      
    end
    --love.graphics.line(centreX, centreY, sunX, sunY)

  end
end

function love.update(dt)
  if  not pause then
    trackPoints()
    
    changePos(obj.ship)
    changePos(obj.planet1)
    changePos(obj.planet2)
    changePos(obj.planet3)
    for i=1, #bul do
      changePos(bul[i])
    end
    if love.keyboard.isDown('d') then
    obj.ship.r = obj.ship.r + 2
      if obj.ship.r >= 362 then
        obj.ship.r = 2
      end
    end
    if love.keyboard.isDown('a') then
      obj.ship.r = obj.ship.r - 2
      if obj.ship.r <= 0 then
        obj.ship.r = 360
      end
    end
    if love.keyboard.isDown('w') then acceleration("w") end
    if love.keyboard.isDown('s') then acceleration("s") end
  end

  followTheShip()
  if love.keyboard.isDown('left') then sunX = sunX + 10 obj.sun.x = getRelX(sunX) end
  if love.keyboard.isDown('right') then sunX = sunX - 10 obj.sun.x = getRelX(sunX) end
  if love.keyboard.isDown('down') then sunY = sunY - 10 obj.sun.y = getRelY(sunY) end
  if love.keyboard.isDown('up') then sunY = sunY + 10 obj.sun.y = getRelY(sunY) end
  
  love.mousepressed()
  love.mousereleased()
  love.keyreleased()
  mouseIsDuwn()
end

function love.draw()
  love.graphics.draw(background, windowWidth/2, windowHeight/2, 0, 1, 1, backgroundWidth/2, backgroundHeight/2)
  drawPointer()
  love.graphics.circle("fill", getAbsX(obj.sun.x), getAbsY(obj.sun.y), 10)
  love.graphics.draw(obj.ship.skin, getAbsX(obj.ship.x), getAbsY(obj.ship.y), math.rad(obj.ship.r), 1, 1, 10, 10)
  love.graphics.circle("fill", getAbsX(obj.planet1.x), getAbsY(obj.planet1.y), 5)
  love.graphics.circle("fill", getAbsX(obj.planet2.x), getAbsY(obj.planet2.y), 5)
  love.graphics.circle("fill", getAbsX(obj.planet3.x), getAbsY(obj.planet3.y), 5)
  for i=1, #bul do
    love.graphics.circle("fill", getAbsX(bul[i].x), getAbsY(bul[i].y), 2)
  end
  love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
  love.graphics.print("Disttance to the Sun: " .. math.sqrt((sunX - windowWidth/2)^2 + (sunY - windowHeight/2)^2) , 10, 25)
  love.graphics.print("speed: " .. math.sqrt((obj.ship.sx)^2 + (obj.ship.sy)^2), 10, 40)
  love.graphics.print("shipData: x> ".. obj.ship.x .."y>".. obj.ship.y .."sx>".. obj.ship.sx .."sy>".. obj.ship.sy, 10, windowHeight - 20) -- настройка планет

  for k,v in pairs(points) do
  local t = 1
  local l = #v
  local c
    for k,v in pairs(v) do
      t = t + 1
      c = t/l
     
      love.graphics.setColor(c, 0.3, 0.5)
      love.graphics.points(getAbsX(v[1]),getAbsY(v[2]))
    end
  end
  love.graphics.setColor(1, 1, 1)
end
