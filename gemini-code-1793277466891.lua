-- ========================================================
-- CẤU HÌNH KEY VÀ SCRIPT
-- ========================================================
local MY_KEY = "phungminhhoa" -- Key do bạn tự quy định
local Directory = "https://raw.githubusercontent.com/flazhy/QuantumOnyx/refs/heads/main/Games"

local Scripts = {
    [994732206]  = Directory .. "/BloxFruits.lua",   -- Blox Fruits
    [9186719164] = Directory .. "/SailorPiece.lua",  -- Sailor Piece
    [8191429227] = Directory .. "/CutTrees.lua",     -- Cut Trees
}

local GameId = game.GameId
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

-- Hàm thông báo
local function SendNotification(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3
        })
    end)
end

-- Hàm nạp script chính
local function LoadMainScript()
    local url = Scripts[GameId]
    if url then
        SendNotification("Quantum Hub", "Đang nạp script chính...")
        pcall(function()
            loadstring(game:HttpGet(url))()
        end)
    else
        SendNotification("Lỗi", "Không tìm thấy script tương thích với Game ID này!")
    end
end

-- ========================================================
-- TẠO GIAO DIỆN UI CUSTOM
-- ========================================================
-- Xóa UI cũ nếu đang tồn tại
if CoreGui:FindFirstChild("CustomQuantumKeyUI") then
    CoreGui.CustomQuantumKeyUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomQuantumKeyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Bảng chính (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Background Ảnh / Pattern
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "BG"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "rbxassetid://6070349968" -- Ảnh nền mẫu dạng lưới mờ
BackgroundImage.ImageTransparency = 0.85
BackgroundImage.ScaleType = Enum.ScaleType.Tile
BackgroundImage.TileSize = UDim2.new(0, 100, 0, 100)
BackgroundImage.Parent = MainFrame

local BGCorner = Instance.new("UICorner")
BGCorner.CornerRadius = UDim.new(0, 10)
BGCorner.Parent = BackgroundImage

-- Tiêu đề (Header)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 45)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "QUANTUM HUB - KEY SYSTEM"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -20, 0, 20)
SubTitle.Position = UDim2.new(0, 10, 0, 45)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Vui lòng nhập key để tiếp tục truy cập"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 160)
SubTitle.TextSize = 12
SubTitle.Font = Enum.Font.Gotham
SubTitle.Parent = MainFrame

-- Khung nhập Key (TextBox)
local KeyInput = Instance.new("TextBox")
KeyInput.Name = "KeyInput"
KeyInput.Size = UDim2.new(0.85, 0, 0, 42)
KeyInput.Position = UDim2.new(0.075, 0, 0.38, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
KeyInput.PlaceholderText = "Nhập Key vào đây..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = KeyInput

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(45, 45, 55)
InputStroke.Thickness = 1
InputStroke.Parent = KeyInput

-- Nút Xác Nhận (Submit Button)
local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Name = "SubmitBtn"
SubmitBtn.Size = UDim2.new(0.85, 0, 0, 42)
SubmitBtn.Position = UDim2.new(0.075, 0, 0.62, 0)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 230)
SubmitBtn.Text = "XÁC NHẬN KEY"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 14
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = SubmitBtn

-- ========================================================
-- XỬ LÝ SỰ KIỆN
-- ========================================================
SubmitBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text

    if enteredKey == MY_KEY then
        -- Key đúng: Đổi màu nút thành xanh lá và ẩn UI
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
        SubmitBtn.Text = "KEY CHÍNH XÁC!"
        
        SendNotification("Thành công", "Xác thực thành công!")
        
        task.wait(1)
        
        -- Hiệu ứng biến mất
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(KeyInput, TweenInfo.new(0.4), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(SubmitBtn, TweenInfo.new(0.4), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(Title, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(SubTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        
        task.wait(0.5)
        ScreenGui:Destroy()
        
        -- Gọi thẳng script game
        LoadMainScript()
    else
        -- Key sai: Đổi màu nút thành đỏ báo lỗi
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        SubmitBtn.Text = "KEY KHÔNG HỢP LỆ!"
        InputStroke.Color = Color3.fromRGB(200, 50, 50)
        
        task.wait(1.5)
        
        -- Khôi phục trạng thái ban đầu
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 230)
        SubmitBtn.Text = "XÁC NHẬN KEY"
        InputStroke.Color = Color3.fromRGB(45, 45, 55)
    end
end)
