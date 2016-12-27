require 'StatusLight'

local first = StatusLight:new({
  redPin = 1,
  greenPin = 2,
  bluePin = 3
})

local second = StatusLight:new({
  redPin = 4,
  greenPin = 5,
  bluePin = 6
})

first:flashRed( 100 )
