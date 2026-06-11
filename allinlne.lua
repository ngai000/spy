-- ================================================
--        MOBILE UTILITY GUI - ROBLOX SCRIPT
--        Tương thích thiết bị di động & PC (Đã tối ưu)
--        KẾT HỢP AIM/ESP SIÊU MƯỢT TỪ FASTATTACK
-- ================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ================================================
--               CẤU HÌNH MẶC ĐỊNH
-- ================================================
local Config = {
    SpeedValue     = 75,
    JumpValue      = 100,
    InfiniteJump   = false,
    SpeedEnabled   = false,
    JumpEnabled    = false,
    DefaultSpeed   = 16,
    DefaultJump    = 50,
    
    -- Cấu hình Aimbot & ESP (Tinh chỉnh từ FastAttack)
    AimbotFOV      = 50,        -- Góc FOV thực tế (độ)
    MAX_DISTANCE   = 400,         -- Khoảng cách tối đa để aim
    UPDATE_PRIORITY = Enum.RenderPriority.Camera.Value + 1,  -- Độ ưu tiên render
    AimbotSmooth   = 1,           -- 1 = khóa cứng ngay lập tức
    FOVVisible     = false,
    AimbotEnabled  = false,
    TriggerbotEnabled = false,
}

-- ================================================
--              TẠO SCREENGUI CHÍNH
-- ================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileUtilityGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- ================================================
--           KHỞI TẠO VÒNG TRÒN FOV (DRAWING API)
-- ================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 50, 150)
FOVCircle.Transparency = 0.8
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Radius = Config.AimbotFOV
FOVCircle.Visible = Config.FOVVisible

-- Cập nhật vị trí vòng tròn FOV theo tâm màn hình liên tục
local UpdateFOVConnection
UpdateFOVConnection = RunService.RenderStepped:Connect(function()
    if FOVCircle then
        local viewportSize = Camera.ViewportSize
        FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    end
end)

-- ================================================
--           MINI BUTTON (NÚT MỞ PANEL)
-- ================================================
local MiniButton = Instance.new("Frame")
MiniButton.Name = "MiniButton"
MiniButton.Size = UDim2.new(0, 50, 0, 50)
MiniButton.Position = UDim2.new(0, 20, 0.4, 0)
MiniButton.BackgroundColor3 = Color3.fromRGB(20, 16, 38)
MiniButton.BorderSizePixel = 0
MiniButton.Active = true
MiniButton.Visible = true
MiniButton.ZIndex = 10
MiniButton.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 12)
MiniCorner.Parent = MiniButton

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(110, 85, 255)
MiniStroke.Thickness = 2
MiniStroke.Parent = MiniButton

local MiniLabel = Instance.new("TextLabel")
MiniLabel.Size = UDim2.new(1, 0, 1, 0)
MiniLabel.BackgroundTransparency = 1
MiniLabel.Text = "⚡"
MiniLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
MiniLabel.TextSize = 22
MiniLabel.Font = Enum.Font.GothamBold
MiniLabel.ZIndex = 11
MiniLabel.Parent = MiniButton

-- ================================================
--           MAIN PANEL (PANEL CHÍNH)
-- ================================================
local TargetSize = UDim2.new(0, 280, 0, 420)

local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = TargetSize
MainPanel.Position = UDim2.new(0.5, -140, 0.5, -210)
MainPanel.BackgroundColor3 = Color3.fromRGB(13, 11, 22)
MainPanel.BorderSizePixel = 0
MainPanel.Active = true
MainPanel.Visible = false
MainPanel.ZIndex = 10
MainPanel.Parent = ScreenGui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 14)
PanelCorner.Parent = MainPanel

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(70, 55, 130)
PanelStroke.Thickness = 1.5
PanelStroke.Parent = MainPanel

-- ================================================
--                  HEADER
-- ================================================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
Header.BorderSizePixel = 0
Header.ZIndex = 11
Header.Parent = MainPanel

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
HeaderFix.BorderSizePixel = 0
HeaderFix.ZIndex = 11
HeaderFix.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ THE GOD ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 12
TitleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 190, 220)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 13
CloseBtn.Parent = Header

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

