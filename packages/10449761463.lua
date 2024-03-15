--[[

    Render Intents | The Strongest Battleground
    The #1 vape mod you'll ever see.

    Version: 1.8
    discord.gg/render
]]

local GuiLibrary = shared.GuiLibrary
local httpService = game:GetService('HttpService')
local teleportService = game:GetService('TeleportService')
local playersService = game:GetService('Players')
local players = game:GetService("Players")
local textService = game:GetService('TextService')
local lightingService = game:GetService('Lighting') 
local collectionService = game:GetService('CollectionService')
local textChatService = game:GetService('TextChatService')
local inputService = game:GetService('UserInputService')
local runService = game:GetService('RunService')
local replicatedStorageService = game:GetService('ReplicatedStorage')
local HWID = game:GetService('RbxAnalyticsService'):GetClientId()		
local executor = (identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or 'Unknown')
local tweenService = game:GetService('TweenService')
local player = playersService.LocalPlayer
local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local plr = playersService.LocalPlayer
local vapeConnections = {}
local vapeCachedAssets = {}
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new('BindableEvent')
		return self[index]
	end
})
local vapeTargetInfo = shared.VapeTargetInfo
local vapeInjected = true
local vec3 = Vector3.new
local vec2 = Vector2.new

local AutoLeave = {}
local isAlive = function() return false end 
local playSound = function() end
local dumptable = function() return {} end
local sendmessage = function() end
local getEnemyBed = function() end 
local canRespawn = function() end
local characterDescendant = function() return nil end
local playerRaycasted = function() return true end
local tweenInProgress = function() end
local GetTarget = function() return {} end
local GetClosetPlayer = function() end
local playAnimation = function() end
local gethighestblock = function() return nil end
local GetAllTargets = function() return {} end
local sendprivatemessage = function() end
local getnewserver = function() return nil end
local switchserver = function() end
local getTablePosition = function() return 1 end
local warningNotification = function() end 
local GetEnumItems = function() return {} end
local getrandomvalue = function() return '' end
local getTweenSpeed = function() return 0.49 end
local isEnabled = function() return false end
local InfoNotification = function() end

table.insert(vapeConnections, workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
	gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
end))

local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local networkownerswitch = tick()
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, 'NetworkOwnershipRule') end)
	if suc and res == Enum.NetworkOwnership.Manual then 
		sethiddenproperty(part, 'NetworkOwnershipRule', Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end

local getcustomasset = getsynasset or getcustomasset or function(location) return 'rbxasset://'..location end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local synapsev3 = syn and syn.toast_notification and 'V3' or ''
local worldtoscreenpoint = function(pos)
	if synapsev3 == 'V3' then 
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return gameCamera.WorldToScreenPoint(gameCamera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == 'V3' then 
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return gameCamera.WorldToViewportPoint(gameCamera, pos)
end

local function vapeGithubRequest(scripturl)
	if not isfile('vape/'..scripturl) then
		local suc, res = pcall(function() return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/'..readfile('vape/commithash.txt')..'/'..scripturl, true) end)
		assert(suc, res)
		assert(res ~= '404: Not Found', res)
		if scripturl:find('.lua') then res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n'..res end
		writefile('vape/'..scripturl, res)
	end
	return readfile('vape/'..scripturl)
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new('TextLabel')
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = 'Downloading '..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = GuiLibrary.MainGui
			repeat task.wait() until isfile(path)
			textlabel:Destroy()
		end)
		local suc, req = pcall(function() return vapeGithubRequest(path:gsub('vape/assets', 'assets')) end)
        if suc and req then
		    writefile(path, req)
        else
            return ''
        end
	end
	if not vapeCachedAssets[path] then vapeCachedAssets[path] = getcustomasset(path) end
	return vapeCachedAssets[path] 
end

warningNotification = function(title, text, delay)
	local suc, res = pcall(function()
		local color = GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api
		local frame = GuiLibrary.CreateNotification(title, text, delay, 'assets/WarningNotification.png')
		frame.Frame.Frame.ImageColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
		frame.Frame.Frame.ImageColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
		return frame
	end)
	return (suc and res)
end

playSound = function(id, volume) 
	local sound = Instance.new("Sound")
	sound.Parent = workspace
	sound.SoundId = id
	sound.PlayOnRemove = true 
	if volume then 
		sound.Volume = volume or 50
	end
	sound:Destroy()
end

playAnimation = function(id)
	local animation = Instance.new("Animation")
	animation.AnimationId = id
	local animatior = lplr.Character.Humanoid.Animator
	animatior:LoadAnimation(animation):Play()
end

InfoNotification = function(title, text, delay)
	local success, frame = pcall(function()
		return GuiLibrary.CreateNotification(title, text, delay)
	end)
	return success and frame
end

errorNotification = function(title, text, delay)
	local success, frame = pcall(function()
		local notification = GuiLibrary.CreateNotification(title, text, delay or 6.5, 'assets/WarningNotification.png')
		notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
		notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
	end)
	return success and frame
end

getrandomvalue = function(tab)
	return #tab > 0 and tab[math.random(1, #tab)] or ''
end

GetEnumItems = function(enum)
	local fonts = {}
	for i,v in next, Enum[enum]:GetEnumItems() do 
		table.insert(fonts, v.Name) 
	end
	return fonts
end

local function runFunction(func) func() end
local function runLunar(func) func() end

local function isFriend(plr, recolor)
	if GuiLibrary.ObjectsThatCanBeSaved['Use FriendsToggle'].Api.Enabled then
		local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectList, plr.Name)
		friend = friend and GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectListEnabled[friend]
		if recolor then
			friend = friend and GuiLibrary.ObjectsThatCanBeSaved['Recolor visualsToggle'].Api.Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectList, plr.Name)
	friend = friend and GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectListEnabled[friend]
	return friend
