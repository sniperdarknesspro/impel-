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
local Re = game:GetService("ReplicatedStorage")
local lp = game.Players.LocalPlayer

-- [[ PHẦN 1: BẢO MẬT NÂNG CAO (NATALIE WOOD LOGIC) ]]
task.spawn(function()
    pcall(function()
        for _, v in pairs(game:GetDescendants()) do
            if v.Name:lower():match("adonis") or v.Name:match("ClientMover") then v:Destroy() end
        end
    end)
    pcall(function()
        local o; o = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(s, ...)
            local a = {...}
            if typeof(a[1]) == "table" and a[1].Mode == "Get" then return nil end
            return o(s, ...)
        end))
    end)
end)

-- [[ PHẦN 2: HÀM DI CHUYỂN THANG MÁY (ELEVATOR) ]]
local function ElevatorMove(target, landHeight)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not target then return end

    local flying = true
    local noclip = RS.Stepped:Connect(function()
        if not flying then return end
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)

    -- TỌA ĐỘ CHI TIẾT
    local startPos = root.Position
    local targetPos = target:GetPivot().Position + Vector3.new(0, landHeight or 5, 0)
    local skyY = startPos.Y + 300 -- Độ cao an toàn tránh mọi vật cản

    -- BƯỚC 1: TELE LÊN CAO (INSTANT TELEPORT)
    root.CFrame = CFrame.new(startPos.X, skyY, startPos.Z)
    task.wait(0.1)

    -- BƯỚC 2: BAY NGANG TRÊN KHÔNG (TWEEN NGANG)
    local skyPoint = Vector3.new(targetPos.X, skyY, targetPos.Z)
    local dist = (root.Position - skyPoint).Magnitude
    local tween = TS:Create(root, TweenInfo.new(dist/120, Enum.EasingStyle.Linear), {CFrame = CFrame.new(skyPoint)})
    tween:Play()
    tween.Completed:Wait()

    -- BƯỚC 3: TELE XUỐNG ĐÍCH (KHÔNG BAY XUỐNG - CHỐNG BAN)
    root.CFrame = CFrame.new(targetPos)
    task.wait(0.2)

    -- NHẶT ĐỒ / MỞ RƯƠNG
    local prompt = target:FindFirstChildOfClass("ProximityPrompt", true)
    if prompt then
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        task.wait(0.1)
        fireproximityprompt(prompt)
        prompt:InputHoldEnd()
    end

    flying = false
    noclip:Disconnect()
    
    -- Dùng Skill Bomb nổ sau khi tới đích
    pcall(function()
        Re.Events.stats:FireServer("DevilFruitMastery", nil, 700)
        Re.Events.Skill:InvokeServer("Explosive Mines")
    end)
end

-- [[ PHẦN 3: LOGIC QUÉT ƯU TIÊN (PRIORITY SCANNER) ]]
task.spawn(function()
    while getgenv().AC do
        task.wait(1)
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local target = nil
            
            -- Priority 1: Vera (Boss)
            target = workspace.NPCs:FindFirstChild("Vera")
            
            -- Priority 2: Key (Khi bị còng)
            if not target then target = workspace.Effects:FindFirstChild("Key") end
            
            -- Priority 3: Chest (Rương số hoặc Chest)
            if not target then
                for _, v in pairs(workspace:GetDescendants()) do
                    if (tonumber(v.Name) or v.Name:match("Chest")) and v:FindFirstChildOfClass("ProximityPrompt", true) then
                        target = v break
                    end
                end
            end
            
            -- Priority 4: Bomb
            if not target then target = workspace.Effects:FindFirstChild("Bomb") end
            
            -- Priority 5: ImpelGuard
            if not target then
                local minD = math.huge
                for _, v in pairs(workspace.NPCs:GetChildren()) do
                    if v.Name == "ImpelGuard" then
                        local d = (root.Position - v:GetPivot().Position).Magnitude
                        if d < minD then minD = d target = v end
                    end
                end
            end

            -- THỰC THI DI CHUYỂN
            if target then
                print(">> Đang nhắm tới: " .. target.Name)
                ElevatorMove(target, 5)
                task.wait(1)
            end
        end
    end
end)