-- ================================================
--          SCROLL FRAME NỘI DUNG
-- ================================================
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -8, 1, -50)
ScrollFrame.Position = UDim2.new(0, 4, 0, 46)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 2
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(90, 75, 165)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ZIndex = 11
ScrollFrame.Parent = MainPanel

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ScrollFrame

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 4)
ContentPadding.PaddingBottom = UDim.new(0, 10)
ContentPadding.PaddingLeft = UDim.new(0, 8)
ContentPadding.PaddingRight = UDim.new(0, 8)
ContentPadding.Parent = ScrollFrame

-- ================================================
--           HÀM TẠO CÁC COMPONENT
-- ================================================
local function CreateSection(text, order)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, 0, 0, 20)
    section.BackgroundTransparency = 1
    section.Text = text
    section.TextColor3 = Color3.fromRGB(110, 95, 160)
    section.TextSize = 11
    section.Font = Enum.Font.GothamBold
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.LayoutOrder = order
    section.ZIndex = 12
    section.Parent = ScrollFrame
    return section
end

local function CreateToggleButton(labelText, order, color)
    color = color or Color3.fromRGB(90, 70, 200)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(20, 17, 32)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.ZIndex = 12
    btn.Parent = ScrollFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(40, 35, 60)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    local btnLabel = Instance.new("TextLabel")
    btnLabel.Size = UDim2.new(1, -50, 1, 0)
    btnLabel.Position = UDim2.new(0, 10, 0, 0)
    btnLabel.BackgroundTransparency = 1
    btnLabel.Text = labelText
    btnLabel.TextColor3 = Color3.fromRGB(200, 195, 215)
    btnLabel.TextSize = 13
    btnLabel.Font = Enum.Font.Gotham
    btnLabel.TextXAlignment = Enum.TextXAlignment.Left
    btnLabel.ZIndex = 13
    btnLabel.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 30, 0, 16)
    indicator.Position = UDim2.new(1, -40, 0.5, -8)
    indicator.BackgroundColor3 = Color3.fromRGB(45, 40, 65)
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 13
    indicator.Parent = btn

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    local indDot = Instance.new("Frame")
    indDot.Size = UDim2.new(0, 12, 0, 12)
    indDot.Position = UDim2.new(0, 2, 0.5, -6)
    indDot.BackgroundColor3 = Color3.fromRGB(130, 120, 150)
    indDot.BorderSizePixel = 0
    indDot.ZIndex = 14
    indDot.Parent = indicator

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = indDot

    local toggled = false

    local function setToggle(state)
        toggled = state
        if state then
            btnStroke.Color = color
            TweenService:Create(indicator, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
            TweenService:Create(indDot, TweenInfo.new(0.15), {
                Position = UDim2.new(1, -14, 0.5, -6),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            btnStroke.Color = Color3.fromRGB(40, 35, 60)
            TweenService:Create(indicator, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 40, 65)}):Play()
            TweenService:Create(indDot, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 2, 0.5, -6),
                BackgroundColor3 = Color3.fromRGB(130, 120, 150)
            }):Play()
        end
    end

    return btn, function() return toggled end, setToggle
end

local function CreateActionButton(labelText, order, color)
    color = color or Color3.fromRGB(85, 70, 185)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = color
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.ZIndex = 12
    btn.Parent = ScrollFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    return btn
end

-- ================================================
--        SECTION: THÔNG TIN GAME (LayoutOrder: 10)
-- ================================================
CreateSection("🎮  THÔNG TIN GAME", 10)

local gameIdFrame = Instance.new("Frame")
gameIdFrame.Size = UDim2.new(1, 0, 0, 36)
gameIdFrame.BackgroundColor3 = Color3.fromRGB(18, 15, 30)
gameIdFrame.BorderSizePixel = 0
gameIdFrame.LayoutOrder = 11
gameIdFrame.ZIndex = 12
gameIdFrame.Parent = ScrollFrame