end

local function isVulnerable(plr)
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, 'ForceField')
end

local function getPlayerColor(plr)
	if isFriend(plr, true) then
		return Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Value)
	end
	return tostring(plr.TeamColor) ~= 'White' and plr.TeamColor.Color
end

local function LaunchAngle(v, g, d, h, higherArc)
	local v2 = v * v
	local v4 = v2 * v2
	local root = -math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	return math.atan((v2 + root) / (g * d))
end

local function LaunchDirection(start, target, v, g)
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local a = LaunchAngle(v, g, d, h)

	if a ~= a then 
		return g == 0 and (target - start).Unit * v
	end

	local vec = horizontal.Unit * v
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	return CFrame.fromAxisAngle(rotAxis, a) * vec
end

local entityLibrary = shared.vapeentity
local entityLibrary = entityLibrary
local WhitelistFunctions = shared.vapewhitelist
local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(function(...) pcall(func, unpack({...})) end)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(function(...) pcall(func, unpack({...})) end)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(function(...) pcall(func, unpack({...})) end)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	vapeInjected = false
	for i, v in next, (vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
	getgenv().vapeEvents = nil
end)

local function attackValue(vec)
	return {value = vec}
end

local Reach = {}
local cachedNormalSides = {}
for i,v in next, (Enum.NormalId:GetEnumItems()) do if v.Name ~= 'Bottom' then table.insert(cachedNormalSides, v) end end
local updateitem = Instance.new('BindableEvent')
local inputobj = nil
local tempconnection
tempconnection = inputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		inputobj = input
		tempconnection:Disconnect()
	end
end)
table.insert(vapeConnections, updateitem.Event:Connect(function(inputObj)
	if inputService:IsMouseButtonPressed(0) then
		game:GetService('ContextActionService'):CallFunction('block-break', Enum.UserInputState.Begin, inputobj)
	end
end))

