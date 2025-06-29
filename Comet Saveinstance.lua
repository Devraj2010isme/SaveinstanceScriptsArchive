-- stop skidding bro

getgenv().saveinstance = function(saving)
    local ScreenGui = Instance.new("ScreenGui")
    local TextLabel = Instance.new("TextLabel")
    
    ScreenGui.Parent = gethui()
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    TextLabel.Parent = ScreenGui
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BorderSizePixel = 0
    TextLabel.Position = UDim2.new(1, -300, 0.5, -50)
    TextLabel.Size = UDim2.new(0, 300, 0, 100)
    TextLabel.Font = Enum.Font.FredokaOne
    TextLabel.Text = "If you have any questions or issues, make sure to report them by pinging @theunrealninja in the discord!"
    TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextScaled = true
    TextLabel.TextWrapped = true
    if not saving then saving = {workspace,game.Lighting,game.ReplicatedFirst,game.ReplicatedStorage,game.StarterGui,game.StarterPack,game.Teams} end 
    getgenv().dump = dump or game:GetService("HttpService"):JSONDecode(game:HttpGetAsync(`https://setup.rbxcdn.com/{game:HttpGetAsync("https://setup.rbxcdn.com/versionQTStudio")}-API-Dump.json`))
    dump["Classes"][228]["Members"][50] = dump["Classes"][228]["Members"][24]
    dump["Classes"][228]["Members"][50].Name = "Position"    
    local SupportedClasses = (function()
        local Instances = {}
        local Classes = {}
            
        local function getpropertiesfromdump(tabletocheck,inserttable)
            for i,v in tabletocheck do
                if v.MemberType == "Property" then
                    local Tags = v.Tags
                    if Tags then
                        if not table.find(Tags,"Deprecated") and not table.find(Tags,"NotScriptable") and not table.find(Tags,"Hidden") then
                            if v.ValueType.Category == "Enum" then
                                table.insert(inserttable,{v.Name,  "Enum"})
                            else
                                table.insert(inserttable,{v.Name, v.ValueType.Name})
                            end
                        end
                    else
                        if v.ValueType.Category == "Enum" then
                            table.insert(inserttable,{v.Name,  "Enum"})
                        else
                            table.insert(inserttable,{v.Name, v.ValueType.Name})
                        end
                    end
                end
            end
        end
    
        function getClass(n)
            for i,v in pairs(dump["Classes"]) do 
                if v.Name == n then 
                    return v 
                end
            end
         end

        for i,v in dump.Classes do
            if v.Superclass == "<<<ROOT>>>" then
                getpropertiesfromdump(v.Members,Instances)
            else
                Classes[v.Name] = (function()
                    local Properties = {}
                    getpropertiesfromdump(v.Members,Properties)
                    local re = getClass(v.Superclass)
                    repeat 
                        getpropertiesfromdump(re.Members,Properties)
                        re = getClass(re.Superclass)
                    until not re or re.Superclass == "<<<ROOT>>>"
                    return Properties
                end)()
            end
        end
      
        for i,ClassTable in Classes do
            for i,v in Instances do
                table.insert(ClassTable,v)
            end
        end
      
        return Classes
    end)()
    table.insert(SupportedClasses["UnionOperation"],{"AssetId", "Content"})
    table.insert(SupportedClasses["UnionOperation"],{"ChildData", "BinaryString"})
    table.insert(SupportedClasses["UnionOperation"],{"FormFactor", "Enum"})
    table.insert(SupportedClasses["UnionOperation"],{"InitialSize", "Vector3"})
    table.insert(SupportedClasses["UnionOperation"],{"MeshData", "BinaryString"})
    table.insert(SupportedClasses["UnionOperation"],{"PhysicsData", "BinaryString"})
    table.insert(SupportedClasses["MeshPart"], {"PhysicsData", "BinaryString"})
    table.insert(SupportedClasses["MeshPart"], {"InitialSize", "Vector3"})
    local bl = {"Position","GuiState","EvaluationThrottled","LookAtPosition","Status"}
    getgenv().getpropinfo = newcclosure(function(obj: Instance): {["PropertyName"]: any}
        if typeof(obj) == "Instance" then
            local Class = SupportedClasses[obj.ClassName]
            local Properties = {}
    
            for i,v in Class do
                if not table.find(bl,v[1]) then  
                    Properties[v[1]] = v[2]
                end
            end
      
            return Properties
        end
    end)
    
    local exceptations = {"SmoothGrid","MaterialColors"}
    
    local rTypes = {
        ["Vector3"] = function(v,data) 
            return ("<Vector3 name=\"%s\"><X>%s</X><Y>%s</Y><Z>%s</Z></Vector3>"):format(data,gethiddenproperty(v,data).X,gethiddenproperty(v,data).Y,gethiddenproperty(v,data).Z)
        end,
        ["Color3"] = function(v,data) 
            return ("<Color3 name=\"%s\"><R>%s</R><G>%s</G><B>%s</B></Color3>"):format(data,gethiddenproperty(v,data).R,gethiddenproperty(v,data).G,gethiddenproperty(v,data).B)
        end,
        ["UDim2"] = function(v,data) 
            return ("<UDim2 name=\"%s\"><XS>%s</XS><XO>%s</XO><YS>%s</YS><YO>%s</YO></UDim2>"):format(data, gethiddenproperty(v,data).X.Scale, gethiddenproperty(v,data).X.Offset, gethiddenproperty(v,data).Y.Scale, gethiddenproperty(v,data).Y.Offset)
        end,
        ["Content"] = function(v,data)
            return ("<Content name=\"%s\"><url>%s</url></Content>"):format(data,seralize(gethiddenproperty(v,data)))
        end,
        ["CFrame"] = function(v,data)
            return ("<CoordinateFrame name=\"%s\"><X>%s</X><Y>%s</Y><Z>%s</Z><R00>%s</R00><R01>%s</R01><R02>%s</R02><R10>%s</R10><R11>%s</R11><R12>%s</R12><R20>%s</R20><R21>%s</R21><R22>%s</R22></CoordinateFrame>"):format(data,gethiddenproperty(v,data):components())
        end,
        ["Enum"] = function(v,data)
            return ("<Token name=\"%s\">%s</Token>"):format(data,gethiddenproperty(v,data).Value)
        end,
        ["BinaryString"] = function(v,data)
            if table.find(exceptations,data) then
                return ("<![CDATA[%s]]>"):format(crypt.base64.encode(gethiddenproperty(v,data)))
            else
                return crypt.base64.encode(gethiddenproperty(v,data))
            end
        end,
        ["Instance"] = function(...) return "" end
    }
        
    local escapes = {
        ["\""] = "&quot;",
        ["&"] = "&amp;",
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ["\""] = "&apos;"
    }
    
    function seralize(word)
        word = tostring(word)
        for i,v in pairs(escapes) do
            word = string.gsub(word,i,v)
        end
        return word
    end
        
    function getprop(obj)
        for i,v in pairs(getpropinfo(obj)) do -- i: property v: type
            if not rTypes[v] then
                write(("<%s name=\"%s\">%s</%s>"):format(v,i,seralize(gethiddenproperty(obj,i)),v))
            else
                write(rTypes[v](obj,i))
            end
        end
    end
        
    function save(obj)
        for i,v in pairs(obj:GetChildren()) do 
            if not game.Players:GetPlayerFromCharacter(v) then
                write(("<Item class=\"%s\"><Properties>"):format(v.ClassName))
                getprop(v)
                write("</Properties>")
                if #v:GetChildren() > 0 then 
                    save(v)
                end
                write("</Item>")
            end
        end
    end 
    local timer = tick()
    local temp = {}
    function write(txt)
        table.insert(temp,txt)
    end
    write([[<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">]])

    for i,v in saving do task.wait()
        write(("<Item class=\"%s\"><Properties>"):format(v.ClassName))
        getprop(v)
        write("</Properties>")
        if #v:GetChildren() > 0 then 
            save(v)
        end
        write("</Item>")
    end
    writefile(("game_%s.rbxlx"):format(game.PlaceId),table.concat(temp," ").."</roblox>")
    print(("Done! Took %ss"):format(math.round((tick()-timer)*100)/100)) 
end