local giCorner = Instance.new("UICorner")
giCorner.CornerRadius = UDim.new(0, 8)
giCorner.Parent = gameIdFrame

local gameIdLabel = Instance.new("TextLabel")
gameIdLabel.Size = UDim2.new(1, -12, 1, 0)
gameIdLabel.Position = UDim2.new(0, 10, 0, 0)
gameIdLabel.BackgroundTransparency = 1
gameIdLabel.Text = "🆔  Game ID: " .. tostring(game.PlaceId)
gameIdLabel.TextColor3 = Color3.fromRGB(160, 190, 225)
gameIdLabel.TextSize = 12
gameIdLabel.Font = Enum.Font.Gotham
gameIdLabel.TextXAlignment = Enum.TextXAlignment.Left
gameIdLabel.ZIndex = 13
gameIdLabel.Parent = gameIdFrame

local copyBtn = CreateActionButton("📋  Sao Chép Game ID", 12, Color3.fromRGB(45, 90, 160))
copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(tostring(game.PlaceId)) end
end)

-- ================================================
--        SECTION: COMBAT & ESP (TỐI ƯU)
-- ================================================
CreateSection("💀  COMBAT & ESP (SIÊU MƯỢT)", 20)

-- NOCLIP
local noclipLoop = nil
local noclipBtn, getNoclipState, setNoclipState = CreateToggleButton("👻  Đi Xuyên Tường (Noclip)", 21, Color3.fromRGB(200, 50, 80))

local function noclipFunction()
    noclipLoop = RunService.Stepped:Connect(function()
        if not getNoclipState() then return end
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

noclipBtn.MouseButton1Click:Connect(function()
    local newState = not getNoclipState()
    setNoclipState(newState)
    if newState then noclipFunction() else
        if noclipLoop then noclipLoop:Disconnect() noclipLoop = nil end
    end
end)

-- ================================================
-- ESP SỬ DỤNG DRAWING API (SIÊU NHẸ - TỪ FASTATTACK)
-- ================================================
local ESPs = {}
local ESPEnabled = false

local function createESP(player)
    if ESPs[player] then return end
    ESPs[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Line = Drawing.new("Line"),
        HealthBar = Drawing.new("Line"),
        Distance = Drawing.new("Text")
    }
    local esp = ESPs[player]
    esp.Box.Thickness = 1.5
    esp.Box.Color = Color3.fromRGB(255, 50, 50)
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.new(0, 0, 0)
    esp.Name.Transparency = 1
    esp.Distance.Color = Color3.new(0.8, 0.8, 1)
    esp.Distance.Size = 11
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.new(0, 0, 0)
    esp.Distance.Transparency = 1
    esp.Line.Color = Color3.fromRGB(255, 255, 0)
    esp.Line.Thickness = 1
    esp.Line.Transparency = 1
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Thickness = 2
end

local function updateESP(player)
    if not ESPEnabled then return end
    if not player.Character or not player.Character:FindFirstChild("Head") or not player.Character:FindFirstChild("Humanoid") then
        if ESPs[player] then
            for _, obj in pairs(ESPs[player]) do obj.Visible = false end
        end
        return
    end
    
    local char = player.Character
    local head = char.Head
    local hum = char.Humanoid
    
    if hum.Health <= 0 then
        if ESPs[player] then
            for _, obj in pairs(ESPs[player]) do obj.Visible = false end
        end
        return
    end
    
    if not ESPs[player] then createESP(player) end
    local esp = ESPs[player]
    
    local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
    
    if onScreen then
        local distance = (head.Position - Camera.CFrame.Position).Magnitude
        local scale = 1 / distance * 100
        local boxSize = Vector2.new(35, 55) * math.clamp(scale, 0.3, 3)
        
        esp.Box.Size = boxSize
        esp.Box.Position = Vector2.new(vector.X - boxSize.X / 2, vector.Y - boxSize.Y / 2)
        esp.Box.Visible = true
        
        if distance < 30 then
            esp.Box.Color = Color3.fromRGB(255, 50, 50)
        else
            esp.Box.Color = Color3.fromRGB(255, 200, 50)
        end
        
        esp.Name.Text = player.Name
        esp.Name.Position = Vector2.new(vector.X, vector.Y - boxSize.Y / 2 - 14)
        esp.Name.Visible = true
        
        esp.Distance.Text = string.format("[%.0fm]", distance)
        esp.Distance.Position = Vector2.new(vector.X, vector.Y - boxSize.Y / 2 - 26)
        esp.Distance.Visible = true
        
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        esp.Line.From = screenCenter
        esp.Line.To = Vector2.new(vector.X, vector.Y)
        esp.Line.Visible = true
        
        local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local barHeight = boxSize.Y * hpPercent
        esp.HealthBar.From = Vector2.new(vector.X - boxSize.X / 2 - 6, vector.Y + boxSize.Y / 2)
        esp.HealthBar.To = Vector2.new(vector.X - boxSize.X / 2 - 6, vector.Y + boxSize.Y / 2 - barHeight)
        
        if hpPercent > 0.6 then
            esp.HealthBar.Color = Color3.fromRGB(50, 255, 50)
        elseif hpPercent > 0.3 then
            esp.HealthBar.Color = Color3.fromRGB(255, 255, 0)
        else
            esp.HealthBar.Color = Color3.fromRGB(255, 50, 50)
        end
        esp.HealthBar.Visible = true
    else
        esp.Box.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Line.Visible = false
        esp.HealthBar.Visible = false
    end
end

local function clearESP()
    for player, esp in pairs(ESPs) do
        for _, obj in pairs(esp) do
            obj:Remove()
        end
    end
    ESPs = {}
end

Players.PlayerRemoving:Connect(function(player)
    if ESPs[player] then
        for _, obj in pairs(ESPs[player]) do
            obj:Remove()
        end
        ESPs[player] = nil
    end
end)

local espBtn, getEspState, setEspState = CreateToggleButton("👁️  ESP (Drawing API - Siêu nhẹ)", 22, Color3.fromRGB(255, 200, 0))
espBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    setEspState(ESPEnabled)
    if not ESPEnabled then
        clearESP()
    end
end)

