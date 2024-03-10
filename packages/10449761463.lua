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

local physicsUpdate = 1 / 60

local function predictGravity(playerPosition, vel, bulletTime, targetPart, Gravity)
	local estimatedVelocity = vel.Y
	local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
	local velocityCheck = (tick() - targetPart.JumpTick) < 0.2
	vel = vel * physicsUpdate

	for i = 1, math.ceil(bulletTime / physicsUpdate) do 
		if velocityCheck then 
			estimatedVelocity = estimatedVelocity - (Gravity * physicsUpdate)
		else
			estimatedVelocity = 0
			playerPosition = playerPosition + Vector3.new(0, -0.03, 0) -- bw hitreg is so bad that I have to add this LOL
			rootSize = rootSize - 0.03
		end

		local floorDetection = workspace:Raycast(playerPosition, Vector3.new(vel.X, (estimatedVelocity * physicsUpdate) - rootSize, vel.Z), bedwarsStore.blockRaycast)
		if floorDetection then 
			playerPosition = Vector3.new(playerPosition.X, floorDetection.Position.Y + rootSize, playerPosition.Z)
			local bouncepad = floorDetection.Instance:FindFirstAncestor('gumdrop_bounce_pad')
			if bouncepad and bouncepad:GetAttribute('PlacedByUserId') == targetPart.Player.UserId then 
				estimatedVelocity = 130 - (Gravity * physicsUpdate)
				velocityCheck = true
			else
				estimatedVelocity = targetPart.Humanoid.JumpPower - (Gravity * physicsUpdate)
				velocityCheck = targetPart.Jumping
			end
		end

		playerPosition = playerPosition + Vector3.new(vel.X, velocityCheck and estimatedVelocity * physicsUpdate or 0, vel.Z)
	end

	return playerPosition, Vector3.new(0, 0, 0)
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
			print('yesys')
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

local function ActivateAbility(name)
	lplr.Backpack[name].Parent = lplr.Character
	lplr.Backpack[name]:Activate()
	lplr.Backpack[name].Parent = lplr.Backpack
end

do
	entityLibrary.animationCache = {}
	entityLibrary.groundTick = tick()
	entityLibrary.selfDestruct()
	entityLibrary.isPlayerTargetable = function(plr)
		return lplr:GetAttribute('Team') ~= plr:GetAttribute('Team') and not isFriend(plr)
	end
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



local players = game:GetService("Players")
local plr = players.LocalPlayer
local cd = false
local Settings = {
	Autoparry = {
		Toggle = true, Range = 25, Delay = 0,Fov = 140, Facing = true, Dodgerange = 3, Aimhelper = false,
	}
}

