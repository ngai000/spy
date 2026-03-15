local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local FILE_NAME = "farm_position.txt"

getgenv().FarmCFrame = nil
getgenv().AutoReturn = false

-- LOAD FILE
if isfile(FILE_NAME) then
    local data = readfile(FILE_NAME)
    local nums = {}

    for n in string.gmatch(data,"[^,]+") do
        table.insert(nums,tonumber(n))
    end

    if #nums == 12 then
        getgenv().FarmCFrame = CFrame.new(unpack(nums))
    end
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0,150,0,25)
frame.Position = UDim2.new(1,-155,0,5)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0

local layout = Instance.new("UIListLayout",frame)
layout.FillDirection = Enum.FillDirection.Horizontal

local function btn(text)
    local b = Instance.new("TextButton")
    b.Parent = frame
    b.Size = UDim2.new(0,50,1,0)
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.BorderSizePixel = 0
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    b.Text = text
    return b
end

local setBtn = btn("Set")
local autoBtn = btn("Auto")
local copyBtn = btn("Copy")

-- SET FARM
setBtn.MouseButton1Click:Connect(function()

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp then
        local cf = hrp.CFrame
        getgenv().FarmCFrame = cf

        writefile(FILE_NAME,table.concat({cf:GetComponents()},","))

        setBtn.Text = "Saved"
        task.wait(1)
        setBtn.Text = "Set"
    end

end)

-- TOGGLE AUTO
autoBtn.MouseButton1Click:Connect(function()

    getgenv().AutoReturn = not getgenv().AutoReturn

    if getgenv().AutoReturn then
        autoBtn.Text = "ON"
    else
        autoBtn.Text = "OFF"
    end

end)

-- COPY
copyBtn.MouseButton1Click:Connect(function()

    if getgenv().FarmCFrame then
        local p = getgenv().FarmCFrame.Position

        setclipboard(
            "Vector3.new("..
            math.floor(p.X)..","..
            math.floor(p.Y)..","..
            math.floor(p.Z)..")"
        )

        copyBtn.Text = "Done"
        task.wait(1)
        copyBtn.Text = "Copy"
    end

end)

-- MOVE STEP 10 STUDS
task.spawn(function()

    while task.wait(0.2) do

        if getgenv().AutoReturn and getgenv().FarmCFrame then

            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then

                local target = getgenv().FarmCFrame.Position
                local dist = (hrp.Position - target).Magnitude

                if dist > 10 then

                    local dir = (target - hrp.Position).Unit
                    local newPos = hrp.Position + dir * 10

                    hrp.CFrame = CFrame.new(newPos,target)

                else

                    hrp.CFrame = getgenv().FarmCFrame

                end

            end
        end
    end
end)
