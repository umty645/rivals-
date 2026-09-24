-- File: RobloxNetworkModule.lua
-- Description: 복원 및 정제된 네트워크/세션 관리 루아 모듈

local WebSocketClient = {}
local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local NetworkModule = {}

-- 1. UserGameSettings를 이용한 세션 토큰 은닉 저장 및 읽기
function NetworkModule.getOrGenerateSessionToken()
    local keyPrefix = "nil  nil  "
    local charset = "qwertyuiopasdfghjklzxcvbnm098765"
    local token = ""

    if UserGameSettings:GetTutorialState(keyPrefix) then
        local bitIndex = 0
        for i = 1, 16 do
            local charVal = 0
            local bitWeight = 1
            for j = 1, 5 do
                local bitSet = UserGameSettings:GetTutorialState(keyPrefix .. bitIndex) and 1 or 0
                charVal = charVal + (bitSet * bitWeight)
                bitWeight = bitWeight * 2
                bitIndex = bitIndex + 1
            end
            token = token .. charset:sub(charVal + 1, charVal + 1)
        end
    else
        UserGameSettings:SetTutorialState(keyPrefix, true)
        
        local bitIndex = 0
        for i = 1, 16 do
            local charVal = 0
            local bitWeight = 1
            for j = 1, 5 do
                local isSet = math.random(10, 20) > 15
                UserGameSettings:SetTutorialState(keyPrefix .. bitIndex, isSet)
                charVal = charVal + ((isSet and 1 or 0) * bitWeight)
                bitWeight = bitWeight * 2
                bitIndex = bitIndex + 1
            end
            token = token .. charset:sub(charVal + 1, charVal + 1)
        end
    end
    return token
end

-- 2. 서버 연결 및 타임아웃 관리 (Heartbeat / Ping Loop)
function NetworkModule.startNetworkHandler(sessionData)
    sessionData.LastActivity = tick()

    local function onMessage(payload)
        if payload == "PING" then
            sessionData.LastPing = tick()
            return
        end

        local signalId = string.match(payload, "^(%d+):")
        if not signalId then
            return sessionData.DefaultEvent:Fire(payload)
        end

        local targetSignal = sessionData.Signals[tonumber(signalId)]
        if targetSignal then
            targetSignal:Fire(payload:gsub("^[0-9]+:", ""))
            targetSignal:Destroy()
        end
    end

    task.spawn(function()
        sessionData.PingTimestamp = tick()
        while task.wait(10) do
            if sessionData.IsConnected then
                local socket = sessionData.Socket
                socket:Send({
                    type = "keepalive",
                    payload = {}
                })

                -- 20초 이상 응답 미수신 시 연결 강제 종료
                if tick() - sessionData.LastPing > 20 then
                    warn("Connection timed out.")
                    sessionData.Socket:Close()
                    break
                end
            end
        end
    end)
end

-- 3. 국가/지역 검증 모듈
function NetworkModule.checkPlayerRegion()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return nil end

    local countryCode = LocalizationService:GetCountryRegionForPlayerAsync(localPlayer)

    if countryCode == "KR" then
        local seedTable = table.create(5)
        return seedTable[math.random(1, 5)]
    end
    return nil
end

-- 4. 바이트 배열 기반 IEEE 754 Double 부동소수점 디코더
function NetworkModule.unpackDouble(bytes)
    local lowInt = bytes[1]
    local highInt = bytes[2]
    
    local mantissa = (highInt % 2^20) * 2^32 + lowInt
    local exponent = math.floor(highInt / 2^20) % 2^11
    local sign = (-1) ^ math.floor(highInt / 2^31)

    if exponent == 0 then
        if mantissa == 0 then return sign * 0 end
        exponent = 1
    elseif exponent == 2047 then
        return mantissa == 0 and (sign * math.huge) or (sign * (0 / 0))
    end

    return sign * (2 ^ (exponent - 1023)) * (1 + mantissa / 4503599627370496)
end

return NetworkModule