-- ================================================
--   NÂNG CẤP AIMBOT SIÊU MƯỢT (TỪ FASTATTACK)
-- ================================================
local AimEnabled = false
local TriggerbotEnabled = false
local currentTarget = nil

local function getAngle(direction)
    return math.acos(math.clamp(Camera.CFrame.LookVector:Dot(direction.Unit), -1, 1))
end

local function getBestTargetCFrame()
    local closest = nil
    local minDist = Config.MAX_DISTANCE
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and 
           player.Character and 
           player.Character:FindFirstChild("Head") and 
           player.Character:FindFirstChild("Humanoid") and 
           player.Character.Humanoid.Health > 0 then
            
            local head = player.Character.Head
            local toTarget = head.Position - Camera.CFrame.Position
            local dist = toTarget.Magnitude
            
            if dist < minDist then
                local angle = getAngle(toTarget)
                if math.deg(angle) <= (Config.AimbotFOV / 2) then
                    closest = player
                    minDist = dist
                end
            end
        end
    end
    
    if closest then
        return CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
    end
    return nil
end

local function fireWeapon()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        local args = {
            [1] = "MouseClick",
            [2] = true
        }
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                v:FireServer(unpack(args))
                break
            end
        end
        tool:Activate()
    end
end

local aimbotBtn, getAimbotState, setAimbotState = CreateToggleButton("🎯  Aimbot (FOV " .. Config.AimbotFOV .. "°)", 23, Color3.fromRGB(255, 50, 150))
aimbotBtn.MouseButton1Click:Connect(function()
    AimEnabled = not AimEnabled
    setAimbotState(AimEnabled)
    
    if not AimEnabled then
        if TriggerbotEnabled then
            TriggerbotEnabled = false
            setTriggerbotState(false)
        end
    end
end)

