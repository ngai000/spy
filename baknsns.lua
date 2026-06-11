

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Cấu hình (ĐÃ SỬA - Đéo còn `local getgenv()` ngu ngốc)
getgenv().KillAuraConfig = {
    Range = 50,
    HitInterval = 0.1,
    TargetPlayers = false,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 0, 0),
    FOVTransparency = 0.3,
    UseRemoteEvents = true, -- Tự động tìm Remote để gây damage thật
    DamageMultiplier = 999999 -- Sát thương khổng lồ
}

getgenv().KillAuraEnabled = false

-- ====== TẠO GUI (Đã fix lỗi click khi kéo) ======
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZoKillAuraGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Nút kéo (chỉ để di chuyển, không mở menu)
local DragButton = Instance.new("TextButton")
DragButton.Size = UDim2.new(0, 50, 0, 50)
DragButton.Position = UDim2.new(0.1, 0, 0.5, 0)
DragButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
DragButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DragButton.Text = "💀"
DragButton.Font = Enum.Font.SourceSansBold
DragButton.TextSize = 22
DragButton.BorderSizePixel = 0
DragButton.BackgroundTransparency = 0.2
DragButton.Active = true
DragButton.Draggable = true
DragButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 25)
UICorner.Parent = DragButton

-- Nút mở menu riêng biệt (đặt bên trong nút kéo nhưng nhỏ hơn)
local MenuToggle = Instance.new("TextButton")
MenuToggle.Size = UDim2.new(0, 30, 0, 30)
MenuToggle.Position = UDim2.new(0.5, -15, 0.5, -15)
MenuToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MenuToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggle.Text = "⚙"
MenuToggle.Font = Enum.Font.SourceSansBold
MenuToggle.TextSize = 16
MenuToggle.BorderSizePixel = 0
MenuToggle.BackgroundTransparency = 0.5
MenuToggle.Parent = DragButton

-- Frame menu (đã fix vị trí)
local OptionFrame = Instance.new("Frame")
OptionFrame.Size = UDim2.new(0, 200, 0, 320)
OptionFrame.Position = UDim2.new(0, 60, 0, 0)
OptionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OptionFrame.BorderSizePixel = 0
OptionFrame.BackgroundTransparency = 0.1
OptionFrame.Visible = false
OptionFrame.Parent = DragButton

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = OptionFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Text = "🔥 ZO KILL AURA V2 🔥"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = OptionFrame

-- Toggle chính
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "KILL AURA: OFF"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = OptionFrame

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 6)
UICorner3.Parent = ToggleButton

-- Range Label
local RangeLabel = Instance.new("TextLabel")
RangeLabel.Size = UDim2.new(0.5, 0, 0, 20)
RangeLabel.Position = UDim2.new(0.05, 0, 0, 90)
RangeLabel.BackgroundTransparency = 1
RangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeLabel.Text = "Range: 50"
RangeLabel.Font = Enum.Font.SourceSans
RangeLabel.TextSize = 12
RangeLabel.Parent = OptionFrame

-- Range Input
local RangeInput = Instance.new("TextBox")
RangeInput.Size = UDim2.new(0.9, 0, 0, 25)
RangeInput.Position = UDim2.new(0.05, 0, 0, 110)
RangeInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RangeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeInput.Text = "50"
RangeInput.Font = Enum.Font.SourceSans
RangeInput.TextSize = 14
RangeInput.BorderSizePixel = 0
RangeInput.Parent = OptionFrame

-- Target Players Toggle
local TargetPlayersButton = Instance.new("TextButton")
TargetPlayersButton.Size = UDim2.new(0.9, 0, 0, 35)
TargetPlayersButton.Position = UDim2.new(0.05, 0, 0, 145)
TargetPlayersButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
TargetPlayersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetPlayersButton.Text = "Target Players: OFF"
TargetPlayersButton.Font = Enum.Font.SourceSansBold
TargetPlayersButton.TextSize = 11
TargetPlayersButton.BorderSizePixel = 0
TargetPlayersButton.Parent = OptionFrame

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0, 6)
UICorner4.Parent = TargetPlayersButton

-- FOV Toggle
local FOVButton = Instance.new("TextButton")
FOVButton.Size = UDim2.new(0.9, 0, 0, 35)
FOVButton.Position = UDim2.new(0.05, 0, 0, 190)
FOVButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
FOVButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVButton.Text = "Show FOV: ON"
FOVButton.Font = Enum.Font.SourceSansBold
FOVButton.TextSize = 11
FOVButton.BorderSizePixel = 0
FOVButton.Parent = OptionFrame

