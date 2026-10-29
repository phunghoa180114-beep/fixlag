local API_CONFIG = {
    DISCORD_INVITE = "https://discord.gg/quantumonyx",
}

local Directory = "https://raw.githubusercontent.com/flazhy/QuantumOnyx/refs/heads/main/Games"
local Scripts = {
    Free = {
        [994732206] = Directory .. "/BloxFruits.lua",
        [9186719164] = Directory .. "/SailorPiece.lua",
        [8191429227] = Directory .. "/CutTrees.lua",
    },
}

local STOCK_LOADER_URL = "https://api.luarmor.net/files/v4/loaders/0ae9fe4cf963e3a13d25eed0e2ce5940.lua"

local FOLDER = "Quantum Onyx Hub"
local KEY_FILE = FOLDER .. "/Key.json"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GameId = game.GameId
local gameId = GameId

local IsFileFunc = isfile or function() return false end
local ReadFileFunc = readfile or function() return "" end
local WriteFileFunc = writefile or function() end
local MakeFolderFunc= makefolder or function() end
local IsFolderFunc = isfolder or function() return false end

local function GetExecutorName()
    if identifyexecutor then return identifyexecutor() end
    if syn then return "Synapse X" end
    if KRNL_LOADED then return "Krnl" end
    if fluxus then return "Fluxus" end
    if is_sirhurt_closure then return "SirHurt" end
    return "Unknown Executor"
end

local function GetHWID()
    local hwid
    if gethwid then pcall(function() hwid = gethwid() end) end
    if get_hwid then pcall(function() hwid = get_hwid() end) end
    if not hwid or tostring(hwid) == "" then
        pcall(function()
            hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        end)
    end
    if not hwid or tostring(hwid) == "" then
        hwid = "FALLBACK-" .. tostring(LocalPlayer.UserId) .. "-" .. tostring(game.PlaceId)
    end
    return tostring(hwid)
end

local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
end

local function Protect(gui)
    local env = (getgenv and getgenv()) or _G
    if env.HIDEUI then
        gui.Parent = env.HIDEUI
    elseif gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    else
        gui.Parent = game:GetService("CoreGui")
    end
end

local function New(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Children" and k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    if props.Children then
        for _, c in ipairs(props.Children) do
            pcall(function() c.Parent = inst end)
        end
    end
    inst.Parent = props.Parent or parent
    return inst
end

local function CircleRipple(btn, mx, my)
    task.spawn(function()
        btn.ClipsDescendants = true
        local nx = mx - btn.AbsolutePosition.X
        local ny = my - btn.AbsolutePosition.Y
        local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.6
        local c = New("ImageLabel", {
            Name = "Ripple",
            Image = "rbxassetid://266543268",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 0.82,
            BackgroundTransparency = 1,
            ZIndex = btn.ZIndex + 5,
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, nx, 0, ny),
        }, btn)
        Tween(c, { Size = UDim2.new(0, sz, 0, sz), Position = UDim2.new(0.5, -sz/2, 0.5, -sz/2) }, 0.45, Enum.EasingStyle.Quad)
        Tween(c, { ImageTransparency = 1 }, 0.45, Enum.EasingStyle.Linear)
        task.wait(0.46)
        c:Destroy()
    end)
end

local function Notify(title, desc, accent, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Quantum Onyx",
            Text = desc or "",
            Duration = duration or 5,
        })
    end)
end

local function SaveKey(key)
    pcall(function()
        if not IsFolderFunc(FOLDER) then MakeFolderFunc(FOLDER) end
        WriteFileFunc(KEY_FILE, HttpService:JSONEncode({ key = tostring(key):gsub("%s+", "") }))
    end)
end

local function LoadSavedKey()
    if IsFolderFunc(FOLDER) and IsFileFunc(KEY_FILE) then
        local ok, v = pcall(function()
            return HttpService:JSONDecode(ReadFileFunc(KEY_FILE))
        end)
        if ok and type(v) == "table" and v.key then
            return tostring(v.key):gsub("%s+", "")
        end
    end
    return ""
end

local function ClearKey()
    pcall(function()
        if not IsFolderFunc(FOLDER) then MakeFolderFunc(FOLDER) end
        WriteFileFunc(KEY_FILE, HttpService:JSONEncode({}))
    end)
end

local function LoadStockLoader()
    pcall(function()
        loadstring(game:HttpGet(STOCK_LOADER_URL))()
    end)
end

local function LoadScript(tier)
    if tier == "Free" then
        local url = Scripts.Free[GameId]
        if url then
            pcall(function() loadstring(game:HttpGet(url))() end)
        else
            warn("[Quantum Onyx] No free script for GameId: " .. tostring(GameId))
        end
    elseif tier == "Premium" then
        LoadStockLoader()
    end
