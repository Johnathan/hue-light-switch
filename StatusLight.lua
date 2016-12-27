local inspect = require 'inspect'

StatusLight = {
  redPin = nil,
  greenPin = nil,
  bluePin = nil
}

function StatusLight:new( pins )

  pins = pins or {}

  setmetatable( pins, self )
  self.__index = self

  return pins
end

function StatusLight:flash( pin, flashInterval )
  self:stopFlash()
  
  print( "Flashing " .. pin )
end

function StatusLight:stopFlash()
  print( "Stop Flash" )
end

function StatusLight:flashRed( flashInterval )
  print( "Flashing Red" )
  self:flash( self.redPin, flashInterval )
end

function StatusLight:flashGreen( flashInterval )
  print( "Flashing Green" )
  self:flash( self.greenPin, flashInterval )
end

function StatusLight:flashBlue( flashInterval )
  print( "Flashing Blue" )
  self:flash( self.bluePin, flashInterval )
end
