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
local lp = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Re = game:GetService("ReplicatedStorage")

-- [[ 1. SIÊU BYPASS CHẶN QUÉT ]]
task.spawn(function()
    pcall(function()
        for _, v in pairs(game:GetDescendants()) do
            if v.Name:lower():match("adonis") or v.Name:match("ClientMover") then v:Destroy() end
        end
        local old; old = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
            local a = {...}
            if typeof(a[1]) == "table" and a[1].Mode == "Get" then return nil end
            return old(self, ...)
        end))
    end)
end)

-- [[ 2. HÀM BAY LÊN AN TOÀN (FIX LỖI TRỤC Y) ]]
local function SafeRise(root, targetY)
    local speedY = 50 -- Vận tốc bay lên (Giảm xuống nếu vẫn bị chữ đỏ)
    while root.Position.Y < targetY and getgenv().AC do
        root.Velocity = Vector3.new(0, speedY, 0)
        -- Gửi Geppo liên tục để server tưởng bạn đang nhảy lên
        pcall(function() Re.Events.Geppo:FireServer() end)
        task.wait()
        if (targetY - root.Position.Y) < 5 then break end
    end
    root.Velocity = Vector3.new(0, 0, 0)
end

-- [[ 3. HÀM DI CHUYỂN TỔNG HỢP ]]
local function go(target, landH)
    local c = lp.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r or not target then return end

    local targetPos = target:GetPivot().Position + Vector3.new(0, landH or 5, 0)
    local skyY = r.Position.Y + 150 
    
    local f = true
    local nc = RS.Stepped:Connect(function()
        if not f then return end
        for _, p in pairs(c:GetDescendants()) do 
            if p:IsA("BasePart") then p.CanCollide = false end 
        end
    end)

    -- BƯỚC 1: BAY LÊN TỪ TỪ (KHÔNG DÙNG TELEPORT TRỤC Y)
    SafeRise(r, skyY)
    task.wait(0.1)

    -- BƯỚC 2: BAY NGANG TRÊN KHÔNG
    local skyPoint = Vector3.new(targetPos.X, skyY, targetPos.Z)
    local dist = (r.Position - skyPoint).Magnitude
    local tw = TS:Create(r, TweenInfo.new(dist/100, Enum.EasingStyle.Linear), {CFrame = CFrame.new(skyPoint)})
    
    tw:Play()
    task.spawn(function()
        while f and tw.PlaybackState == Enum.PlaybackState.Playing do
            pcall(function() Re.Events.Geppo:FireServer() end)
            lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.3)
        end
    end)
    tw.Completed:Wait()

    -- BƯỚC 3: TELE XUỐNG (CHỈ TELE KHI ĐÃ Ở NGAY TRÊN ĐẦU)
    r.CFrame = CFrame.new(targetPos)
    task.wait(0.2)

    -- NHẶT ĐỒ
    local p = target:FindFirstChildOfClass("ProximityPrompt", true)
    if p then
        p.HoldDuration = 0
        p:InputHoldBegin() task.wait(0.1)
        fireproximityprompt(p)
        p:InputHoldEnd()
    end

    f = false
    nc:Disconnect()
    pcall(function() Re.Events.Skill:InvokeServer("Explosive Mines") end)
end

-- [[ 4. VÒNG LẶP QUÉT ƯU TIÊN ]]
task.spawn(function()
    while getgenv().AC do
        task.wait(1)
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local t = workspace.NPCs:FindFirstChild("Vera") or workspace.Effects:FindFirstChild("Key")
            if not t then
                for _, v in pairs(workspace:GetDescendants()) do
                    if (tonumber(v.Name) or v.Name:match("Chest")) and v:FindFirstChildOfClass("ProximityPrompt", true) then t = v break end
                end
            end
            if not t then t = workspace.Effects:FindFirstChild("Bomb") end
            if not t then
                local m = math.huge
                for _, v in pairs(workspace.NPCs:GetChildren()) do
                    if v.Name == "ImpelGuard" then
                        local d = (lp.Character.HumanoidRootPart.Position - v:GetPivot().Position).Magnitude
                        if d < m then m = d t = v end
                    end
                end
            end
            if t then go(t, 5) task.wait(1.5) end
        end
    end
end)