-- Project R7 HUB
-- Criado por: BruXo & Tabuada

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Project R7 HUB",
    Icon = 0,
    LoadingTitle = "Project R7 HUB",
    LoadingSubtitle = "by BruXo & Tabuada",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ProjectR7",
        FileName = "Config"
    },
    KeySystem = false,
})

-- =====================
-- VARIAVEIS GLOBAIS
-- =====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local AuraKillEnabled = false
local AuraDistance = 20
local AuraInterval = 1
local AuraMode = "Instant Kill"
local AuraDamage = 100
local AuraKillCount = 0
local AuraConnection = nil

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getEquippedTool()
    local char = getCharacter()
    if not char then return nil end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") then return v end
    end
    return nil
end

local function simulateAttack(npcHRP)
    local tool = getEquippedTool()
    local hrp = getHRP()
    if not hrp then return end

    -- Teleporta o personagem perto do NPC temporariamente pra tool registrar o hit
    local originalCFrame = hrp.CFrame

    if AuraMode == "Instant Kill" then
        -- Move até o NPC, dispara o Activated da tool e volta
        hrp.CFrame = npcHRP.CFrame * CFrame.new(0, 0, 2)
        if tool then
            tool:Activate()
        end
        task.wait(0.05)
        hrp.CFrame = originalCFrame
    elseif AuraMode == "Damage" then
        hrp.CFrame = npcHRP.CFrame * CFrame.new(0, 0, 2)
        if tool then
            -- Dispara multiplas vezes baseado no dano configurado
            local hits = math.ceil(AuraDamage / 10)
            for i = 1, hits do
                tool:Activate()
                task.wait(0.05)
            end
        end
        hrp.CFrame = originalCFrame
    end

    AuraKillCount = AuraKillCount + 1
end

local function startAuraKill()
    if AuraConnection then AuraConnection:Disconnect() end

    local lastTick = 0
    AuraConnection = RunService.Heartbeat:Connect(function()
        if not AuraKillEnabled then return end
        if tick() - lastTick < AuraInterval then return end
        lastTick = tick()

        local hrp = getHRP()
        if not hrp then return end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                local npcHRP = obj:FindFirstChild("HumanoidRootPart")
                local npcHum = obj:FindFirstChildOfClass("Humanoid")
                if npcHRP and npcHum and npcHum.Health > 0 then
                    local dist = (hrp.Position - npcHRP.Position).Magnitude
                    if dist <= AuraDistance then
                        task.spawn(function()
                            simulateAttack(npcHRP)
                        end)
                    end
                end
            end
        end
    end)
end

-- =====================
-- TAB: FARM KILL
-- =====================
local FarmTab = Window:CreateTab("⚔️ Farm Kill", 4483362458)

FarmTab:CreateSection("Aura Kill")

FarmTab:CreateToggle({
    Name = "Aura Kill",
    CurrentValue = false,
    Flag = "AuraKillToggle",
    Callback = function(val)
        AuraKillEnabled = val
        if val then
            startAuraKill()
        end
    end,
})

FarmTab:CreateSlider({
    Name = "Distância da Aura",
    Range = {5, 200},
    Increment = 5,
    Suffix = " studs",
    CurrentValue = 20,
    Flag = "AuraDistance",
    Callback = function(val)
        AuraDistance = val
    end,
})

FarmTab:CreateSlider({
    Name = "Intervalo de Ataque",
    Range = {1, 10},
    Increment = 1,
    Suffix = " seg",
    CurrentValue = 1,
    Flag = "AuraInterval",
    Callback = function(val)
        AuraInterval = val
    end,
})

FarmTab:CreateDropdown({
    Name = "Modo da Aura Kill",
    Options = {"Instant Kill", "Damage"},
    CurrentOption = {"Instant Kill"},
    Flag = "AuraMode",
    Callback = function(val)
        AuraMode = val[1]
    end,
})

FarmTab:CreateSlider({
    Name = "Dano por Hit",
    Range = {1, 999},
    Increment = 1,
    Suffix = " dmg",
    CurrentValue = 100,
    Flag = "AuraDamage",
    Callback = function(val)
        AuraDamage = val
    end,
})

FarmTab:CreateSection("Auto Farm")

local AutoFarmEnabled = false
local AutoFarmConnection = nil

FarmTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(val)
        AutoFarmEnabled = val
        if val then
            AuraKillEnabled = true
            startAuraKill()
        else
            AuraKillEnabled = false
        end
    end,
})

FarmTab:CreateDropdown({
    Name = "Alvo da Aura",
    Options = {"Todos os NPCs", "NPCs Próximos", "NPCs Específicos"},
    CurrentOption = {"Todos os NPCs"},
    Flag = "AuraTarget",
    Callback = function(val) end,
})

