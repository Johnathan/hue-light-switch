StatusLight = {
    timerId = nil,
    redPin = nil,
    greenPin = nil,
    bluePin = nil
}

function StatusLight:new(pins)

    pins = pins or {}

    setmetatable(pins, self)
    self.__index = self

    -- Set all outputs to LOW to turn them off
    gpio.write(pins.redPin, gpio.LOW)
    gpio.write(pins.greenPin, gpio.LOW)
    gpio.write(pins.bluePin, gpio.LOW)

    return pins
end

function StatusLight:flash(pin, flashInterval)
    self:stopFlash()

    local value = true

    tmr.alarm(self.timerId, flashInterval, 1, function()
        gpio.write(pin, value and gpio.LOW or gpio.HIGH)
        value = not value
    end)
end

function StatusLight:stopFlash()
    self:turnOff()
    tmr.stop(self.timerId)
end

function StatusLight:turnOn(pin)
    gpio.write(pin, gpio.HIGH)
end

function StatusLight:turnOff()
    gpio.write(self.redPin, gpio.LOW)
    gpio.write(self.greenPin, gpio.LOW)
    gpio.write(self.bluePin, gpio.LOW)
end

-- Helpers
function StatusLight:flashRed(flashInterval)
    self:flash(self.redPin, flashInterval)
end

function StatusLight:flashGreen(flashInterval)
    self:flash(self.greenPin, flashInterval)
end

function StatusLight:flashBlue(flashInterval)
    self:flash(self.bluePin, flashInterval)
end

function StatusLight:turnOnRed()
    self:turnOn(self.redPin)
end

function StatusLight:turnOnGreen()
    self:turnOn(self.greenPin)
end

function StatusLight:turnOnBlue()
    self:turnOn(self.bluePin)
end
