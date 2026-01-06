-- [[ HÀM TÌM VÀ NHẶT CHÌA KHÓA - OPTIMIZED FOR CODEX ]] --



local function AutoPickKey()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    -- 1. Tìm chìa khóa trong thư mục Effects (Theo logic file natalie wood.txt)
    local key = workspace.Effects:FindFirstChild("Key") 
    if key then

        print("Đã tìm thấy chìa khóa tại: " .. tostring(key:GetPivot().Position))
        -- 2. Dịch chuyển đến vị trí chìa khóa
        character.HumanoidRootPart.CFrame = key:GetPivot()
        -- 3. Tương tác để nhặt (Sử dụng ProximityPrompt)
        -- Codex hỗ trợ hàm fireproximityprompt để nhặt ngay lập tức không cần chờ
        task.wait(0.1) -- Đợi 1 chút để đảm bảo nhân vật đã tới nơi
        local prompt = key:FindFirstChildWhichIsA("ProximityPrompt", true)

        if prompt then
            fireproximityprompt(prompt)
            print("Đã thực hiện lệnh nhặt chìa khóa!")
        else
            -- Nếu không có Prompt, thử phương pháp chạm (Touch)
            firetouchinterest(character.HumanoidRootPart, key:FindFirstChildWhichIsA("BasePart") or key, 0)
            firetouchinterest(character.HumanoidRootPart, key:FindFirstChildWhichIsA("BasePart") or key, 1)
        end
    else
        warn("Hiện không tìm thấy chìa khóa trong workspace.Effects")

    end
end

-- Chạy hàm
AutoPickKey()





-- [[ SCRIPT CHẠY 100% - KHÔNG LỖI END ]] --
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local lp = game.Players.LocalPlayer

local function Go()
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local target = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v:FindFirstChildOfClass("ProximityPrompt", true) then
            if v.Name:match("Chest") or tonumber(v.Name) then
                target = v
                break
            end
        end
    end

    if target then
        local isFly = true
        local nc = RS.Stepped:Connect(function()
            if not isFly then return end
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)

        local cf = target:GetPivot()
        local dist = (root.Position - cf.Position).Magnitude
        local tw = TS:Create(root, TweenInfo.new(dist/150, Enum.EasingStyle.Linear), {CFrame = cf})
        tw:Play()

        tw.Completed:Connect(function()
            isFly = false
            nc:Disconnect()
            task.wait(0.2)
            local pmp = target:FindFirstChildOfClass("ProximityPrompt", true)
            if pmp then fireproximityprompt(pmp) print("XONG!") end
        end)
    else
        warn("KHONG THAY RUONG!")
    end
end

Go()