local UICorner5 = Instance.new("UICorner")
UICorner5.CornerRadius = UDim.new(0, 6)
UICorner5.Parent = FOVButton

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 40)
StatusLabel.Position = UDim2.new(0, 0, 0, 240)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Text = "✅ Sẵn sàng tàn sát"
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 10
StatusLabel.Parent = OptionFrame

-- Hint
local Hint = Instance.new("TextLabel")
Hint.Size = UDim2.new(1, 0, 0, 20)
Hint.Position = UDim2.new(0, 0, 0, 290)
Hint.BackgroundTransparency = 1
Hint.TextColor3 = Color3.fromRGB(150, 150, 150)
Hint.Text = "⚙ Mở menu | 💀 Kéo thả"
Hint.Font = Enum.Font.SourceSans
Hint.TextSize = 10
Hint.Parent = OptionFrame

-- ====== LOGIC GUI ======
MenuToggle.MouseButton1Click:Connect(function()
    OptionFrame.Visible = not OptionFrame.Visible
    StatusLabel.Text = OptionFrame.Visible and "📂 Menu đang mở" or "✅ Sẵn sàng tàn sát"
end)

ToggleButton.MouseButton1Click:Connect(function()
    getgenv().KillAuraEnabled = not getgenv().KillAuraEnabled
    if getgenv().KillAuraEnabled then
        ToggleButton.Text = "KILL AURA: ON 🔥"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        StatusLabel.Text = "☠️ ĐANG QUÉT SẠCH!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    else
        ToggleButton.Text = "KILL AURA: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        StatusLabel.Text = "💤 Đã tắt"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

RangeInput.FocusLost:Connect(function()
    local num = tonumber(RangeInput.Text)
    if num and num > 0 and num <= 500 then
        getgenv().KillAuraConfig.Range = num
        RangeLabel.Text = "Range: " .. tostring(num)
        if fovCircle then
            fovCircle.Radius = num * 3
        end
    else
        RangeInput.Text = tostring(getgenv().KillAuraConfig.Range)
    end
end)

TargetPlayersButton.MouseButton1Click:Connect(function()
    getgenv().KillAuraConfig.TargetPlayers = not getgenv().KillAuraConfig.TargetPlayers
    if getgenv().KillAuraConfig.TargetPlayers then
        TargetPlayersButton.Text = "Target Players: ON ☠️"
        TargetPlayersButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    else
        TargetPlayersButton.Text = "Target Players: OFF"
        TargetPlayersButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

FOVButton.MouseButton1Click:Connect(function()
    getgenv().KillAuraConfig.ShowFOV = not getgenv().KillAuraConfig.ShowFOV
    if fovCircle then
        fovCircle.Visible = getgenv().KillAuraConfig.ShowFOV
    end
    if getgenv().KillAuraConfig.ShowFOV then
        FOVButton.Text = "Show FOV: ON"
        FOVButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    else
        FOVButton.Text = "Show FOV: OFF"
        FOVButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

-- ====== HỆ THỐNG KILL AURA THỰC SỰ ======
-- Tìm RemoteEvents/RemoteFunctions để gây damage server-side
local function findDamageRemote()
    -- Thử tìm trong ReplicatedStorage
    local remotes = {}
    local replicatedStorage = game:GetService("ReplicatedStorage")
    
    local function searchRemote(parent)
        for _, obj in pairs(parent:GetChildren()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                if name:find("damage") or name:find("hit") or name:find("attack") or name:find("kill") or name:find("hurt") then
                    table.insert(remotes, obj)
                end
            end
            if #obj:GetChildren() > 0 then
                searchRemote(obj)
            end
        end
    end
    
    searchRemote(replicatedStorage)
    return remotes
end

-- Cache remotes khi load
local cachedRemotes = {}
local function updateRemotes()
    cachedRemotes = findDamageRemote()
end
updateRemotes()

-- Hàm tấn công target (đã fix kiểm tra tồn tại)
local function attackTarget(target)
    if not target then return false end
    
    local humanoid = target:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    local root = target:FindFirstChild("HumanoidRootPart") 
        or target:FindFirstChild("Torso") 
        or target:FindFirstChild("UpperTorso")
        or target.PrimaryPart
    
    if not root then return false end
    
    local success = false
    
    -- Cách 1: Dùng RemoteEvents đã cache
    if getgenv().KillAuraConfig.UseRemoteEvents and #cachedRemotes > 0 then
        for _, remote in pairs(cachedRemotes) do
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(target, getgenv().KillAuraConfig.DamageMultiplier)
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer(target, getgenv().KillAuraConfig.DamageMultiplier)
                end
                success = true
            end)
        end
    end
    
    -- Cách 2: TakeDamage (chỉ hoạt động nếu server cho phép)
    if not success then
        pcall(function()
            humanoid:TakeDamage(getgenv().KillAuraConfig.DamageMultiplier)
            success = true
        end)
    end
    
    -- Cách 3: Set health trực tiếp (ít hiệu quả nhưng thử đéo chết ai)
    if not success then
        pcall(function()
            humanoid.Health = math.max(0, humanoid.Health - getgenv().KillAuraConfig.DamageMultiplier)
            success = true
        end)
    end
    
    -- Cách 4: Fire touch interest (kiểm tra tồn tại)
    if not success and firetouchinterest then
        pcall(function()
            local myChar = LocalPlayer.Character
            if myChar then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    firetouchinterest(myRoot, root, 0)
                    firetouchinterest(myRoot, root, 1)
                end
            end
            success = true
        end)
    end
    
    return success
end

-- Tìm target gần nhất (đã fix check null + tối ưu scan)
local function getClosestTarget()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local myPos = myRoot.Position
    local maxRange = getgenv().KillAuraConfig.Range
    local closest = nil
    local shortestDist = maxRange
    
    -- Scan NPC folder trước nếu có
    local folders = {"NPCs", "Enemies", "Monsters", "Mobs", "Zombies"}
    for _, folderName in pairs(folders) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, entity in pairs(folder:GetChildren()) do
                if entity:IsA("Model") then
                    local humanoid = entity:FindFirstChild("Humanoid")
                    local root = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("Torso") or entity.PrimaryPart
                    
                    if humanoid and humanoid.Health > 0 and root then
                        local isPlayer = Players:GetPlayerFromCharacter(entity)
                        if isPlayer and not getgenv().KillAuraConfig.TargetPlayers then continue end
                        if entity == myChar then continue end
                        
                        local dist = (root.Position - myPos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closest = entity
                        end
                    end
                end
            end
        end
    end
    
    -- Nếu không có folder đặc biệt, scan workspace nhưng giới hạn
    if not closest then
        for _, entity in pairs(workspace:GetChildren()) do
            if entity:IsA("Model") then
                local humanoid = entity:FindFirstChild("Humanoid")
                local root = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("Torso") or entity.PrimaryPart
                
                if humanoid and humanoid.Health > 0 and root then
                    local isPlayer = Players:GetPlayerFromCharacter(entity)
                    if isPlayer and not getgenv().KillAuraConfig.TargetPlayers then continue end
                    if entity == myChar then continue end
                    
                    local dist = (root.Position - myPos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = entity
                    end
                end
            end
        end
    end
    
    return closest
end

-- Vòng lặp chính (ĐÃ DÙNG HitInterval + task.wait)
task.spawn(function()
    while task.wait(getgenv().KillAuraConfig.HitInterval) do
        if getgenv().KillAuraEnabled then
            local target = getClosestTarget()
            if target then
                attackTarget(target)
            end
        end
    end
end)

-- FOV Circle (ĐÃ KIỂM TRA Drawing tồn tại)
local fovCircle
if Drawing and Drawing.new then
    pcall(function()
        fovCircle = Drawing.new("Circle")
        if fovCircle then
            fovCircle.Visible = getgenv().KillAuraConfig.ShowFOV
            fovCircle.Radius = getgenv().KillAuraConfig.Range * 3
            fovCircle.Color = getgenv().KillAuraConfig.FOVColor
            fovCircle.Transparency = getgenv().KillAuraConfig.FOVTransparency
            fovCircle.Thickness = 2
            fovCircle.Filled = false
            
            local camera = workspace.CurrentCamera
            if camera then
                fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            end
            
            RunService.RenderStepped:Connect(function()
                if fovCircle and fovCircle.Visible and camera then
                    fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                end
            end)
        end
    end)
end

-- Auto update remotes mỗi 30s
task.spawn(function()
    while task.wait(30) do
        updateRemotes()
    end
end)