local triggerbotBtn, getTriggerbotState, setTriggerbotState = CreateToggleButton("🔥  Triggerbot (Tự Động Bắn)", 24, Color3.fromRGB(255, 80, 20))
triggerbotBtn.MouseButton1Click:Connect(function()
    if not AimEnabled then
        AimEnabled = true
        setAimbotState(true)
    end
    TriggerbotEnabled = not TriggerbotEnabled
    setTriggerbotState(TriggerbotEnabled)
end)

local fovToggleBtn, getFovVState, setFovVState = CreateToggleButton("⭕  Hiển Thị Vòng Tròn FOV", 25, Color3.fromRGB(110, 85, 255))
setFovVState(Config.FOVVisible)

fovToggleBtn.MouseButton1Click:Connect(function()
    Config.FOVVisible = not Config.FOVVisible
    setFovVState(Config.FOVVisible)
    FOVCircle.Visible = Config.FOVVisible
end)

-- ================================================
--        SECTION: DI CHUYỂN (LayoutOrder: 30)
-- ================================================
CreateSection("🏃  DI CHUYỂN", 30)

local speedBtn, getSpeedState, setSpeedState = CreateToggleButton("⚡  Speed Boost  [" .. Config.SpeedValue .. "]", 31, Color3.fromRGB(235, 140, 35))
speedBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    setSpeedState(Config.SpeedEnabled)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.SpeedEnabled and Config.SpeedValue or Config.DefaultSpeed
    end
end)

local jumpBtn, getJumpState, setJumpState = CreateToggleButton("🦘  Nhảy Cao  [" .. Config.JumpValue .. "]", 32, Color3.fromRGB(60, 180, 105))
jumpBtn.MouseButton1Click:Connect(function()
    Config.JumpEnabled = not Config.JumpEnabled
    setJumpState(Config.JumpEnabled)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = Config.JumpEnabled and Config.JumpValue or Config.DefaultJump
    end
end)

local infJumpBtn, getInfJumpState, setInfJumpState = CreateToggleButton("♾️  Nhảy Vô Hạn", 33, Color3.fromRGB(150, 70, 230))
infJumpBtn.MouseButton1Click:Connect(function()
    Config.InfiniteJump = not Config.InfiniteJump
    setInfJumpState(Config.InfiniteJump)
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ================================================
--        SECTION: CÔNG CỤ (LayoutOrder: 40)
-- ================================================
CreateSection("🔧  CÔNG CỤ", 40)

-- TÍNH NĂNG MỚI: BAY (FLY)
local flyBtn = CreateActionButton("🚀  Bay (Fly)", 41, Color3.fromRGB(195, 60, 60))
flyBtn.MouseButton1Click:Connect(function()
    pcall(function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ngai000/spy/refs/heads/main/bay.txt"))() 
    end)
end)

local dexBtn = CreateActionButton("🔍  DEX Explorer", 42, Color3.fromRGB(50, 115, 180))
dexBtn.MouseButton1Click:Connect(function()
    pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-DeX-Explorer-114771"))() end)
end)

local spyBtn = CreateActionButton("👁️  Simple Spy (Remote Spy)", 43, Color3.fromRGB(130, 50, 160))
spyBtn.MouseButton1Click:Connect(function()
    pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Simple-Spy-V3-Mobile-53593"))() end)
end)

-- ================================================
--      SECTION: CUSTOM SCRIPT (LayoutOrder: 50)
-- ================================================
CreateSection("📝  CUSTOM SCRIPT", 50)

local scriptBoxFrame = Instance.new("Frame")
scriptBoxFrame.Size = UDim2.new(1, 0, 0, 90)
scriptBoxFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
scriptBoxFrame.BorderSizePixel = 0
scriptBoxFrame.LayoutOrder = 51
scriptBoxFrame.ZIndex = 12
scriptBoxFrame.Parent = ScrollFrame

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 8)
sbCorner.Parent = scriptBoxFrame