local anims = {
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
local dodges = {
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

local closestplr, anim, plrDirection, unit, value,dodge
function lookatlol(player)
	if not player or not player:IsA("Player") or not player.Character then
		return false
	end
	local Char = player.Character
	if not Char or not Char:FindFirstChild("Head") then
		return false
	end
	local lplrChar = plr.Character
	if not lplrChar or not lplrChar:FindFirstChild("Head") then
		return false
	end
	local Charac = (lplrChar.Head.Position - Char.Head.Position).unit
	local CharLook = Char.Head.CFrame.LookVector
	local dp = Charac:Dot(CharLook)
	return dp > 0.5
end

function closest()
	local closestplr = {}
	for _, v in next, players:GetPlayers() do
		if v:IsA("Player") and v ~= plr and v.Character and plr.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
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
		z = anims[Anim.Animation.AnimationId]
		q = dodges[Anim.Animation.AnimationId]
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
	["anim"] = 0.3,
	["dodge"] = 0.3,
	["barrage"] = 0.9,
	["ability"] = 0.6,
}

function def(action)
	if cd then
		return
	end
	task.wait(Settings.Autoparry.Delay)
	print("parry attempt".."| "..action)
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

function parry()
	for i, c in closest() do
		if c and plr.Character:WaitForChild("HumanoidRootPart", 2) and c.Character and c.Character:FindFirstChild("Humanoid") and c.Character.Humanoid:FindFirstChild("Animator") then
			for i, v in next, c.Character.Humanoid.Animator:GetPlayingAnimationTracks() do
				anim = anims[v.Animation.AnimationId]
				dodge = dodges[v.Animation.AnimationId]
				ability = abilities[v.Animation.AnimationId]
				barrage = barrages[v.Animation.AnimationId]
				if allowed(c.Character) and anim and v.TimePosition >= anim[1] and v.TimePosition <= anim[2] then
					task.spawn(function()
						def("m1")
						lookat(c.Character)
					end)
				elseif allowed(c.Character) and dodge and v.TimePosition > dodge[1] and v.TimePosition < dodge[2] then
					task.spawn(function()
						def("dash")
						lookat(c.Character)
					end)
				elseif allowed(c.Character) and barrage and v.TimePosition > barrage[1] and v.TimePosition < barrage[2] then
					task.spawn(function()
						def("barrage")
						lookat(c.Character)
					end)
				elseif allowed(c.Character) and ability and v.TimePosition > ability[1] and v.TimePosition < ability[2] then
					task.spawn(function()
						def("ability")
						lookat(c.Character)
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

runFunction(function()
	local function Teleport(part)
		lplr.Character.HumanoidRootPart.CFrame = CFrame.new(part)
	end
	local Killaura = {}
	local Check
	local AutoSkill = {}
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
			if rootPart and isAlive(lplr, true) then
				task.spawn(function()
					if AutoSkill.Enabled then
						task.wait(0.11)
						Check = true
						task.wait(0.2)
						Check = false
					else
						task.wait(0.11)
						Check = true
						task.wait(0.2)
						Check = false
					end
				end)
				repeat task.wait()
					task.wait(0.05)
					Teleport(rootPart.Position + Vector3.new(2,2,2))
					if AutoSkill.Enabled then
						Teleport(rootPart.Position + Vector3.new(2,2,2))
						ActivateAbility("Flowing Water")
						Teleport(rootPart.Position + Vector3.new(2,2,2))
						ActivateAbility("Lethal Whirlwind Stream")
						Teleport(rootPart.Position + Vector3.new(2,2,2))
						lplr.Character.Communicate:FireServer({
							["Goal"] = "LeftClick",
							["Mobile"] = true
						})	
						Teleport(rootPart.Position + Vector3.new(2,2,2))
					else
						lplr.Character.Communicate:FireServer({
							["Goal"] = "LeftClick",
							["Mobile"] = true
						})	
					end
				until (not Check)
				lplr.Character.HumanoidRootPart.CFrame = CFrame.new(oldPosition)
				game:GetService("Players").LocalPlayer.Character.Communicate:FireServer({
					["Goal"] = "LeftClickRelease",
					["Mobile"] = true
				})
				print("M1 Attempted")
			end
		end
			
    end
	Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Killaura', 
		Function = function(callback)
			if callback then
				repeat task.wait()
					Attack()
				until (not Killaura.Enabled)
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
						task.wait()
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
end)


runFunction(function()
	local AutoLook = {}
	local AutoLookRotate = {Value = 5}
	local AutoLookHeight = {Value = 2}
	local connection1
	AutoLook = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'AutoLook',
        HoverText = 'Automatically looks in the\ndirection you are walking',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until entityLunar.isAlive or not AutoLook.Enabled
					connection1 = runService.Heartbeat:Connect(function()
						if entityLunar.isAlive then
							local newmovedir = vec3(lplr.Character.HumanoidRootPart.Velocity.X, 0, lplr.Character.HumanoidRootPart.Velocity.Z)
							local newplace = lplr.Character.HumanoidRootPart.CFrame.Position + newmovedir
							if vec2(lplr.Character.HumanoidRootPart.Velocity.X, lplr.Character.HumanoidRootPart.Velocity.Z).magnitude > 1 then
								if isnetworkowner(lplr.Character.HumanoidRootPart) then
									lplr.Character.HumanoidRootPart.CFrame = CFrame.lookAt(lplr.Character.HumanoidRootPart.CFrame.Position, newplace, (lplr.Character.HumanoidRootPart.Velocity / lplr.Character.HumanoidRootPart.Velocity.magnitude) * (vec3(0, AutoLookRotate.Value, 0) * (lplr.Character.HumanoidRootPart.Velocity / lplr.Character.HumanoidRootPart.Velocity.magnitude)))
									lplr.Camera.CFrame = CFrame.new(lplr.Character.HumanoidRootPart.Position + vec3(0, AutoLookHeight.Value, 0))
								end
							end
						end
					end)
				end)
			else
				if connection1 then
					connection1:Disconnect()
				end
			end
		end,
        Default = false
	})
	AutoLookRotate = AutoLook.CreateSlider({
		Name = 'Rotate',
		Min = 0,
		Max = 10,
		HoverText = 'Rotate Amount',
		Function = function() end,
		Default = 5,
		Double = 10
	})
	AutoLookHeight = AutoLook.CreateSlider({
		Name = 'Height',
		Min = 1,
		Max = 5,
		HoverText = 'Camera Height',
		Function = function() end,
		Default = 2
	})
