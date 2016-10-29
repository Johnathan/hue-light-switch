var Gpio = require('chip-gpio').Gpio;

var led = new Gpio( 2, 'out' );

console.log( led.read() );
led.write( 1 );
console.log( led.read() );