local scriptBox = Instance.new("TextBox")
scriptBox.Size = UDim2.new(1, -12, 1, -12)
scriptBox.Position = UDim2.new(0, 6, 0, 6)
scriptBox.BackgroundTransparency = 1
scriptBox.PlaceholderText = "-- Nhập script tại đây..."
scriptBox.PlaceholderColor3 = Color3.fromRGB(70, 65, 95)
scriptBox.Text = ""
scriptBox.TextColor3 = Color3.fromRGB(180, 220, 180)
scriptBox.TextSize = 11
scriptBox.Font = Enum.Font.Code
scriptBox.MultiLine = true
scriptBox.ClearTextOnFocus = false
scriptBox.TextXAlignment = Enum.TextXAlignment.Left
scriptBox.TextYAlignment = Enum.TextYAlignment.Top
scriptBox.ZIndex = 13
scriptBox.Parent = scriptBoxFrame

local runScriptBtn = CreateActionButton("▶  Chạy Custom Script", 52, Color3.fromRGB(35, 140, 80))
runScriptBtn.MouseButton1Click:Connect(function()
    local code = scriptBox.Text
    if code == "" then return end
    local loader, err = loadstring(code)
    if loader then pcall(loader) else warn("[MobileGUI] Lỗi: " .. tostring(err)) end
end)

-- ================================================
--   TỰ ĐỘNG ÁP DỤNG SPEED/JUMP KHI RESPAWN
-- ================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = Config.SpeedEnabled and Config.SpeedValue or Config.DefaultSpeed
    hum.UseJumpPower = true
    hum.JumpPower = Config.JumpEnabled and Config.JumpValue or Config.DefaultJump
end)

-- ================================================
--   MAIN RENDER LOOP (TỐI ƯU - 1 LOOP DUY NHẤT)
-- ================================================
RunService:BindToRenderStep("AimAndESP", Config.UPDATE_PRIORITY, function()
    if AimEnabled then
        local targetCFrame = getBestTargetCFrame()
        if targetCFrame then
            Camera.CFrame = targetCFrame
            currentTarget = true
        else
            currentTarget = false
        end
    else
        currentTarget = false
    end
    
    if TriggerbotEnabled and currentTarget then
        fireWeapon()
    end
    
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                updateESP(player)
            end
        end
    end
end)

-- ================================================
--           DRAG SYSTEM (HỆ THỐNG KÉO THẢ)
-- ================================================
local function MakeDraggable(dragFrame, targetFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

MakeDraggable(Header, MainPanel)

-- ================================================
--         XỬ LÝ ĐÓNG / MỞ PANEL
-- ================================================
local miniDragging = false
local isMoving = false
local startPos, dragStart

MiniButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        isMoving = false
        dragStart = input.Position
        startPos = MiniButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 7 then isMoving = true end
        
        if isMoving then
            MiniButton.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

MiniButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = false
        if not isMoving then
            MiniButton.Visible = false
            MainPanel.Visible = true
            MainPanel.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(MainPanel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = TargetSize
            }):Play()
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(MainPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    tween:Play()
    tween.Completed:Connect(function()
        MainPanel.Visible = false
        MainPanel.Size = TargetSize
        MiniButton.Visible = true
    end)
end)

-- HIỆU ỨNG PULSE MINI BUTTON
local pulseUp = true
RunService.Heartbeat:Connect(function(dt)
    if not MiniButton.Visible then return end
    if pulseUp then
        MiniStroke.Thickness = MiniStroke.Thickness + dt * 2
        if MiniStroke.Thickness >= 3 then pulseUp = false end
    else
        MiniStroke.Thickness = MiniStroke.Thickness - dt * 2
        if MiniStroke.Thickness <= 1.5 then pulseUp = true end
    end
end)

print("[MobileGUI] ✅ Đã tích hợp thành công nút Bay (Fly) vào Công cụ!")
