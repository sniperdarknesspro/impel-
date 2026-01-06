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

getgenv().AC = true 
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local lp = game.Players.LocalPlayer
local Re = game:GetService("ReplicatedStorage")

-- [[ PHẦN 1: BYPASS ANTI-CHEAT ]]
task.spawn(function()
    pcall(function()
        for _, v in pairs(game:GetDescendants()) do
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

-- [[ PHẦN 2: AUTO SKILL ]]
local function sk()
    pcall(function()
        Re.Events.stats:FireServer("DevilFruitMastery", nil, 700)
        local s = Re:FindFirstChild(lp.Name.."|ServerScriptService.Skills.Skills.SkillContainer.Bomb-Bomb.Explosive Mines")
        if s then s:InvokeServer({cf=lp.Character.HumanoidRootPart.CFrame}) 
        else Re.Events.Skill:InvokeServer("Explosive Mines") end
    end)
end

-- [[ PHẦN 3: DI CHUYỂN THANG MÁY (Y HIỆN TẠI + 200) ]]
local function go(t, h)
    local c = lp.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r or not t then return end
    
    local f = true
    local nc = RS.Stepped:Connect(function()
        if not f then return end
        for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end)

    -- Lấy vị trí Y hiện tại và cộng thêm 200
    local startPos = r.Position
    local skyY = startPos.Y + 200 
    local targetLanding = t:GetPivot().Position + Vector3.new(0, h or 5, 0)
    
    -- 1. THANG MÁY LÊN: Từ Y hiện tại nhảy lên +200
    r.CFrame = CFrame.new(startPos.X, skyY, startPos.Z)
    task.wait(0.1)
    
    -- 2. BAY NGANG TRÊN TRỜI: Giữ nguyên độ cao skyY
    local skyPoint = Vector3.new(targetLanding.X, skyY, targetLanding.Z)
    local dist = (r.Position - skyPoint).Magnitude
    local tw = TS:Create(r, TweenInfo.new(dist/100, Enum.EasingStyle.Linear), {CFrame = CFrame.new(skyPoint)})
    tw:Play()
    tw.Completed:Wait()
    
    -- 3. THANG MÁY XUỐNG: Đáp xuống mục tiêu
    r.CFrame = CFrame.new(targetLanding)
    task.wait(0.2)

    -- Nhặt đồ
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
    sk()
end

-- [[ PHẦN 4: VÒNG LẶP CHÍNH ]]
task.spawn(function()
    while getgenv().AC do
        task.wait(1)
        local r = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if r then
            -- Thứ tự ưu tiên: Key > Bomb > Guard/Chest
            local t = workspace.Effects:FindFirstChild("Key") or workspace.Effects:FindFirstChild("Bomb")
            if not t then
                local m = math.huge
                for _,v in pairs(workspace:GetDescendants()) do
                    if (v.Name == "ImpelGuard" or tonumber(v.Name) or v.Name:match("Chest")) and v:FindFirstChildOfClass("ProximityPrompt", true) then
                        local d = (r.Position - v:GetPivot().Position).Magnitude
                        if d < m then m = d t = v end
                    end
                end
            end
            if t then go(t, 5) task.wait(1) end
        end
    end
end)