if not isfolder('vape/Render') then 
    return game:GetService('StarterGui'):SetCore('SendNotification', ({
        Title = 'Render', 
        Text = 'No installation detected, not installed.', 
        Icon = 'rbxassetid://16498204245',
        Duration = 20
    }))  
end

delfolder('vape/Render')

for i,v in next, listfiles('vape/CustomModules') do 
    if isfile('vape/CustomModules/'..v) then 
        delfolder('vape/CustomModules/'..v) 
    end
end

for i,v in next, ({'GuiLibrary.lua', 'MainScript.lua', 'NewMainScript.lua'}) do 
    if isfile('vape/'..v) then 
        delfolder('vape/'..v) 
    end 
end

game:GetService('StarterGui'):SetCore('SendNotification', ({
    Title = 'Render', 
    Text = 'Successfully uninstalled the render configuration. farewell soldier.', 
    Icon = 'rbxassetid://16498204245',
    Duration = 20
}))