local function EntityNearPosition(distance, ignore, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in next, (entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
				if overridepos and mag > distance then
					mag = (overridepos - v.RootPart.Position).magnitude
				end
                if mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, mag
                end
            end
        end
		if not ignore then
			return
		end
	end
	return closestEntity
end

local function EntityNearMouse(distance)
	local closestEntity, closestMagnitude = nil, distance
    if entityLibrary.isAlive then
		local mousepos = inputService.GetMouseLocation(inputService)
		for i, v in next, (entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v.RootPart.Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
                if vis and mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, v.Target and -1 or mag
                end
            end
        end
    end
	return closestEntity
end

local ToolCheck
local function ActivateAbility(name)
	if not lplr.Backpack:FindFirstChild(name) then
		ToolCheck = false
		lplr.Character:WaitForChild(name).Parent = backpack
		return
	else
		ToolCheck = true
		backpack:WaitForChild(name).Parent = lplr.Character
		backpack:WaitForChild(name):Activate()	
		lplr.Character:WaitForChild(name).Parent = backpack
		ToolCheck = false
	end
end

do
	entityLibrary.animationCache = {}
	entityLibrary.groundTick = tick()
	entityLibrary.selfDestruct()
	entityLibrary.characterAdded = function(plr, char, localcheck)
		local id = game:GetService('HttpService'):GenerateGUID(true)
		entityLibrary.entityIds[plr.Name] = id
        if char then
            task.spawn(function()
                local humrootpart = char:WaitForChild('HumanoidRootPart', 10)
                local head = char:WaitForChild('Head', 10)
                local hum = char:WaitForChild('Humanoid', 10)
				if entityLibrary.entityIds[plr.Name] ~= id then return end
                if humrootpart and hum and head then
					local childremoved
                    local newent
                    if localcheck then
                        entityLibrary.isAlive = true
                        entityLibrary.character.Head = head
                        entityLibrary.character.Humanoid = hum
                        entityLibrary.character.HumanoidRootPart = humrootpart
						table.insert(entityLibrary.entityConnections, char.AttributeChanged:Connect(function(...)
							vapeEvents.AttributeChanged:Fire(...)
						end))
                    else
						newent = {
                            Player = plr,
                            Character = char,
                            HumanoidRootPart = humrootpart,
                            RootPart = humrootpart,
                            Head = head,
                            Humanoid = hum,
                            Targetable = entityLibrary.isPlayerTargetable(plr),
                            Team = plr.Team,
                            Connections = {},
							Jumping = false,
							Jumps = 0,
							JumpTick = tick()
                        }
						if entityLibrary.entityIds[plr.Name] ~= id then return end
						task.delay(0.3, function() 
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							entityLibrary.entityUpdatedEvent:Fire(newent)
						end)
						table.insert(newent.Connections, hum:GetPropertyChangedSignal('Health'):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum:GetPropertyChangedSignal('MaxHealth'):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum.AnimationPlayed:Connect(function(state) 
							local animnum = tonumber(({state.Animation.AnimationId:gsub('%D+', '')})[1])
							if animnum then
								if not entityLibrary.animationCache[state.Animation.AnimationId] then 
									entityLibrary.animationCache[state.Animation.AnimationId] = game:GetService('MarketplaceService'):GetProductInfo(animnum)
								end
								if entityLibrary.animationCache[state.Animation.AnimationId].Name:lower():find('jump') then
									newent.Jumps = newent.Jumps + 1
								end
							end
						end))
						table.insert(newent.Connections, char.AttributeChanged:Connect(function(attr) if attr:find('Shield') then entityLibrary.entityUpdatedEvent:Fire(newent) end end))
						table.insert(entityLibrary.entityList, newent)
						entityLibrary.entityAddedEvent:Fire(newent)
                    end
					if entityLibrary.entityIds[plr.Name] ~= id then return end
					childremoved = char.ChildRemoved:Connect(function(part)
						if part.Name == 'HumanoidRootPart' or part.Name == 'Head' or part.Name == 'Humanoid' then			
							if localcheck then
								if char == lplr.Character then
									if part.Name == 'HumanoidRootPart' then
										entityLibrary.isAlive = false
										local root = char:FindFirstChild('HumanoidRootPart')
										if not root then 
											root = char:WaitForChild('HumanoidRootPart', 3)
										end
										if root then 
											entityLibrary.character.HumanoidRootPart = root
											entityLibrary.isAlive = true
										end
									else
										entityLibrary.isAlive = false
									end
								end
							else
								childremoved:Disconnect()
								entityLibrary.removeEntity(plr)
							end
						end
					end)
					if newent then 
						table.insert(newent.Connections, childremoved)
					end
					table.insert(entityLibrary.entityConnections, childremoved)
                end
            end)
        end
    end
	entityLibrary.entityAdded = function(plr, localcheck, custom)
		table.insert(entityLibrary.entityConnections, plr:GetPropertyChangedSignal('Character'):Connect(function()
            if plr.Character then
                entityLibrary.refreshEntity(plr, localcheck)
            else
                if localcheck then
                    entityLibrary.isAlive = false
                else
                    entityLibrary.removeEntity(plr)
                end
            end
        end))
        table.insert(entityLibrary.entityConnections, plr:GetAttributeChangedSignal('Team'):Connect(function()
			local tab = {}
			for i,v in next, entityLibrary.entityList do
                if v.Targetable ~= entityLibrary.isPlayerTargetable(v.Player) then 
                    table.insert(tab, v)
                end
            end
			for i,v in next, tab do 
				entityLibrary.refreshEntity(v.Player)
			end
            if localcheck then
                entityLibrary.fullEntityRefresh()
            else
				entityLibrary.refreshEntity(plr, localcheck)
            end
        end))
		if plr.Character then
            task.spawn(entityLibrary.refreshEntity, plr, localcheck)
        end
    end
	entityLibrary.fullEntityRefresh()
	task.spawn(function()
		repeat
			task.wait()
			if entityLibrary.isAlive then
				entityLibrary.groundTick = entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entityLibrary.groundTick
			end
			for i,v in next, (entityLibrary.entityList) do 
				local state = v.Humanoid:GetState()
				v.JumpTick = (state ~= Enum.HumanoidStateType.Running and state ~= Enum.HumanoidStateType.Landed) and tick() or v.JumpTick
				v.Jumping = (tick() - v.JumpTick) < 0.2 and v.Jumps > 1
				if (tick() - v.JumpTick) > 0.2 then 
					v.Jumps = 0
				end
			end
		until not vapeInjected
	end)
end


warn('Wait Until Fully Loaded')
local players = game:GetService("Players")
local plr = players.LocalPlayer
local cd = false
local Settings = {
	Autoparry = {
		Toggle = true, Range = 25, Delay = 0,Fov = 140, Facing = true, Dodgerange = 3, Aimhelper = false,
	}
}

local function isRagdolled(plr)
    local character = plr.Character
	if character:FindFirstChild("Ragdoll") then
		print()
	end
end

local m1s = {
--YZFloppa
	["rbxassetid://10469493270"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://10469630950"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://10469639222"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://10469643643"] = { [1] = 0, [2] = 0.30 },
--YZFloppa's minion
	["rbxassetid://13532562418"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://13532600125"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://13532604085"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://13294471966"] = { [1] = 0, [2] = 0.30 },
--mcdonald's frying machine
	["rbxassetid://13491635433"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://13296577783"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://13295919399"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://13295936866"] = { [1] = 0, [2] = 0.30 },
--mcdonald's fastest work
	["rbxassetid://13370310513"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://13390230973"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://13378751717"] = { [1] = 0, [2] = 0.30 },
	["rbxassetid://13378708199"] = { [1] = 0, [2] = 0.30 },
--nigga got brain issue
	['rbxassetid://14004222985'] = { [1] = 0, [2] = 0.40 },
	['rbxassetid://13997092940'] = { [1] = 0, [2] = 0.40 },
	['rbxassetid://14001963401'] = { [1] = 0, [2] = 0.40 },
	['rbxassetid://14136436157'] = { [1] = 0, [2] = 0.45 },
--bro think he's good at cutting shit
	['rbxassetid://15259161390'] = { [1] = 0, [2] = 0.30 }, 
	['rbxassetid://15240216931'] = { [1] = 0, [2] = 0.30 },
	['rbxassetid://15240176873'] = { [1] = 0, [2] = 0.30 },
	['rbxassetid://15162694192'] = { [1] = 0, [2] = 0.30 },
--omg a child with telekinesis
	['rbxassetid://16515503507'] = { [1] = 0, [2] = 0.30 },
	['rbxassetid://16515520431'] = { [1] = 0, [2] = 0.30 },
	['rbxassetid://16515448089'] = { [1] = 0, [2] = 0.30 },
	['rbxassetid://16552234590'] = { [1] = 0, [2] = 0.30 },
	abilities = {}
}
local dashes = {
	["rbxassetid://10479335397"] = { [1] = 0, [2] = 0.50 },
	["rbxassetid://13380255751"] = { [1] = 0, [2] = 0.50 },
	['rbxassetid://13380255751'] = { [1] = 0, [2] = 0.50 },
	['rbxassetid://13380255751'] = { [1] = 0, [2] = 0.50 },
	
}
local barrages = {
	["rbxassetid://10466974800"] = { [1] = 0.20, [2] = 1.80 },
	["rbxassetid://12534735382"] = { [1] = 0.20, [2] = 1.80 }
}
local abilities = {
	["rbxassetid://10468665991"] = { [1] = 0.15, [2] = 0.60 },
	["rbxassetid://13376869471"] = { [1] = 0.05, [2] = 1 },
	["rbxassetid://13376962659"] = { [1] = 0, [2] = 2 },
	["rbxassetid://12296882427"] = { [1] = 0.05, [2] = 1 },--sonic
	["rbxassetid://13309500827"] = { [1] = 0.05, [2] = 1 },--sonic
	["rbxassetid://13365849295"] = { [1] = 0, [2] = 1 },--sonic
	["rbxassetid://13377153603"] = { [1] = 0, [2] = 1 },--sonik
	["rbxassetid://12509505723"] = { [1] = 0.09, [2] = 2 }, -- dash for gemoss
}

local closestplr, m1, plrDirection, unit, value,dash
local plr = game.Players.LocalPlayer

function lookatlol(player)
	if not player or not player:IsA("Player") or not player.Character then
		return false
	end
	local plrChar = player.Character
	if not plrChar or not plrChar:FindFirstChild("Head") or plrChar.Humanoid.Health == 0 then
		return false
	end
	local lplrChar = plr.Character
	if not lplrChar or not lplrChar:FindFirstChild("Head") or lplrChar.Humanoid.Health == 0 then
		return false
	end
	local charDirection = (plrChar.Head.Position - lplrChar.Head.Position).unit
	local charLook = lplrChar.Head.CFrame.LookVector
	local dp = charDirection:Dot(charLook)
	return dp > 0.5
end
function closest()
	local closestplr = {}
	for _, v in next, players:GetPlayers() do
		if v:IsA("Player") and v ~= plr and v.Character and plr.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
			local distance = (v.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
			if distance < Settings.Autoparry.Range then
				local isLooking = lookatlol(v)
				if isLooking then
					table.insert(closestplr, v)
				end
			end
		end
	end
	return closestplr
end

function attackchecker()
	for i,Anim in next, plr.Character.Humanoid.Animator:GetPlayingAnimationTracks() do
		z = m1s[Anim.Animation.AnimationId]
		q = dashes[Anim.Animation.AnimationId]
		j = abilities[Anim.Animation.AnimationId]
		k = barrages[Anim.Animation.AnimationId]
		if z or q or j or k then return true
		else return false
		end
	end
end

function isfacing(object)
	if Settings.Autoparry.Toggle then
		if Settings.Autoparry.Facing then
			plrDirection = plr.Character.Head.CFrame.LookVector
			unit = (object.Head.CFrame.p - plr.Character.Head.CFrame.p).Unit
			value = math.pow((plrDirection - unit).Magnitude / 2, 2)
			if value >= Settings.Autoparry.Fov / 360 then
				return false
			else
				return true
			end
		else
			return true
		end
	end
end

function allowed(enemy)
	if not plr.Character:FindFirstChild("M1ing") and not attackchecker() and isfacing(enemy) then
		return true
	end
end

local durations = {
	["m1"] = 0.3,
	["dash"] = 0.3,
	["barrage"] = 0.9,
	["ability"] = 0.6,
}

function def(action)
	if cd then
		return
	end
	task.wait(Settings.Autoparry.Delay)
	print("parry attempt".."|"..action)
	cd = true
	plr.Character.Communicate:FireServer({["Goal"] = "KeyPress", ["Key"] = Enum.KeyCode.F })
	task.wait(durations[action])
	plr.Character.Communicate:FireServer({["Goal"] = "KeyRelease",["Key"] = Enum.KeyCode.F })
	cd = false
end

function barragechecker(enemy)
	if enemy:FindFirstChild("BarrageBind") then
		return true
	else
		return false
	end
end

function lookat(enemy)
	if Settings.Autoparry.Aimhelper then
		plr.Character.HumanoidRootPart.CFrame = CFrame.lookAt(plr.Character.HumanoidRootPart.Position, enemy.HumanoidRootPart.Position)
	end
end

local GarouPrey = {Enabled = false}
function parry()
	for i, c in closest() do
		if c and plr.Character:WaitForChild("HumanoidRootPart", 2) and c.Character and c.Character:FindFirstChild("Humanoid") and c.Character.Humanoid:FindFirstChild("Animator") then
			for i, v in next, c.Character.Humanoid.Animator:GetPlayingAnimationTracks() do
				m1 = m1s[v.Animation.AnimationId]
				dash = dashes[v.Animation.AnimationId]
				ability = abilities[v.Animation.AnimationId]
				barrage = barrages[v.Animation.AnimationId]
				if allowed(c.Character) and m1 and v.TimePosition >= m1[1] and v.TimePosition <= m1[2] then
					task.spawn(function()
						lookat(c.Character)
						def("m1")
						if GarouPrey.Enabled then
							ActivateAbility("Prey's Peril")
						end
						
					end)
				elseif allowed(c.Character) and dash and v.TimePosition > dash[1] and v.TimePosition < dash[2] then
					task.spawn(function()
						lookat(c.Character)
						def("dash")
						if GarouPrey.Enabled then
							ActivateAbility("Prey's Peril")
						end
					end)
				elseif allowed(c.Character) and barrage and v.TimePosition > barrage[1] and v.TimePosition < barrage[2] then
					task.spawn(function()
						lookat(c.Character)
						def("barrage")
						if GarouPrey.Enabled then
							ActivateAbility("Prey's Peril")
						end
						
					end)
				elseif allowed(c.Character) and ability and v.TimePosition > ability[1] and v.TimePosition < ability[2] then
					task.spawn(function()
						lookat(c.Character)
						def("ability")
						if GarouPrey.Enabled then
							ActivateAbility("Prey's Peril")
						end
					end)
				end
			end
		end
	end
end

GuiLibrary.RemoveObject('SilentAimOptionsButton')
GuiLibrary.RemoveObject('ReachOptionsButton')
GuiLibrary.RemoveObject('MouseTPOptionsButton')
GuiLibrary.RemoveObject('PhaseOptionsButton')
GuiLibrary.RemoveObject('SpiderOptionsButton')
GuiLibrary.RemoveObject('HitBoxesOptionsButton')
GuiLibrary.RemoveObject('AntiBlackOptionsButton')
GuiLibrary.RemoveObject('KillauraOptionsButton')
GuiLibrary.RemoveObject('TriggerBotOptionsButton')
GuiLibrary.RemoveObject('ClientKickDisablerOptionsButton')
GuiLibrary.RemoveObject('FOVChangerOptionsButton')
GuiLibrary.RemoveObject('SongBeatsOptionsButton')

local AnimationController = {
	["Saitama"] = {
		["Normal Punch"] = "rbxassetid://10468665991",
		["DoublePunches"] = "rbxassetid://10466974800",
		["Shove"] = "rbxassetid://10471336737",
		["Uppercut"] = "rbxassetid://112510170988",
		["Ultimate"] = {
			["Deathcounter"] = "rbxassetid://1",
			["TableFlip"] = "rbxassetid://1",
			["SeriousPunch"] = "rbxassetid://1",
			["DirectionalPunch"] = "rbxassetid://1",
		},
	},
	["Garou"] = {
		["Flowing Water"] = "rbxassetid://12272894215",
		["Lethal Whirlwind Stream"] = "rbxassetid://12296882427",
		["Hunter's Gasp"] = "rbxassetid://12307656616",
		["Prey's Peril"] = "rbxassetid://12351854556",
		["Ultimate"] = {
			["RockSmashing"] = "rbxassetid://1",
			["FinalHunt"] = "rbxassetid://1",
			["RockFist"] = "rbxassetid://1",
			["CrushedRock"] = "rbxassetid://1",
		},
	},
	["Genos"] = {
		["MachineGunBlowing"] = "rbxassetid://12534735382",
		["Burst"] = {
			["Coming"] = "rbxassetid://12502664044",
			["BurstFire"] = "rbxassetid://12509505723",
		},
		["BlitzShot"] = {
			["Idle"] = "rbxassetid://12618271998",
			["Shot"] = "rbxassetid://12618292188",
		},
		["JetDive"] = {
			["Air"] = "rbxassetid://12684390285",
			["Down"] = "rbxassetid://12684185971",
		},
		["Ultimate"] = {
			["ThunderKick"] = "rbxassetid://1",
			["Dropkick"] = "rbxassetid://1",
			["FlameCannon"] = "rbxassetid://1",
			["Incinerate"] = "rbxassetid://1",
		},
	},
	["Sonic"] = {
		["FlashStrike"] = "rbxassetid://13376869471",
		["Kick"] = {
			["Teleport"] = "rbxassetid://13377153603",
			["Slam"] = "rbxassetid://13294790250",
		},
		["Scatter"] = {
			["Start"] = "rbxassetid://13376962659",
			["End"] = "rbxassetid://13365849295",
		},
		["Shuriken"] = "rbxassetid://13501296372",
		["Ultimate"] = {
			["Rush"] = "rbxassetid://1",
			["Straight"] = "rbxassetid://1",
			["Carnage"] = "rbxassetid://1",
			["FlashStrike"] = "rbxassetid://1",
		},
	},
	["MetalBat"] = {
		["Homerun"] = {
			["Start"] = "rbxassetid://14004235777",
			["End"] = "rbxassetid://14003607057",
		},
		["Beatdown"] = {
			["Start"] = "rbxassetid://14046756619",
			["End"] = "rbxassetid://14048349132",
		},
		["GrandSlam"] = {
			["Start"] = "rbxassetid://14299135500",
			["End"] = "rbxassetid://14967219354",
		},
		["FourBall"] = "rbxassetid://14351441234",
		["Ultimate"] = {
			["Tornado"] = "rbxassetid://1",
			["Beatdown"] = "rbxassetid://1",
			["StrengthDiff"] = "rbxassetid://1",
			["DeathBlow"] = "rbxassetid://1",
		},
	},
	["AtomicSamurai"] = {
		["QuickSlice"] = "rbxassetid://15290930205",
		["Cleave"] = "rbxassetid://15145462680",
		["Pinpoint"] = "rbxassetid://15295895753",
		["Counter"] = "rbxassetid://15311685628",
		["Ultimate"] = {
			["Sunset"] = "rbxassetid://1",
			["Cleave"] = "rbxassetid://1",
			["Sunrise"] = "rbxassetid://1",
			["Slash"] = "rbxassetid://1",
		},
	},
}

local function M1Attack()
	lplr.Character.Communicate:FireServer({
		["Goal"] = "LeftClick",
		["Mobile"] = true
	})	
end

local function Teleport(part)
	if ToolCheck then return end
	lplr.Character.HumanoidRootPart.CFrame = CFrame.new(part)
end

local Killaura = {}
local Check
local AutoLook = {Enabled = false}
local AutoSkill = {}
local AutoSonic = {}
local StopTpAway = {Enabled = true}
local KillauraRange = {Value = 25}

local function Attack()
	local nearest = nil
	local cooldistance = KillauraRange.Value + 10
	for _, player in pairs(playersService:GetPlayers()) do
		if player ~= lplr then
			local character = player.Character
			if character and character:IsA("Model") then
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if rootPart and humanoid and humanoid.Health > 0 then
					local distance = (rootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude
					if distance < cooldistance then
						cooldistance = distance
						nearest = player
					end
				end
			end
		end
	end
	if nearest then
		local character = nearest.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		local oldPosition = lplr.Character.HumanoidRootPart.Position
		
		if rootPart then
			task.spawn(function()
				task.wait(0.11)
				Check = true
				task.wait(0.2)
				Check = false
			end)
			task.spawn(function()
				repeat 
					task.wait()
					if character:FindFirstChild("Ragdoll") then
						lplr.Character.HumanoidRootPart.CFrame = CFrame.new(rootPart.Position + Vector3.new(2,10,1))
					else
						lplr.Character.HumanoidRootPart.CFrame = CFrame.new(rootPart.Position + Vector3.new(1,-2,1))
						M1Attack()
						oldPosition = lplr.Character.HumanoidRootPart.Position -- this code line will make a new oldposition (i make this message so my brain doesnt get hurt when i coded it again)
					end
				until (not Killaura.Enabled)
			end)
			repeat task.wait()
				task.spawn(function()
					if AutoSkill.Enabled then
						if character:FindFirstChild("Ragdoll") or character:FindFirstChild("BeingLaunched") or character:FindFirstChild("Freeze") then
							return nil
						else
							ActivateAbility("Flowing Water")
							task.wait(0.1)
							ActivateAbility("Hunter's Grasp")
							task.wait(0.1)
							ActivateAbility("Lethal Whirlwind Stream")
						end
					elseif AutoSonic.Enabled then
						if character:FindFirstChild("Ragdoll") then
							print("Player Ragdolled")
						else
							M1Attack()
							ActivateAbility("Scatter")
							task.wait(0.1)
							M1Attack()
							ActivateAbility("Whirlwind Kick")
							task.wait(0.1)
							M1Attack()
							ActivateAbility("Flash Strike")
							task.wait(0.1)
							M1Attack()
							ActivateAbility("Explosive Shuriken")
						end
					end
				end)
			until (not Check or not Killaura.Enabled)
			lplr.Character.HumanoidRootPart.CFrame = CFrame.new(oldPosition)
			lplr.Character.Communicate:FireServer({
				["Goal"] = "LeftClickRelease",
				["Mobile"] = true
			})
		end
	end
end
Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
	Name = 'Killaura', 
	Function = function(callback)
		if callback then
			task.spawn(function()
				repeat task.wait()
					Attack()
				until (not Killaura.Enabled)
			end)
		else
			Check = false
		end
	end
})
KillauraRange = Killaura.CreateSlider({
	Name = 'Range', 
	Min = 1,
	Max = 60, 
	Function = function(val) end,
	Default = 35
})

StopTpAway = Killaura.CreateToggle({
	Name = 'Stop Teleport Away',
	Default = true,
	Function = function(callback) 
		if callback then
			task.spawn(function()
				repeat
					task.wait(0) -- task.wait(0) very cool haahhaha
					Check = true
				until (not StopTpAway.Enabled)
			end)
		end
	end
})

AutoSkill = Killaura.CreateToggle({
	Name = 'AutoGarou',
	Default = true,
	Function = function() end,
	HoverText = 'Auto Activate Ability'
})

AutoSonic = Killaura.CreateToggle({
	Name = 'AutoSonic',
	Default = false,
	Function = function() end,
	HoverText = 'Auto Activate Ability'
})

AutoLook = Killaura.CreateToggle({
	Name = 'AutoLook',
	HoverText = 'Skidded from vezt owner ty :3',
	Function = function(calling) 
		if calling then
			task.spawn(function()
				repeat 
					task.wait()
					local targetPlayer = nil
					local maxDistance = KillauraRange.Value + 10
					local player = game.Players.LocalPlayer
					local char = player.Character or player.CharacterAdded:Wait()
					local hum = char:WaitForChild("Humanoid")
					local root = char:WaitForChild("HumanoidRootPart")
					
					local function updateTarget()
						local nearestPlayer = nil
						local nearestDistance = math.huge
						
						for _, otherPlayer in pairs(game.Players:GetPlayers()) do
							if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
								local distance = (otherPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
								if distance <= maxDistance and distance < nearestDistance then
									nearestPlayer = otherPlayer
									nearestDistance = distance
								end
							end
						end
						
						targetPlayer = nearestPlayer
					end
					
					local function faceTarget()
						if hum and hum.Health > 0 and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
							local chrPos = root.Position
							local tPos = targetPlayer.Character.HumanoidRootPart.Position
							local modTPos = Vector3.new(tPos.X, chrPos.Y, tPos.Z)
							local newCF = CFrame.new(chrPos, modTPos)
							char:SetPrimaryPartCFrame(newCF)
						end
					end
				
					updateTarget()
					faceTarget()
				until (not AutoLook.Enabled)
			end)
		end 
	end
})

local AutoParry = {}
local ParryConnection
AutoParry = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
	Name = 'AutoParry',
	HoverText = "Made By YZFloppa!",
	Function = function(callback)
		if callback then
			task.spawn(function()
				ParryConnection = runService.RenderStepped:Connect(function()
					if Settings.Autoparry.Toggle then
						parry()
					end
				end)
			end)
		else
			ParryConnection:Disconnect()
		end
	end
})

GarouPrey = AutoParry.CreateToggle({
	Name = 'PreyPeril',
	Default = true,
	Function = function() end,
	HoverText = 'Hero Hunter Required'
})

local function TpToVoid(delay)
	local oldPosition = lplr.Character.HumanoidRootPart.Position
	lplr.Character.HumanoidRootPart.CFrame = CFrame.new(-253.74664306640625, 351.74859619140625, -575.7261962890625)
	task.wait(delay or 2)
	lplr.Character.HumanoidRootPart.CFrame = CFrame.new(oldPosition)
end
local TpPlayer = {}
local TpRange = {Value = 40}
local Garou = {}
local Sonic = {}
local function StartTeleport()
	local nearest = nil
	local cooldistance = TpRange.Value + 10
	for _, player in pairs(playersService:GetPlayers()) do
		if player ~= lplr then
			local character = player.Character
			if character and character:IsA("Model") then
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if rootPart and humanoid and humanoid.Health > 0 then
					local distance = (rootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude
					if distance < cooldistance then
						cooldistance = distance
						nearest = player
					end
				end
			end
		end
	end
	if nearest then
		local character = nearest.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			if Garou.Enabled then
				ActivateAbility("Flowing Water")
				TpToVoid(3)
			elseif Sonic.Enabled then
				ActivateAbility("Scatter")
				TpToVoid()
			end
		end
	end	
end
TpPlayer = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
	Name = 'InstaKill', 
	Function = function(callback)
		if callback then
			StartTeleport()
			TpPlayer.ToggleButton(false)
		end
	end,
	HoverText = "Need Sonic Character Or Garou Character!"
})
Garou = TpPlayer.CreateToggle({
	Name = 'Garou',
	Function = function() end
})

Sonic = TpPlayer.CreateToggle({
	Name = 'Sonic',
	Function = function() end
})

local FakeAbility = {}
local Abilities = {"Flowing Water", "Lethal Whirlwind Stream", "Hunter's Gasp", "Prey's Peril"}
local Ability = {Value = "Prey's Peril"}
local Activate = {}
FakeAbility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
	Name = "FakeGarouSkill",
	HoverText = "you can use any character and troll people :trollage:",
	Function = function(callback)
		playAnimation(AnimationController.Garou[Ability.Value])
		if Activate.Enabled then
			ActivateAbility(Ability.Value)
		end
	end
})
Ability = FakeAbility.CreateDropdown({
	Name = "Ability",
	List = Abilities,
	Function = function() end
})

Activate = FakeAbility.CreateToggle({
	Name = "Activate The Ability",
	HoverText = "Actually activate the ability but you need to use garou",
	Function = function() end
})

task.spawn(function()
	repeat task.wait() until shared.VapeFullyLoaded
	warningNotification("Render", "Tsb Powered By Render Red 🔥", 10)
end)

local AntiStun = {}
AntiStun = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
	Name = "AntiStun",
	Function = function(calling)
		if calling then
			task.spawn(function()
				repeat
					task.spawn(function()
						lplr.Character:FindFirstChild("NoRotate"):Destroy()
						lplr.Character:FindFirstChild("BeingGrabbed"):Destroy()
						lplr.Character:FindFirstChild("Small Debris"):Destroy()
						lplr.Character:FindFirstChild("RootAnchor"):Destroy()
					end)
					lplr.Character:FindFirstChild("Ragdoll"):Destroy()
					lplr.Character:FindFirstChild("RagdollSim"):Destroy()
					lplr.Character:FindFirstChild("Freeze"):Destroy()
					task.wait()
				until (not AntiStun.Enabled)
			end)
		end
	end
})

local UserProtection = {}
UserProtection = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
	Name = "UserProtection",
	Function = function(calling)
		if calling then
			
		else
			
		end
	end
})
