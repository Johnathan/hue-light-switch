'use strict';
var Gpio = require('chip-gpio').Gpio;
var request = require( 'request' );
var jsonfile = require( 'jsonfile' );
var client = null;

var persist = 'persist.json';
var persistedData = jsonfile.readFileSync( persist );
var brightness = 254;

// Setup th buttons and rotary encoder
var btn = new Gpio(7, 'in', 'both', {
    debounceTimeout: 500
});

var a = new Gpio(0, 'in', 'both',{
    debounceTimeout: 200
});

var b = new Gpio(1, 'in', 'both',{
    debounceTimeout: 50
});

// Set default Values
var brightness = 255;

/*
*  Connect to the Bridge
*/

// Search for the Bridge
request( 'https://www.meethue.com/api/nupnp', function( error, response, body ){
  persistedData.ip = JSON.parse( body )[0].internalipaddress;
  jsonfile.writeFile( persist, persistedData );

  // Do we need to create a user?
  if( typeof persistedData.username == 'undefined' || ! persistedData.username )
  {
    request.post( 'http://' + persistedData.ip + '/api', {
      json: {
        devicetype: 'chip_hue_switch'
      }
    }, function( error, response, body ){
      persistedData.username = body[0].success.username;

      jsonfile.writeFile( persist, persistedData );
    });
  }
});

btn.watch(function (err, value) {
  console.log('press', value);
  console.log( persistedData.username );

  request( 'http://' + persistedData.ip + '/api/' + persistedData.username + '/lights', function( error, response, body ){
  	body = JSON.parse( body );
  	var newState = ! body[4].state.on;

  	request.put( 'http://' + persistedData.ip + '/api/' + persistedData.username + '/lights/4/state', {
  		json: {
	  		on: newState
  		}
  	});

  });

});


var previousA, previousB;


function setBrightness()
{
	if( brightness >= 255 ) brightness = 255;
	if( brightness <= 1 ) brightness = 1;
	
	console.info( 'Setting brightness to ' + brightness );
	
	request.put( 'http://' + persistedData.ip + '/api/' + persistedData.username + '/lights/4/state', {
  		json: {
	  		on: true,
	  		bri: brightness
  		}
  	}, function( error, response, body ){
  		console.log( response.statusCode );
  	});
}

a.watch(function (err, value) {
	var direction = '';
	var currentA = a.read();
	var currentB = b.read();
	
	if( previousA != currentA )
	{
		if( currentA != currentB )
		{
			direction = 'forward';
			brightness = brightness + 2.55;
		}
		else
		{
			direction = 'back';
			brightness = brightness - 2.55;
		}
	}

/*  	console.log({
		a: a.read(),
		b: b.read(),
		direction: direction,
		brightness: brightness
	}); */
	
	setBrightness( brightness );
});

b.watch(function (err, value) {
	var direction = '';
	var currentA = a.read();
	var currentB = b.read();
	
	if( previousB != currentB )
	{
		if( currentA == currentB )
		{
			direction = 'forward';
			brightness = brightness + 2.55;
		}
		else
		{
			direction = 'back';
			brightness = brightness - 2.55;
		}
	}
	
	setBrightness( brightness );

/* 	console.log({
		a: a.read(),
		b: b.read(),
		direction: direction,
		brightness: brightness
	}); */

});


function exit() {
    btn.unexport();
    a.unexport();
    b.unexport();
    process.exit();
}

process.on('SIGINT', exit);
