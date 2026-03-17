local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local FILE = "lock_position.json"
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

local function moveSmooth(targetCFrame, stepSize, moveType)
	if isMoving then return end
	local hrp = getHRP()
	if not hrp then return end

	isMoving = true
	if moveType == "lock" then
		returning = true
	elseif moveType == "boss" then
		moveToBossPosition = true
	end

	local targetPos = targetCFrame.Position
	local maxSteps = 1000
	local steps = 0

	while steps < maxSteps do
	
		if moveType == "lock" and (not lockEnabled or bossPresent) then
			break
		end
		if moveType == "boss" and (not bossPresent or not currentBossIsland) then
			break
		end

		local hrp = getHRP()
		if not hrp then break end

		local currentPos = hrp.Position
		local distLeft = (targetPos - currentPos).Magnitude

		if distLeft <= stepSize then
			
			hrp.CFrame = targetCFrame
			break
		else
		
			local dir = (targetPos - currentPos).Unit
			local newPos = currentPos + dir * stepSize
			
			local rot = hrp.CFrame - hrp.Position
			hrp.CFrame = CFrame.new(newPos) * rot
		end

		steps = steps + 1
		task.wait(0.1)
	end

	isMoving = false
	returning = false
	moveToBossPosition = false
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
			notify("Boss ở "..islandKey)

			task.spawn(function()
				task.wait(10)
				if bossPresent and currentBossIsland then
					checkAndMoveToBossPosition()
					while bossPresent and currentBossIsland do
						task.wait(3)
						checkAndMoveToBossPosition()
					end
				end
			end)
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

local lockGui = Instance.new("ScreenGui")
lockGui.Name = "BossCheckerGUI"
lockGui.Parent = game.CoreGui

local frame = Instance.new("Frame", lockGui)
frame.Size = UDim2.new(0, 90, 0, 55)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true

local set = Instance.new("TextButton", frame)
set.Size = UDim2.new(1, 0, 0, 25)
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

set.MouseButton1Click:Connect(function()
	local hrp = getHRP()
	if hrp then
		savedCFrame = hrp.CFrame
		savePosition(hrp.CFrame)
		notify("Đã lưu vị trí")
	end
end)

toggle.MouseButton1Click:Connect(function()
	lockEnabled = not lockEnabled
	toggle.Text = lockEnabled and "LOCK ON" or "LOCK OFF"
end)


local infoGui = Instance.new("ScreenGui")
infoGui.Name = "InfoStats"
infoGui.Parent = game.CoreGui

local infoLabel = Instance.new("TextLabel")
infoLabel.Parent = infoGui
infoLabel.Size = UDim2.new(0, 200, 0, 70)
infoLabel.Position = UDim2.new(0, 5, 0, 80)  
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

task.spawn(function()
	while true do
		if lockEnabled and savedCFrame and not bossPresent and not returning and not moveToBossPosition then
			local hrp = getHRP()
			if hrp then
				if distance(hrp.CFrame, savedCFrame) > 15 then
				
					task.spawn(returnToLock)
				end
			end
		end
		task.wait(3)
	end
end)
task.spawn(function()
	while true do
		checkBoss()
		task.wait(3)
	end
end)