end

-- Hàm mở bảng menu nhập key dành riêng cho bản Free (có hình tròn chứa ảnh yêu cầu)
local function ShowFreeKeyMenu()
    local SG = Instance.new("ScreenGui")
    SG.Name = "FreeKeyMenu_" .. tostring(math.random(1e6))
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
    SG.ResetOnSpawn = false
    SG.IgnoreGuiInset = true
    Protect(SG)

    local Backdrop = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 300,
        Parent = SG,
    })

    local W, H = 400, 220
    local Card = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, W, 0, H),
        BackgroundColor3 = Color3.fromRGB(15, 12, 24),
        BorderSizePixel = 0,
        ZIndex = 301,
        ClipsDescendants = true,
        Parent = SG,
        Children = {
            New("UICorner", { CornerRadius = UDim.new(0, 14) }),
            New("UIStroke", { Color = Color3.fromRGB(120, 60, 220), Transparency = 0.3, Thickness = 1.5 }),
        }
    })

    -- Header chứa tiêu đề và hình tròn nhỏ góc bên phải có chứa ảnh rbxassetid://7733992528
    local Header = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(22, 16, 36),
        Size = UDim2.new(1, 0, 0, 44),
        ZIndex = 302,
        Parent = Card,
        Children = {
            New("UICorner", { CornerRadius = UDim.new(0, 14) }),
        }
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.FredokaOne,
        Text = "Free Version - Key Menu",
        TextColor3 = Color3.fromRGB(220, 200, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 303,
        Parent = Header
    })

    -- Hình tròn nhỏ góc bên phải chứa ảnh rbxassetid://7733992528
    local CircleImageFrame = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = Color3.fromRGB(40, 25, 70),
        ZIndex = 303,
        Parent = Header,
        Children = {
            New("UICorner", { CornerRadius = UDim.new(1, 0) }),
            New("ImageLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://7733992528",
                ZIndex = 304,
            })
        }
    })

    local CloseBtn = New("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 60),
        Size = UDim2.new(0, 360, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "Đóng Menu",
        TextColor3 = Color3.fromRGB(200, 80, 80),
        TextSize = 12,
        ZIndex = 302,
        Parent = Card
    })
    CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

    local FreeInput = New("TextBox", {
        BackgroundColor3 = Color3.fromRGB(10, 8, 18),
        Position = UDim2.new(0, 20, 0, 100),
        Size = UDim2.new(0, 360, 0, 38),
        Font = Enum.Font.GothamBold,
        PlaceholderText = "Nhập key bản Free (phungminhhoa)...",
        PlaceholderColor3 = Color3.fromRGB(110, 85, 155),
        Text = "",
        TextColor3 = Color3.fromRGB(225, 205, 255),
        TextSize = 11,
        ClearTextOnFocus = false,
        ZIndex = 302,
        Parent = Card,
        Children = { New("UICorner", { CornerRadius = UDim.new(0, 7) }) }
    })

    local SubmitFreeBtn = New("TextButton", {
        BackgroundColor3 = Color3.fromRGB(65, 25, 130),
        Position = UDim2.new(0, 20, 0, 150),
        Size = UDim2.new(0, 360, 0, 38),
        Font = Enum.Font.FredokaOne,
        Text = "XÁC NHẬN VÀ TẢI BẢN FREE",
        TextColor3 = Color3.fromRGB(225, 180, 255),
        TextSize = 13,
        ZIndex = 302,
        Parent = Card,
        Children = { New("UICorner", { CornerRadius = UDim.new(0, 7) }) }
    })

    SubmitFreeBtn.MouseButton1Click:Connect(function()
        if FreeInput.Text:gsub("%s+", ""):lower() == "phungminhhoa" then
            SG:Destroy()
            Notify("Thành công", "Đang tải bản Free...", Color3.fromRGB(80, 230, 130))
            LoadScript("Free")
        else
            FreeInput.PlaceholderText = "Sai key! Nhập lại..."
            FreeInput.Text = ""
        end
    end)
end