FarmTab:CreateButton({
    Name = "Resetar Contador de Kills",
    Callback = function()
        AuraKillCount = 0
        Rayfield:Notify({
            Title = "Contador Resetado",
            Content = "Kill count zerado!",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

FarmTab:CreateButton({
    Name = "Ver Kills",
    Callback = function()
        Rayfield:Notify({
            Title = "Kill Counter",
            Content = "NPCs mortos: " .. AuraKillCount,
            Duration = 4,
            Image = 4483362458,
        })
    end,
})

-- =====================
-- TAB: PLAYER
-- =====================
local PlayerTab = Window:CreateTab("🧍 Player", 4483362458)

PlayerTab:CreateSection("Movimento")

local speedEnabled = false
local speedValue = 16
local defaultSpeed = 16

PlayerTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(val)
        speedEnabled = val
        local char = getCharacter()
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = val and speedValue or defaultSpeed
            end
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Velocidade",
    Range = {16, 500},
    Increment = 1,
    Suffix = " speed",
    CurrentValue = 16,
    Flag = "SpeedValue",
    Callback = function(val)
        speedValue = val
        if speedEnabled then
            local char = getCharacter()
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = val end
            end
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(val)
        local uis = game:GetService("UserInputService")
        if val then
            uis.JumpRequest:Connect(function()
                local char = getCharacter()
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(11) end
                end
            end)
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 5,
    Suffix = " power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(val)
        local char = getCharacter()
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = val end
        end
    end,
})

PlayerTab:CreateSection("Fly")

local flyEnabled = false
local flySpeed = 50
local flyBodyVelocity = nil
local flyBodyGyro = nil

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(val)
        flyEnabled = val
        local char = getCharacter()
        local hrp = getHRP()
        if not hrp then return end

        if val then
            flyBodyGyro = Instance.new("BodyGyro", hrp)
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.P = 9e4

            flyBodyVelocity = Instance.new("BodyVelocity", hrp)
            flyBodyVelocity.Velocity = Vector3.zero
            flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

            local cam = workspace.CurrentCamera
            RunService.RenderStepped:Connect(function()
                if not flyEnabled then
                    if flyBodyVelocity then flyBodyVelocity:Destroy() end
                    if flyBodyGyro then flyBodyGyro:Destroy() end
                    return
                end
                local uis = game:GetService("UserInputService")
                local dir = Vector3.zero
                if uis:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
                flyBodyVelocity.Velocity = dir * flySpeed
                flyBodyGyro.CFrame = cam.CFrame
            end)
        else
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
            if flyBodyGyro then flyBodyGyro:Destroy() end
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Velocidade do Fly",
    Range = {10, 300},
    Increment = 5,
    Suffix = " speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(val)
        flySpeed = val
    end,
})

PlayerTab:CreateSection("Outros")

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(val)
        RunService.Stepped:Connect(function()
            if val then
                local char = getCharacter()
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end,
})

-- =====================
-- TAB: VISUALS
-- =====================
local VisualsTab = Window:CreateTab("👁️ Visuals", 4483362458)

VisualsTab:CreateSection("ESP")

local npcESPEnabled = false
local npcHighlights = {}

VisualsTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = false,
    Flag = "NpcESP",
    Callback = function(val)
        npcESPEnabled = val
        if not val then
            for _, h in pairs(npcHighlights) do h:Destroy() end
            npcHighlights = {}
            return
        end
        RunService.Heartbeat:Connect(function()
            if not npcESPEnabled then return end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 and not npcHighlights[obj] then
                        local h = Instance.new("Highlight", obj)
                        h.FillColor = Color3.fromRGB(255, 0, 0)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.5
                        npcHighlights[obj] = h
                    end
                end
            end
        end)
    end,
})

VisualsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(val)
        local playerHighlights = {}
        if not val then
            for _, h in pairs(playerHighlights) do h:Destroy() end
            return
        end
        RunService.Heartbeat:Connect(function()
            if not val then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and not playerHighlights[plr] then
                    local h = Instance.new("Highlight", plr.Character)
                    h.FillColor = Color3.fromRGB(0, 120, 255)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.FillTransparency = 0.5
                    playerHighlights[plr] = h
                end
            end
        end)
    end,
})

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(val)
        local lighting = game:GetService("Lighting")
        if val then
            lighting.Brightness = 10
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
        else
            lighting.Brightness = 1
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
            lighting.GlobalShadows = true
            lighting.Ambient = Color3.fromRGB(127, 127, 127)
        end
    end,
})

-- =====================
-- TAB: MISC
-- =====================
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

MiscTab:CreateSection("Utilidades")

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(val)
        if val then
            local vu = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end,
})

MiscTab:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Flag = "FPSBoost",
    Callback = function(val)
        local lighting = game:GetService("Lighting")
        if val then
            settings().Rendering.QualityLevel = 1
        else
            settings().Rendering.QualityLevel = 10
        end
    end,
})

MiscTab:CreateButton({
    Name = "Auto Rejoin",
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, LocalPlayer)
    end,
})

MiscTab:CreateButton({
    Name = "Limpar Workspace",
    Callback = function()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Part") and not obj.Anchored then
                obj:Destroy()
            end
        end
        Rayfield:Notify({
            Title = "Workspace Limpo",
            Content = "Parts soltas removidas!",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

-- =====================
-- TAB: CREDITS
-- =====================
local CreditsTab = Window:CreateTab("📜 Credits", 4483362458)

CreditsTab:CreateSection("Project R7 HUB")

CreditsTab:CreateLabel("🔥 Project R7 HUB")
CreditsTab:CreateLabel("👑 Criado por: BruXo & Tabuada")
CreditsTab:CreateLabel("⚔️ Versão: 1.0.0")
CreditsTab:CreateLabel("💀 Use com responsabilidade!")

CreditsTab:CreateSection("Contato")

CreditsTab:CreateLabel("Discord: BruXo#0000")
CreditsTab:CreateLabel("Discord: Tabuada#0000")

-- Init notify
Rayfield:Notify({
    Title = "Project R7 HUB",
    Content = "Carregado com sucesso! by BruXo & Tabuada",
    Duration = 5,
    Image = 4483362458,
})
