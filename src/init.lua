require 'persistence'
http_server_request = require 'httpserver-request'
require 'StatusLight'


-- Helpers
function tprint(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        elseif type(v) == 'string' then
            print(formatting .. v)
        end
    end
end

-- Timer ID's
statusLightTimerId = 1
ipTimerId = 2
connectionSuccessTimerId = 3

local statusLed = StatusLight:new({
    timerId = statusLightTimerId,
    redPin = 3,
    greenPin = 2,
    bluePin = 1
})

ssid_set, ssid = read_setting("ssid")
pwd_set, pwd = read_setting("pwd")

function initialConnection()
    wifi.sta.sethostname("HAME-DEVICE")
    wifi.setmode(wifi.STATIONAP)

    -- Setup as Access Point
    wifi.ap.config({
        ssid = "Hame-Hue-Switch",
        pwd = "hamepassword",
        auth = wifi.OPEN
    })
    print(wifi.sta.gethostname())

    local srv = net.createServer(net.TCP)

    srv:listen(80, function(conn)
        conn:on("receive", function(sck, payload)
            -- print(payload)

            local response = "HTTP/1.0 200 OK\r\nContent-Type: application/json\r\n\r\n"


            local request = http_server_request(payload)
            print(payload)

            if (payload.match(payload, "GET /ping")) then
                response = response .. "{\"device\":\"Light Switch\"}"
                sck:send(response)
            end

            -- GET /access-points (returns json with a list of nearby access points)
            if (payload.match(payload, "GET /access%-points")) then
                -- Return a list of available access points
                wifi.sta.getap(function(ssids)
                    response = response .. "{\"ssids\":["
                    for ssid in pairs(ssids) do
                        response = response .. "\"" .. ssid .. "\""

                        if (next(ssids, ssid) ~= nil) then
                            response = response .. ","
                        end
                    end
                    response = response .. "]}"

                    sck:send(response)
                end)
            end

            -- POST /access-points (returns json with a list of nearby access points)
            if (payload.match(payload, "POST /access%-points")) then
                -- Return a list of available access points
                local ssid = request.uri["args"]["ssid"]
                local password = request.uri["args"]["password"]
                sck:send(response)

                save_setting("ssid", ssid)
                save_setting("pwd", password)

                connectToNetwork(ssid, password)
            end
        end)

        conn:on("sent", function(sck)
            sck:close()
        end)
    end)

    -- statusLed:flashBlue( 100 )
end

function getWifiStatus()
    local ip = wifi.sta.getip()

    if ip ~= nil then
        statusLed:stopFlash()
        statusLed:turnOnGreen()

        tmr.alarm(connectionSuccessTimerId, 3000, tmr.ALARM_SINGLE, function()
            statusLed:turnOff()
        end)


        print('Connected with WiFi. IP Address: ' .. ip)

        tmr.stop(ipTimerId)

        runSwitch()
    end
end

function connectToNetwork(ssid, pwd)
    statusLed:flashBlue(500)

    local STATUS_CHECK_INTERVAL = 1000
    local STATUS_CHECK_COUNTER = 0
    local STOP_AFTER_ATTEMPTS = 45


    --- Connect to the wifi network ---
    wifi.setmode(wifi.STATION)
    wifi.sta.config(ssid, pwd)
    wifi.sta.connect()

    --- Check WiFi Status before starting anything ---
    tmr.alarm(ipTimerId, STATUS_CHECK_INTERVAL, 1, function()

        getWifiStatus()
        tmr.delay(STATUS_CHECK_INTERVAL)

        --- Stop from getting into infinite loop ---
        local STATUS_CHECK_COUNTER = STATUS_CHECK_COUNTER + 1
        if STOP_AFTER_ATTEMPTS == STATUS_CHECK_COUNTER then
            tmr.stop(ipTimerId)
            statusLed:turnOnRed()
        end
    end)
end

function connectToHueBridge()
end

function runSwitch()
    print("More setup checks in here probably for initial connection to hue bridge")
end

if ssid_set and pwd_set then
    connectToNetwork(ssid, pwd)
else
    initialConnection()
end
