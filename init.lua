require 'persistence'
require 'StatusLight'

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

ssid_set, ssid = read_setting( "ssid" )
pwd_set, pwd = read_setting( "pwd" )

function initialConnection()
  wifi.setmode(wifi.SOFTAP)

	-- Setup as Access Point
	print(wifi.ap.config({
		ssid = "Hame-Hue-Switch",
    pwd = "hamepassword",
		auth = wifi.OPEN
	}))

  server = net.createServer(net.TCP, 30)

  if server then
    server:listen(80, function(conn)
      conn:on("receive",function(conn,payload)
        print(payload)
        conn:send("<h1> Hello, NodeMCU!!! </h1>")
      end)
    end)
  end

  -- statusLed:flashBlue( 100 )
end

function getWifiStatus()
 ip = wifi.sta.getip()

 if ip ~= nil then
   statusLed:stopFlash()
   statusLed:turnOnGreen()

   tmr.alarm( connectionSuccessTimerId, 3000, tmr.ALARM_SINGLE, function()
     statusLed:turnOff()
  end)


   print('Connected with WiFi. IP Add: ' .. ip)

   tmr.stop(ipTimerId)

   runSwitch()
 end
end

function connectToHueBridge()

end

function runSwitch()
 print ( "More setup checks in here probably for initial connection to hue bridge" )
end

if ssid_set and pwd_set then

	statusLed:flashBlue( 500 )

	STATUS_CHECK_INTERVAL = 1000
	STATUS_CHECK_COUNTER = 0
	STOP_AFTER_ATTEMPTS = 45


	--- Connect to the wifi network ---
	wifi.setmode(wifi.STATION)
	wifi.sta.config(ssid, pwd)
	wifi.sta.connect()

	--- Check WiFi Status before starting anything ---
	tmr.alarm(ipTimerId, STATUS_CHECK_INTERVAL, 1, function()

	 getWifiStatus()
	 tmr.delay(STATUS_CHECK_INTERVAL)

	 --- Stop from getting into infinite loop ---
	 STATUS_CHECK_COUNTER = STATUS_CHECK_COUNTER + 1
	 if STOP_AFTER_ATTEMPTS == STATUS_CHECK_COUNTER then
		 tmr.stop(ipTimerId)
		 statusLed:turnOnRed()
	 end
	end)

else
  initialConnection()
end
