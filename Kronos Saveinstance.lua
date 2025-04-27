getgenv().saveinstance = function(saving)
    if not saving then saving = {workspace,game.Lighting,game.ReplicatedFirst,game.ReplicatedStorage,game.StarterGui,game.StarterPack,game.Teams} end 
    getgenv().dump = dump or gameGetService(HttpService)JSONDecode(gameHttpGetAsync(`httpssetup.rbxcdn.com{gameHttpGetAsync(httpssetup.rbxcdn.comversionQTStudio)}-API-Dump.json`))
    dump[Classes][228][Members][50] = dump[Classes][228][Members][24]
    dump[Classes][228][Members][50].Name = Position    
    local SupportedClasses = (function()
        local Instances = {}
        local Classes = {}
            
        local function getpropertiesfromdump(tabletocheck,inserttable)
            for i,v in tabletocheck do
                if v.MemberType == Property then
                    local Tags = v.Tags
                    if Tags then
                        if not table.find(Tags,Deprecated) and not table.find(Tags,NotScriptable) and not table.find(Tags,Hidden) then
                            if v.ValueType.Category == Enum then
                                table.insert(inserttable,{v.Name,  Enum})
                            else
                                table.insert(inserttable,{v.Name, v.ValueType.Name})
                            end
                        end
                    else
                        if v.ValueType.Category == Enum then
                            table.insert(inserttable,{v.Name,  Enum})
                        else
                            table.insert(inserttable,{v.Name, v.ValueType.Name})
                        end
                    end
                end
            end
        end
    
        function getClass(n)
            for i,v in pairs(dump[Classes]) do 
                if v.Name == n then 
                    return v 
                end
            end
         end

        for i,v in dump.Classes do
            if v.Superclass == ROOT then
                getpropertiesfromdump(v.Members,Instances)
            else
                Classes[v.Name] = (function()
                    local Properties = {}
                    getpropertiesfromdump(v.Members,Properties)
                    local re = getClass(v.Superclass)
                    repeat 
                        getpropertiesfromdump(re.Members,Properties)
                        re = getClass(re.Superclass)
                    until not re or re.Superclass == ROOT
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
    table.insert(SupportedClasses[UnionOperation],{AssetId, Content})
    table.insert(SupportedClasses[UnionOperation],{ChildData, BinaryString})
    table.insert(SupportedClasses[UnionOperation],{FormFactor, Enum})
    table.insert(SupportedClasses[UnionOperation],{InitialSize, Vector3})
    table.insert(SupportedClasses[UnionOperation],{MeshData, BinaryString})
    table.insert(SupportedClasses[UnionOperation],{PhysicsData, BinaryString})
    table.insert(SupportedClasses[MeshPart], {PhysicsData, BinaryString})
    table.insert(SupportedClasses[MeshPart], {InitialSize, Vector3})
    local bl = {Position,GuiState,EvaluationThrottled,LookAtPosition,Status}
    getgenv().getpropinfo = newcclosure(function(obj Instance) {[PropertyName] any}
        if typeof(obj) == Instance then
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
    
    local exceptations = {SmoothGrid,MaterialColors}
    
    local rTypes = {
        [Vector3] = function(v,data) 
            return (Vector3 name=%sX%sXY%sYZ%sZVector3)format(data,gethiddenproperty(v,data).X,gethiddenproperty(v,data).Y,gethiddenproperty(v,data).Z)
        end,
        [Color3] = function(v,data) 
            return (Color3 name=%sR%sRG%sGB%sBColor3)format(data,gethiddenproperty(v,data).R,gethiddenproperty(v,data).G,gethiddenproperty(v,data).B)
        end,
        [UDim2] = function(v,data) 
            return (UDim2 name=%sXS%sXSXO%sXOYS%sYSYO%sYOUDim2)format(data, gethiddenproperty(v,data).X.Scale, gethiddenproperty(v,data).X.Offset, gethiddenproperty(v,data).Y.Scale, gethiddenproperty(v,data).Y.Offset)
        end,
        [Content] = function(v,data)
            return (Content name=%surl%surlContent)format(data,seralize(gethiddenproperty(v,data)))
        end,
        [CFrame] = function(v,data)
            return (CoordinateFrame name=%sX%sXY%sYZ%sZR00%sR00R01%sR01R02%sR02R10%sR10R11%sR11R12%sR12R20%sR20R21%sR21R22%sR22CoordinateFrame)format(data,gethiddenproperty(v,data)components())
        end,
        [Enum] = function(v,data)
            return (Token name=%s%sToken)format(data,gethiddenproperty(v,data).Value)
        end,
        [BinaryString] = function(v,data)
            if table.find(exceptations,data) then
                return (![CDATA[%s]])format(crypt.base64.encode(gethiddenproperty(v,data)))
            else
                return crypt.base64.encode(gethiddenproperty(v,data))
            end
        end,
        [Instance] = function(...) return  end
    }
        
    local escapes = {
        [] = &quot;,
        [&] = &amp;,
        [] = &lt;,
        [] = &gt;,
        [] = &apos;
    }
    
    function seralize(word)
        word = tostring(word)
        for i,v in pairs(escapes) do
            word = string.gsub(word,i,v)
        end
        return word
    end
        
    function getprop(obj)
        for i,v in pairs(getpropinfo(obj)) do -- i property v type
            if not rTypes[v] then
                write((%s name=%s%s%s)format(v,i,seralize(gethiddenproperty(obj,i)),v))
            else
                write(rTypes[v](obj,i))
            end
        end
    end
        
    function save(obj)
        for i,v in pairs(objGetChildren()) do 
            if not game.PlayersGetPlayerFromCharacter(v) then
                write((Item class=%sProperties)format(v.ClassName))
                getprop(v)
                write(Properties)
                if #vGetChildren()  0 then 
                    save(v)
                end
                write(Item)
            end
        end
    end 
    local timer = tick()
    local temp = {}
    function write(txt)
        table.insert(temp,txt)
    end
    write([[roblox xmlnsxmime=httpwww.w3.org200505xmlmime xmlnsxsi=httpwww.w3.org2001XMLSchema-instance xsinoNamespaceSchemaLocation=httpwww.roblox.comroblox.xsd version=4]])

    for i,v in saving do task.wait()
        write((Item class=%sProperties)format(v.ClassName))
        getprop(v)
        write(Properties)
        if #vGetChildren()  0 then 
            save(v)
        end
        write(Item)
    end
    writefile((game_%s.rbxlx)format(game.PlaceId),table.concat(temp, )..roblox)
    print((Done! Took %ss)format(math.round((tick()-timer)100)100)) 
    print(Credit To HTDBarsi & Nori)
end
