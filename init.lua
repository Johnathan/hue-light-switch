require 'StatusLight'

-- Timer ID's
statusLightTimerId = 1

local statusLed = StatusLight:new({
  timerId = statusLightTimerId,
  redPin = 3,
  greenPin = 2,
  bluePin = 1
})
