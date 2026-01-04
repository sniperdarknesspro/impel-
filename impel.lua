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

-- ==========================================================
-- PHẦN 1: ANTI-CHEAT BYPASS (Trích xuất từ natalie wood.txt)
-- ==========================================================

-- 1. Xóa hệ thống quản trị (Adonis) và các script check ClientMover
task.spawn(function()
    pcall(function()
        -- Quét trong game
        for _, v in ipairs(game:GetDescendants()) do
            if v.Name:lower():match("adonis") or v.Name == "__FUNCTION" or v.Name:match("ClientMover") then
                v:Destroy()
            end
        end
        
        -- Quét các instance ẩn (nil instances)
        if getnilinstances then
            for _, v in ipairs(getnilinstances()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v.Name:match("ClientMover") or v.Name == "__FUNCTION" then
                    v:Destroy()
                end
            end
        end
    end)
end)

-- 2. Hook RemoteEvent để chặn gửi thông tin về Server (Mode == "Get")
task.spawn(function()
    pcall(function()
        local originalFireServer
        -- Lưu ý: Cần executor hỗ trợ hookfunction và newcclosure
        originalFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
            local args = {...}
            -- Nếu server yêu cầu lấy thông tin ("Get"), chặn lại
            if typeof(args[1]) == "table" and args[1].Mode == "Get" then
                return nil 
            end
            return originalFireServer(self, ...)
        end))
    end)
end)

-- 3. Actor Bypass ("Paul Greyrat") - Vô hiệu hóa báo lỗi (Error Logging)
-- Đoạn này yêu cầu executor hỗ trợ run_on_actor
task.spawn(function()
    pcall(function()
        local rf = game:GetService("ReplicatedFirst")
        local actor = rf:WaitForChild("paul greyrat", 3) -- Chờ tối đa 3s
        
        if actor and run_on_actor then
            run_on_actor(actor, [[
                local Context = game:GetService('ScriptContext')
                -- Tìm các kết nối vào sự kiện lỗi và vô hiệu hóa chúng
                for i,v in next, getconnections(Context.Error) do 
                    if v.Function and debug.getinfo(v.Function).nups > 1 then 
                        hookfunction(v.Function, function() end)
                    end
                end
            ]])
        end
    end)
end)

wait(1) -- Đợi 1 chút để các bypass kịp xử lý

-- ==========================================================
-- PHẦN 2: SCRIPT CỦA BẠN
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- Thông báo đã bypass xong
print("Đã thực hiện bypass anti-cheat.")

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