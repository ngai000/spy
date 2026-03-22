local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer

-- ==========================================================================
-- PHẦN 1: WEBHOOK ONLINE STATUS
-- ==========================================================================
local webhookURL = "https://discord.com/api/webhooks/1337863794969542736/yKfwH5gqmjxzvABxZQCyhkkKz8RAQJ9Je3ozosJlajaCug-QHBa6J0NbzpLp6Zbwo7Ir"  -- 👈 THAY LINK WEBHOOK CỦA BẠN VÀO ĐÂY
local joinTime = tick()
local lastWebhookSend = 0

-- 🧠 Format số: 1000000 -> 1.000.000
local function formatNumber(num)
    num = tonumber(num) or 0
    local str = tostring(math.floor(num))
    return str:reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "")
end

-- ⏱️ Format time
local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- 📅 Lấy thời gian hiện tại (giờ Việt Nam GMT+7)
local function getCurrentTime()
    local now = os.time()
    local vietnamTime = now + 7 * 3600  -- GMT+7
    return os.date("%H:%M:%S - %d/%m/%Y", vietnamTime)
end

-- 🎮 Lấy tên game
local function getGameName()
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    return (success and info and info.Name) or "Unknown Game"
end

-- 🔍 Tìm stat theo nhiều kiểu game
local function findStat(possibleNames)
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        for _, v in pairs(ls:GetChildren()) do
            for _, name in pairs(possibleNames) do
                if string.lower(v.Name):find(name) then
                    return v.Value
                end
            end
        end
    end

    for _, v in pairs(player:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            for _, name in pairs(possibleNames) do
                if string.lower(v.Name):find(name) then
                    return v.Value
                end
            end
        end
    end

    return 0
end

-- 💰 Lấy tiền + gem
local function getCurrency()
    local moneyNames = {"money","cash","coin","coins","beli","gold","yen"}
    local gemNames = {"gem","gems","diamond","ruby"}

    local money = findStat(moneyNames)
    local gems = findStat(gemNames)

    return formatNumber(money), formatNumber(gems)
end

-- 📤 Gửi webhook
local function sendWebhook()
    local playTime = tick() - joinTime
    local formattedTime = formatTime(playTime)
    local currentTime = getCurrentTime()
    
    local usernameHidden = "||" .. player.Name .. "||"
    local gameName = getGameName()
    local money, gems = getCurrency()
    local playerCount = #Players:GetPlayers()  -- Số lượng người trong server

    local data = {
        username = "Bot By Ngài 🎩",
        embeds = {{
            title = "🟢 Trạng thái tài khoản",
            color = 65280,
            fields = {
                {
                    name = "👤 Tài khoản",
                    value = usernameHidden,
                    inline = false
                },
                {
                    name = "🎮 Game",
                    value = gameName,
                    inline = false
                },
                {
                    name = "⏱️ Thời gian trong server",
                    value = formattedTime,
                    inline = false
                },
                {
                    name = "💰 Tiền",
                    value = money,
                    inline = true
                },
                {
                    name = "💎 Gems",
                    value = gems,
                    inline = true
                },
                {
                    name = "👥 Số người chơi",
                    value = tostring(playerCount),
                    inline = true
                },
                {
                    name = "🆔 Server",
                    value = game.JobId,
                    inline = false
                },
                {
                    name = "🤖 Boss Checker",
                    value = "Đang hoạt động",
                    inline = false
                }
            },
            footer = {
                text = "🕐 " .. currentTime  -- Thay bằng thời gian hiện tại
            }
        }}
    }

    local jsonData = HttpService:JSONEncode(data)

    pcall(function()
        request({
            Url = webhookURL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })
    end)
end
-- ==========================================================================
-- PHẦN 2: BOSS CHECKER & LOCK POSITION
-- ==========================================================================

-- Tạo tên file riêng cho từng tài khoản dựa trên UserId
local FILE = "lock_position_"..player.UserId..".json"

local Islands = {
	["Dao1"] = {
		Position = Vector3.new(270.40, 21.53, 50.72),
		LookVector = Vector3.new(1.00, 0.00, -0.04)
	},
	["Dao2"] = {
		Position = Vector3.new(1736.32, 18.04, -352.39),
		LookVector = Vector3.new(0.60, 0.00, 0.80)
	},
	["Dao3"] = {
		Position = Vector3.new(915.57, 17.63, 1242.17),
		LookVector = Vector3.new(0.64, 0.00, -0.77)
	},
	["Dao4"] = {
		Position = Vector3.new(769.92, 20.90, -988.58),
		LookVector = Vector3.new(0.29, 0.00, 0.96)
	},
	["Dao5"] = {
		Position = Vector3.new(-433.47, 22.06, 957.79),
		LookVector = Vector3.new(-0.79, 0.00, 0.61)
	}
}

local savedCFrame = nil
local lockEnabled = true
local bossPresent = false
local returning = false
local currentBossIsland = nil
local moveToBossPosition = false
local isMoving = false
local bossMoveEnabled = false  -- mặc định OFF

-- Đọc vị trí đã lưu từ file riêng của tài khoản
pcall(function()
	if readfile and isfile and isfile(FILE) then
		local data = HttpService:JSONDecode(readfile(FILE))
		savedCFrame = CFrame.new(
			data.x,data.y,data.z,
			data.r00,data.r01,data.r02,
			data.r10,data.r11,data.r12,
			data.r20,data.r21,data.r22
		)
	end
end)

local function savePosition(cf)
	local comp = {cf:GetComponents()}
	local save = {
		x=comp[1],y=comp[2],z=comp[3],
		r00=comp[4],r01=comp[5],r02=comp[6],
		r10=comp[7],r11=comp[8],r12=comp[9],
		r20=comp[10],r21=comp[11],r22=comp[12]
	}
	writefile(FILE,HttpService:JSONEncode(save))
end

local function notify(t)
	StarterGui:SetCore("SendNotification",{
		Title="Boss Checker",
		Text=t,
		Duration=3
	})
end

local function getHRP()
	if player.Character then
		return player.Character:FindFirstChild("HumanoidRootPart")
	end
end

local function distance(a,b)
	return (a.Position - b.Position).Magnitude
end

-- ===== HÀM RAYCAST ĐỂ BÁM MẶT ĐẤT =====
local function getGroundPosition(pos)
	local character = player.Character
	if not character then return nil end
	local hrp = getHRP()
	if not hrp then return nil end

	local rayOrigin = pos + Vector3.new(0, 5, 0)
	local rayDir = Vector3.new(0, -15, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {character}
	local result = Workspace:Raycast(rayOrigin, rayDir, raycastParams)
	if result then
		return result.Position
	end
	return nil
end

-- ===== PHÁT HIỆN RƠI KHỎI MAP =====
local fallDetectEnabled = true
local fallCheckDelay = 1
local isFalling = false
local fallCheckCount = 0

local function checkAndRecoverFromFall()
	if not lockEnabled or not savedCFrame then return end
	
	local hrp = getHRP()
	local character = player.Character
	if not hrp or not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	local currentPos = hrp.Position
	
	local isBelowMap = currentPos.Y < 0
	
	local groundBelow = getGroundPosition(currentPos)
	local noGroundFound = (groundBelow == nil) and (currentPos.Y > 0) and (currentPos.Y < 1000)
	
	if isBelowMap or noGroundFound then
		if not isFalling then
			isFalling = true
			fallCheckCount = 0
		end
		fallCheckCount = fallCheckCount + 1
		
		if fallCheckCount >= 2 then
			notify("⚠️ Phát hiện rơi khỏi map! Đang hồi phục...")
			task.spawn(function()
				local wasMoving = isMoving
				isMoving = false
				
				moveSmooth(savedCFrame, 10, "fall_recover")
				
				isMoving = wasMoving
				isFalling = false
				fallCheckCount = 0
				notify("✅ Đã hồi phục về vị trí an toàn")
			end)
		end
	else
		isFalling = false
		fallCheckCount = 0
	end
end

-- Di chuyển mượt với noclip & bám mặt đất
local function moveSmooth(targetCFrame, stepSize, moveType)
	if isMoving then return end
	local hrp = getHRP()
	if not hrp then return end

	isMoving = true
	if moveType == "lock" then
		returning = true
	elseif moveType == "boss" then
		moveToBossPosition = true
	elseif moveType == "fall_recover" then
		-- Không set các biến trạng thái khác
	end

	local targetPos = targetCFrame.Position
	local maxSteps = 1000
	local steps = 0
	
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local originalState = nil
	if humanoid then
		originalState = humanoid.PlatformStand
		humanoid.PlatformStand = true
	end

	while steps < maxSteps do
		if moveType == "lock" and (not lockEnabled or bossPresent) then break end
		if moveType == "boss" and (not bossPresent or not currentBossIsland) then break end
		if moveType == "fall_recover" and not lockEnabled then break end

		local hrp = getHRP()
		local character = player.Character
		if not hrp or not character then break end

		local humanoid = character:FindFirstChild("Humanoid")
		local currentPos = hrp.Position
		local distLeft = (targetPos - currentPos).Magnitude

		if distLeft <= stepSize then
			local finalPos = targetCFrame.Position
			if humanoid then
				local ground = getGroundPosition(finalPos)
				if ground then
					finalPos = Vector3.new(finalPos.X, ground.Y + humanoid.HipHeight, finalPos.Z)
				end
			end
			hrp.CFrame = CFrame.new(finalPos) * (targetCFrame - targetCFrame.Position)
			break
		else
			local dir = (targetPos - currentPos).Unit
			local newPos = currentPos + dir * stepSize

			if humanoid then
				local ground = getGroundPosition(newPos)
				if ground then
					newPos = Vector3.new(newPos.X, ground.Y + humanoid.HipHeight, newPos.Z)
				end
			end

			local rot = hrp.CFrame - hrp.Position
			hrp.CFrame = CFrame.new(newPos) * rot
		end

		steps = steps + 1
		task.wait(0.1)
	end
	
	if humanoid and originalState ~= nil then
		humanoid.PlatformStand = originalState
	end

	isMoving = false
	if moveType == "lock" then
		returning = false
	elseif moveType == "boss" then
		moveToBossPosition = false
	end
end

local function returnToLock()
	if not savedCFrame or not lockEnabled or bossPresent or isMoving then return end
	moveSmooth(savedCFrame, 10, "lock")
end

local function getIslandCFrame(islandName)
	local island = Islands[islandName]
	if island then
		return CFrame.new(island.Position, island.Position + island.LookVector)
	end
	return nil
end

local function checkAndMoveToBossPosition()
	if not bossMoveEnabled then return end
	if not bossPresent or not currentBossIsland or isMoving then return end
	local targetCFrame = getIslandCFrame(currentBossIsland)
	if not targetCFrame then return end
	local hrp = getHRP()
	if not hrp then return end

	if distance(hrp.CFrame, targetCFrame) > 5 then
		notify("Đang di chuyển đến vị trí " .. currentBossIsland)
		moveSmooth(targetCFrame, 10, "boss")
	else
		notify("Đã ở vị trí " .. currentBossIsland)
	end
end

local function checkBoss()
	local z = workspace:FindFirstChild("BossZones")
	if not z then return end

	local island = nil
	for i = 1, 7 do
		local name = "Island "..i
		if z:FindFirstChild(name) and z[name]:FindFirstChild("BossSpawnZone") then
			island = name
			break
		end
	end

	if island then
		local islandKey = "Dao"..string.match(island, "%d+")
		if not bossPresent then
			bossPresent = true
			currentBossIsland = islandKey
			if bossMoveEnabled then
				notify("Boss ở "..islandKey)
				task.spawn(function()
					task.wait(10)
					if bossPresent and currentBossIsland and bossMoveEnabled then
						checkAndMoveToBossPosition()
						while bossPresent and currentBossIsland and bossMoveEnabled do
							task.wait(7)
							checkAndMoveToBossPosition()
						end
					end
				end)
			else
				notify("Boss ở "..islandKey.." (tự động di chuyển tắt)")
			end
		end
	else
		if bossPresent then
			bossPresent = false
			currentBossIsland = nil
			moveToBossPosition = false
			notify("Boss biến mất")

			task.spawn(function()
				task.wait(15)
				if lockEnabled and savedCFrame and not bossPresent and not returning then
					returnToLock()
				end
			end)
		end
	end
end

-- ===== GUI VỚI 3 NÚT =====
local lockGui = Instance.new("ScreenGui")
lockGui.Name = "BossCheckerGUI"
lockGui.Parent = game.CoreGui

local frame = Instance.new("Frame", lockGui)
frame.Size = UDim2.new(0, 90, 0, 85)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true

local set = Instance.new("TextButton", frame)
set.Size = UDim2.new(1, 0, 0, 25)
set.Position = UDim2.new(0, 0, 0, 0)
set.Text = "SET"
set.TextScaled = true
set.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
set.TextColor3 = Color3.new(1, 1, 1)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 25)
toggle.Position = UDim2.new(0, 0, 0, 28)
toggle.Text = "LOCK ON"
toggle.TextScaled = true
toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggle.TextColor3 = Color3.new(1, 1, 1)

local bossToggle = Instance.new("TextButton", frame)
bossToggle.Size = UDim2.new(1, 0, 0, 25)
bossToggle.Position = UDim2.new(0, 0, 0, 56)
bossToggle.Text = "BOSS OFF"
bossToggle.TextScaled = true
bossToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bossToggle.TextColor3 = Color3.new(1, 1, 1)

set.MouseButton1Click:Connect(function()
	local hrp = getHRP()
	if hrp then
		savedCFrame = hrp.CFrame
		savePosition(hrp.CFrame)
		notify("Đã lưu vị trí cho tài khoản "..player.Name)
	end
end)

toggle.MouseButton1Click:Connect(function()
	lockEnabled = not lockEnabled
	toggle.Text = lockEnabled and "LOCK ON" or "LOCK OFF"
	if lockEnabled then
		notify("Lock đã BẬT")
	else
		notify("Lock đã TẮT")
	end
end)

bossToggle.MouseButton1Click:Connect(function()
	bossMoveEnabled = not bossMoveEnabled
	bossToggle.Text = bossMoveEnabled and "BOSS ON" or "BOSS OFF"
	notify("Tự động di chuyển đến boss: " .. (bossMoveEnabled and "BẬT" or "TẮT"))
end)

-- ==========================================================================
-- PHẦN 3: HIỂN THỊ PING + FPS + PLAYER COUNT
-- ==========================================================================
local infoGui = Instance.new("ScreenGui")
infoGui.Name = "InfoStats"
infoGui.Parent = game.CoreGui

local infoLabel = Instance.new("TextLabel")
infoLabel.Parent = infoGui
infoLabel.Size = UDim2.new(0, 200, 0, 70)
infoLabel.Position = UDim2.new(0, 5, 0, 100)
infoLabel.BackgroundTransparency = 0.3
infoLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
infoLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
infoLabel.TextStrokeTransparency = 0
infoLabel.Font = Enum.Font.SourceSansBold
infoLabel.TextSize = 18
infoLabel.TextXAlignment = Enum.TextXAlignment.Left

local fps = 0
local frames = 0
local last = tick()

RunService.RenderStepped:Connect(function()
	frames = frames + 1
	if tick() - last >= 1 then
		fps = frames
		frames = 0
		last = tick()
	end
end)

task.spawn(function()
	while true do
		local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		local players = #Players:GetPlayers()
		infoLabel.Text = " Ping: "..ping.." ms\n FPS: "..fps.."\n Players: "..players
		task.wait(1)
	end
end)

-- ==========================================================================
-- PHẦN 4: CÁC VÒNG LẶP CHÍNH
-- ==========================================================================

-- Vòng lặp giữ vị trí (lock)
task.spawn(function()
	while true do
		if lockEnabled and savedCFrame and not bossPresent and not returning and not moveToBossPosition then
			local hrp = getHRP()
			if hrp then
				if distance(hrp.CFrame, savedCFrame) > 100 then
					task.spawn(returnToLock)
				end
			end
		end
		task.wait(15)
	end
end)

-- Vòng lặp quét boss
task.spawn(function()
	while true do
		checkBoss()
		task.wait(15)
	end
end)

-- Vòng lặp phát hiện rơi khỏi map
task.spawn(function()
	while true do
		if lockEnabled and savedCFrame and not isMoving then
			checkAndRecoverFromFall()
		end
		task.wait(fallCheckDelay)
	end
end)

-- Vòng lặp gửi webhook (5 phút)
task.spawn(function()
	-- Gửi ngay khi script chạy
	task.wait(5)
	sendWebhook()
	
	while true do
		task.wait(300) -- 5 phút
		sendWebhook()
	end
end)
