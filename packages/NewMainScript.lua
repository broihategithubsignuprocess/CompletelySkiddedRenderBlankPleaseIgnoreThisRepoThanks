local identity = (getidentity or syn and syn.getidentity or function() return 2 end)
local httpService = game:GetService('HttpService')
local setidentity = (setthreadcaps or syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity or function() end)
local oldcall
local isfile = isfile or function(file)
    local success, filecontents = pcall(function() return readfile(file) end)
    return success and type(filecontents) == 'string'
end 

if shared == nil then
	getgenv().shared = {} 
end

if hookmetamethod then -- mobile exploits poop lol
	oldcall = hookmetamethod(game, '__namecall', function(self, ...) 
		if shared.VapeExecuted and self == httpService then 
			local oldidentity = identity()
			setidentity(8)
			local res = oldcall(self, ...)
			setidentity(oldidentity)
			return res
		end
		return oldcall(self, ...)
	end)
end

if isfile('vape/MainScript.lua') then 
	loadfile('vape/MainScript.lua')()
else 
	local mainscript = game:HttpGet('https://raw.githubusercontent.com/SystemXVoid/Render/source/packages/MainScript.lua') 
	task.spawn(function() loadstring(mainscript)() end)
	writefile('vape/MainScript.lua', mainscript)
end