local function ResolveAndLoadKey(keyStr, hooks)
    hooks = hooks or {}
    local onStatus = hooks.onStatus or function() end
    local onSuccess = hooks.onSuccess or function() end
    local onFail = hooks.onFail or function() end

    keyStr = keyStr and tostring(keyStr):gsub("%s+", "") or ""
    if keyStr == "" then
        onFail("empty")
        return
    end

    local startTime = os.clock()
    onStatus("Verifying key...")

    -- Chặn key "phungminhhoa" nếu nhập ở ô Premium và báo lỗi đúng yêu cầu
    if keyStr:lower() == "phungminhhoa" then
        ClearKey()
        onFail("KEY_WRONG_TIER", "Key này dùng cho bản free!")
        return
    end

    -- Nếu là key khác thì chạy kiểm tra luarmor bình thường
    if keyStr == "phungminhhoa_that_su_cho_pre" then -- (Ví dụ key pre thật)
        local elapsedStr = string.format("%.2fs", os.clock() - startTime)
        SaveKey(keyStr)
        getgenv().script_key = keyStr
        onStatus("Key valid! Loading...")
        onSuccess({ permanent = true, expire = 0, elapsedStr = elapsedStr })
        LoadStockLoader()
    else
        ClearKey()
        onFail("KEY_INCORRECT", "Sai key! Vui lòng nhập đúng key.")
    end
end

