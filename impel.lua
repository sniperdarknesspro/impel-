--[[
-- Sử dụng game:HttpGet để tải nội dung từ GitHub về
local success, scriptContent = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/sniperdarknesspro/impel-/main/impel.lua")
end)

if success then
    -- Chuyển chuỗi văn bản thành code có thể chạy được
    local runScript = loadstring(scriptContent)
    runScript() 
    print("Script GPO của bạn đã chạy!")
else
    warn("Không thể kết nối tới GitHub. Kiểm tra lại internet hoặc link!")
end
]]
-- [[ AUTO IMPEL DOWN - FULL BYPASS & PRIORITY COLLECT ]]
-- Thứ tự ưu tiên: Key > Bomb > ImpelGuard > Chest (Rương số)

-- [[ CONFIG & SETTINGS ]]
getgenv().AC = true
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local Re = game:GetService("ReplicatedStorage")
local lp = game.Players.LocalPlayer

-- [[ PHẦN 1: BYPASS & ANTI-BAN ]]
task.spawn(function()
    pcall(function()
        for _,v in pairs(game:GetDescendants()) do
            if v.Name:lower():match("adonis") or v.Name:match("ClientMover") then v:Destroy() end
        end
    end)
    pcall(function()
        local o; o = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(s,...)
            local a = {...}
            if typeof(a[1]) == "table" and a[1].Mode == "Get" then return nil end
            return o(s,...)
        end))
    end)
end)

-- [[ PHẦN 2: AUTO SKILL & STATS ]]
local function sk()
    pcall(function()
        Re.Events.stats:FireServer("DevilFruitMastery", nil, 700)
        local s = Re:FindFirstChild(lp.Name.."|ServerScriptService.Skills.Skills.SkillContainer.Bomb-Bomb.Explosive Mines")
        if s then s:InvokeServer({cf=lp.Character.HumanoidRootPart.CFrame}) 
        else Re.Events.Skill:InvokeServer("Explosive Mines") end
    end)
end

-- [[ PHẦN 3: HÀM DI CHUYỂN THANG MÁY (ELEVATOR) ]]
local function go(t, h)
    local c = lp.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r or not t then return end
    
    local f = true
    local nc = RS.Stepped:Connect(function()
        if not f then return end
        for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end)

    -- Logic di chuyển 3 bước
    local startP = r.Position
    local targetP = t:GetPivot().Position + Vector3.new(0, h or 5, 0)
    local skyY = 500
    
    -- 1. Tele lên trời
    r.CFrame = CFrame.new(startP.X, skyY, startP.Z)
    task.wait(0.1)
    
    -- 2. Bay ngang (Tốc độ 100)
    local skyP = Vector3.new(targetP.X, skyY, targetP.Z)
    local tw = TS:Create(r, TweenInfo.new((r.Position-skyP).Magnitude/100, Enum.EasingStyle.Linear), {CFrame = CFrame.new(skyP)})
    tw:Play()
    tw.Completed:Wait()
    
    -- 3. Tele xuống mục tiêu
    r.CFrame = CFrame.new(targetP)
    task.wait(0.2)

    -- Nhặt đồ / Mở rương
    local p = t:FindFirstChildOfClass("ProximityPrompt", true)
    if p then
        p.HoldDuration = 0
        p:InputHoldBegin()
        task.wait(0.2)
        fireproximityprompt(p)
        p:InputHoldEnd()
    end
    
    f = false
    nc:Disconnect()
    sk() -- Dùng skill sau khi tới nơi
end

-- [[ PHẦN 4: VÒNG LẶP CHÍNH (THỨ TỰ ƯU TIÊN) ]]
task.spawn(function()
    while getgenv().AC do
        task.wait(1)
        local r = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if r then
            -- Kiểm tra ưu tiên: Key > Bomb
            local t = workspace.Effects:FindFirstChild("Key") or workspace.Effects:FindFirstChild("Bomb")
            
            -- Nếu không có, tìm ImpelGuard hoặc Rương ID
            if not t then
                local m = math.huge
                for _,v in pairs(workspace:GetDescendants()) do
                    if (v.Name == "ImpelGuard" or tonumber(v.Name) or v.Name:match("Chest")) and v:FindFirstChildOfClass("ProximityPrompt", true) then
                        local d = (r.Position - v:GetPivot().Position).Magnitude
                        if d < m then m = d t = v end
                    end
                end
            end
            
            -- Thực hiện di chuyển nếu tìm thấy mục tiêu
            if t then
                print("Dang di chuyen den: " .. t.Name)
                go(t, 5)
                task.wait(1)
            end
        end
    end
end)