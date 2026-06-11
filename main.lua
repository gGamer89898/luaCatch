function love.load()
    window = {
        x=love.graphics.getWidth(),
        y=love.graphics.getHeight()
    }

    Objects = {}
    Objects.score = 0
    Objects.numApples = 0
    Objects.misses = 0
    Objects.apples = {}
    Objects.player = {
        x=math.floor(window.x/2),
        y=window.y-(window.y/8),
        size={
            x=100,
            y=20
        },
        next={
            x=0,
            y=0
        },
        rate=300,
        render=function ()
            love.graphics.rectangle("fill",Objects.player.x,Objects.player.y,Objects.player.size.x,Objects.player.size.y)
        end
    }

    Objects.newApple = function (x,y,rate)
        local apple = {
            x = x,
            y = y,
            next={
                x = 0,
                y = 1
            },
            rate=rate,
            radius = 10,
            render=function ()
                love.graphics.circle("line",Objects.apples[#Objects.apples].x,Objects.apples[#Objects.apples].y,Objects.apples[#Objects.apples].radius)
            end
        }
        table.insert(Objects.apples,apple)
    end
end

function love.update(dt)
    fps = math.floor(1/dt)

    -- MOVEMENT
    --  Apples
    for oi,ov in ipairs(Objects.apples) do
        Objects.apples[oi].y = ov.y + ov.next.y * ov.rate * dt
        -- Checks
        local collision = {
            y={
                circle={
                    max=ov.y + ov.radius,
                    min = ov.y - ov.radius
                },
                rectangle={
                    min=Objects.player.y,
                    max=Objects.player.y + Objects.player.size.y
                }
            },
            x={
                circle={
                    max=ov.x + ov.radius,
                    min = ov.x - ov.radius
                },
                rectangle={
                    min=Objects.player.x,
                    max=Objects.player.x + Objects.player.size.x
                }
            },
            points= {
                {x=Objects.player.x,y=Objects.player.y},
                {x=Objects.player.x+Objects.player.size.x,y=Objects.player.y},
                {x=Objects.player.x,y=Objects.player.y+Objects.player.size.y},
                {x=Objects.player.x+Objects.player.size.x,y=Objects.player.y+Objects.player.size.y}
            }
        }
        collision.bigAssEquations={
            ((ov.x > collision.x.rectangle.min and ov.x < collision.x.rectangle.max) and (collision.y.circle.max > collision.y.rectangle.min and collision.y.circle.min < collision.y.rectangle.max)) or ((ov.y > collision.y.rectangle.min and ov.y < collision.y.rectangle.max) and (collision.x.circle.max > collision.x.rectangle.min and collision.x.circle.min < collision.x.rectangle.max)), -- checks if the circle's square hitbox touches the rectangle AND if it's inside the rectangle for both axis
            (collision.x.circle.max > collision.x.rectangle.min and collision.x.circle.min < collision.x.rectangle.max) and (collision.y.circle.max > collision.y.rectangle.min and collision.y.circle.min < collision.y.rectangle.max) -- checks if the circle's square hitbox touches the rectangle
        }
        if ov.y > window.y + ov.radius then
            Objects.score = Objects.score - 100
            Objects.misses = Objects.misses + 1
            table.remove(Objects.apples, oi)
        else
            if collision.bigAssEquations[1] then
                Collision(oi)
            elseif collision.bigAssEquations[2] then
                local temp = true
                for ci, cv in ipairs(collision.points) do
                    if math.sqrt( (cv.x - ov.x)^2 + (cv.y - ov.y)^2 ) < ov.radius then
                        Collision(oi)
                        temp = false
                        break
                    end
                end
            end
        end
    end
    if #Objects.apples == 0 then
        math.randomseed(os.time())
        Objects.newApple(math.random(0,window.x), 0, Objects.player.rate)
        Objects.numApples = Objects.numApples + 1
    end

    --  Player
    Objects.player.x = Objects.player.x + Objects.player.next.x * Objects.player.rate * dt
end

function love.draw()
    love.graphics.print("FPS: " .. fps,20,20)
    love.graphics.print("Score: " .. Objects.score,20,60)
    love.graphics.print("Accuracy: " .. (((Objects.score+100*Objects.misses)/1000)-Objects.misses*5)/((Objects.score+100*Objects.misses)/1000), 20, 90)

    -- Rendering
    for oi,ov in ipairs(Objects.apples) do
        ov.render()
    end
    love.graphics.rectangle("line",Objects.player.x,Objects.player.y,Objects.player.size.x,Objects.player.size.y) --Objects.player.render()
end

function love.keypressed(key)
    if key == "right" then
        Objects.player.next.x = 1
    end
    if key == "left" then
        Objects.player.next.x = -1
    end
    if key == "up" then
        Objects.player.rate = Objects.player.rate + 50
    end
    if key == "down" then
        Objects.player.rate = Objects.player.rate - 50
    end
end

function love.keyreleased(key)
    if (key == "right" and Objects.player.next.x == 1) or (key == "left" and Objects.player.next.x == -1) then
        Objects.player.next.x = 0
    end
end

function Collision(index,distance)
    table.remove(Objects.apples,index)
    Objects.score = Objects.score + 1000
end