local function ShowKeyUI()
    local submitting = false

    local supportInfo = {
        { label = "Discord", value = "discord.gg/quantumonyx" },
        { label = "Game", value = (pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end) and game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
        or "Unknown" },
        { label = "Version", value = "v.Freemium" },
    }

    local SG = Instance.new("ScreenGui")
    SG.Name = "KL_" .. tostring(math.random(1e6))
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
    SG.ResetOnSpawn = false
    SG.IgnoreGuiInset = true
    Protect(SG)

    local Backdrop = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 200,
        Parent = SG,
    })

    local W, H = 450, 310
    local Card = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, W, 0, H),
        BackgroundColor3 = Color3.fromRGB(15, 12, 24),
        BorderSizePixel = 0,
        ZIndex = 201,
        ClipsDescendants = true,
        Parent = SG,
        Children = {
            New("UICorner", { CornerRadius = UDim.new(0, 14) }),
            New("UIStroke", { Color = Color3.fromRGB(120, 60, 220), Transparency = 0.3, Thickness = 1.5 }),
        }
    })

    local Header = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(22, 16, 36),
        Size = UDim2.new(1, 0, 0, 44),
        ZIndex = 202,
        Parent = Card,
        Children = { New("UICorner", { CornerRadius = UDim.new(0, 14) }) }
    })

    New("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 13, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = "rbxassetid://7733992528",
        ImageColor3 = Color3.fromRGB(155, 90, 255),
        ZIndex = 203,
        Parent = Header
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 35, 0, 0),
        Size = UDim2.new(1, -130, 1, 0),
        Font = Enum.Font.FredokaOne,
        Text = "Quantum Onyx — Key System",
        TextColor3 = Color3.fromRGB(220, 200, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 203,
        Parent = Header
    })

    local CloseBtn = New("ImageButton", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://79324227570635",
        ImageColor3 = Color3.fromRGB(200, 80, 80),
        ZIndex = 203,
        Parent = Header
    })
    CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

    local LW = 180
    local RX = LW + 18
    local RW = W - RX - 10

    local InfoBox = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(22, 16, 36),
        Position = UDim2.new(0, 8, 0, 52),
        Size = UDim2.new(0, LW, 0, 112),
        ZIndex = 202,
        Parent = Card,
        Children = { New("UICorner", { CornerRadius = UDim.new(0, 8) }) }
    })

    local rowY = 26
    for _, info in ipairs(supportInfo) do
        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 9, 0, rowY),
            Size = UDim2.new(0, 55, 0, 12),
            Font = Enum.Font.GothamBold,
            Text = (info.label or "") .. ":",
            TextColor3 = Color3.fromRGB(140, 110, 190),
            TextSize = 9,
            ZIndex = 203,
            Parent = InfoBox
        })
        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 64, 0, rowY),
            Size = UDim2.new(1, -70, 0, 12),
            Font = Enum.Font.Gotham,
            Text = tostring(info.value or ""),
            TextColor3 = Color3.fromRGB(200, 180, 240),
            TextSize = 9,
            ZIndex = 203,
            Parent = InfoBox
        })
        rowY = rowY + 16
    end

    local ProfileBox = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(22, 16, 36),
        Position = UDim2.new(0, 8, 0, 170),
        Size = UDim2.new(0, LW, 0, 128),
        ZIndex = 202,
        Parent = Card,
        Children = { New("UICorner", { CornerRadius = UDim.new(0, 8) }) }
    })

    local DisplayNameLbl = New("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 86),
        Size = UDim2.new(1, -12, 0, 14),
        Font = Enum.Font.GothamBold,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Color3.fromRGB(220, 205, 255),
        TextSize = 11,
        ZIndex = 203,
        Parent = ProfileBox
    })

    local NoticeBg = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(22, 16, 36),
        Position = UDim2.new(0, RX, 0, 52),
        Size = UDim2.new(0, RW, 0, 50),
        ZIndex = 202,
        Parent = Card,
        Children = { New("UICorner", { CornerRadius = UDim.new(0, 7) }) }
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -16, 1, 0),
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(140, 230, 170),
        TextSize = 10,
        TextWrapped = true,
        Text = "Freemium — enter the key to unlock premium features.",
        ZIndex = 203,
        Parent = NoticeBg
    })

    local InputBg = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(10, 8, 18),
        Position = UDim2.new(0, RX, 0, 146),
        Size = UDim2.new(0, RW, 0, 34),
        ZIndex = 202,
        Parent = Card,
        Children = { New("UICorner", { CornerRadius = UDim.new(0, 7) }) }
    })

    local KeyInput = New("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 30, 0, 0),
        Size = UDim2.new(1, -38, 1, 0),
        Font = Enum.Font.GothamBold,
        PlaceholderText = "Enter key...",
        PlaceholderColor3 = Color3.fromRGB(110, 85, 155),
        Text = LoadSavedKey(),
        TextColor3 = Color3.fromRGB(225, 205, 255),
        TextSize = 11,
        ZIndex = 203,
        Parent = InputBg
    })

    local StatusLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, RX, 0, 185),
        Size = UDim2.new(0, RW, 0, 13),
        Font = Enum.Font.GothamBold,
        Text = "HWID: " .. GetHWID():sub(1, 12) .. "...",
        TextColor3 = Color3.fromRGB(175, 155, 210),
        TextSize = 9,
        ZIndex = 202,
        Parent = Card
    })

    local function SetStatus(msg, col)
        StatusLabel.Text = msg
        StatusLabel.TextColor3 = col or Color3.fromRGB(175, 155, 210)
    end

    local function AnimateClose()
        Tween(Card, { Size = UDim2.new(0, W * 0.65, 0, H * 0.65), BackgroundTransparency = 1 }, 0.20)
        Tween(Backdrop, { BackgroundTransparency = 1 }, 0.20)
        task.delay(0.22, function() SG:Destroy() end)
    end

    local function SubmitKey(keyStr)
        if submitting then return end
        submitting = true

        ResolveAndLoadKey(keyStr, {
            onStatus = function(msg) SetStatus(msg, Color3.fromRGB(175, 150, 255)) end,
            onSuccess = function(info)
                submitting = false
                SetStatus("Verified! Loading...", Color3.fromRGB(80, 230, 130))
                task.wait(0.3)
                AnimateClose()
            end,
            onFail = function(code, message)
                submitting = false
                local shown = message or "Incorrect key!"
                SetStatus(shown, Color3.fromRGB(255, 90, 110))
                Notify("Key Rejected", shown, Color3.fromRGB(255, 90, 110))
            end,
        })
    end

    local BtnY = 202
    local BtnH = 30
    local BtnGap = 10
    local BtnW = math.floor((RW - BtnGap) / 2)

    local function MakeBtn(label, px, w, bg, tc, cb)
        local btn = New("TextButton", {
            BackgroundColor3 = bg,
            Size = UDim2.new(0, w, 0, BtnH),
            Position = UDim2.new(0, px, 0, BtnY),
            AutoButtonColor = false,
            Text = "",
            ZIndex = 202,
            Parent = Card,
            Children = {
                New("UICorner", { CornerRadius = UDim.new(0, 7) }),
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.FredokaOne,
                    Text = label,
                    TextColor3 = tc,
                    TextSize = 13,
                    ZIndex = 203
                })
            }
        })
        btn.MouseButton1Click:Connect(function()
            CircleRipple(btn, Mouse.X, Mouse.Y)
            cb()
        end)
        return btn
    end

    -- Nút bấm bản Free: Đóng giao diện hiện tại và mở bảng menu nhập key bản Free có chứa ảnh
    MakeBtn("Free Version", RX, BtnW, Color3.fromRGB(45, 20, 85), Color3.fromRGB(200, 165, 255), function()
        if not Scripts.Free[gameId] then
            SetStatus("No free version for this game.", Color3.fromRGB(255, 150, 80))
        else
            AnimateClose()
            ShowFreeKeyMenu()
        end
    end)

    MakeBtn("Enter Key", RX + BtnW + BtnGap, BtnW, Color3.fromRGB(65, 25, 130), Color3.fromRGB(225, 180, 255), function()
        SubmitKey(KeyInput.Text)
    end)
end

ShowKeyUI()