end)

runFunction(function()
	local TpPlayer = {}
	local function Teleport(part)
		lplr.Character.HumanoidRootPart.CFrame = CFrame.new(part)
	end
	local TpRange = {Value = 25}
	local InstaKill = {}
	local instacheck = nil
	local BringPlr = {}
	local function StartTeleport()
		local nearest = nil
		local cooldistance = TpRange.Value * TpRange.Value
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
				if InstaKill.Enabled then
					task.spawn(function()
						instacheck = true
						task.wait(0.3)
						instacheck = false
					end)
					repeat 
						task.wait(0.1)
						ActivateAbility("Scatter")
						Teleport(rootPart.Position)
					until (not instacheck)
					lplr.Character.HumanoidRootPart.CFrame = CFrame.new(-253.74664306640625, 351.74859619140625, -575.7261962890625)
					wait(3)
					lplr.Character.HumanoidRootPart.CFrame = CFrame.new(oldPosition)
				elseif BringPlr.Enabled then
					TpRange.Value = 10000
					task.spawn(function()
					
						instacheck = true
						task.wait(0.3)
						instacheck = false
					end)
					repeat 
						task.wait(0.1)
						ActivateAbility("Scatter")
						Teleport(rootPart.Position)
					until (not instacheck)
					wait(3.5)
					lplr.Character.HumanoidRootPart.CFrame = CFrame.new(oldPosition)
				end
			end
		end	
		TpPlayer.ToggleButton(false)
    end
	TpPlayer = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'Teleport Player', 
		Function = function(callback)
			if callback then
				StartTeleport()
			end
		end,
		HoverText = "Need Sonic Character Or Garou Character!"
	})
	InstaKill = TpPlayer.CreateToggle({
        Name = 'InstaKill',
        Default = true,
        Function = function() end
    })
	BringPlr = TpPlayer.CreateToggle({
        Name = 'BringPlayer',
        Default = false,
        Function = function() end
    })
end)

runFunction(function()
    local FakeAbility = {}
	local Abilities = {"Flowing Water", "Lethal Whirlwind Stream", "Hunter's Gasp", "Prey's Peril"}
	local Ability = {Value = "Prey's Peril"}
	local Activate = {}
    FakeAbility = GuiLibrary.ObjectsThatCanBeSaved.KeybindWindow.Api.CreateOptionsButton({
        Name = "FakeGarouSkill",
		HoverText = "you can use any character and troll people :trollage:",
        Function = function(callback)
			playAnimation(AnimationController.Garou[Ability.Value])
			if Activate.Enabled then
				ActivateAbility(Ability.Value)
			end
			FakeAbility.ToggleButton(false)
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
end)

-- i love haudhqwieqwhje
