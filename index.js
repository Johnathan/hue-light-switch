'use strict';

console.log( 7 );

var Gpio = require('chip-gpio').Gpio,
    request = require( 'request' ),
    jsonfile = require( 'jsonfile' ),
    client = null,

    persist = 'persist.json',
    persistedData = jsonfile.readFileSync( persist ),
    brightness = 255;

// Setup th buttons and rotary encoder
var btn = new Gpio(7, 'in', 'both', {
      debounceTimeout: 500
    }),

    a = new Gpio(0, 'in', 'both',{
        debounceTimeout: 200
    }),

    b = new Gpio(1, 'in', 'both',{
      debounceTimeout: 200
    });

var apiBaseUrl,
    // Set default Values
    brightness = 255;

function setState( on, brightness )
{
  console.log( 'setState', {
    on, brightness
  });
  request.put( apiBaseUrl + persistedData.username + '/lights/4/state', {
    json: {
      on: on,
      bri: Math.ceil( brightness )
    }
  });
}

/*
*  Connect to the Bridge
*/

// Search for the Bridge
request( 'https://www.meethue.com/api/nupnp', function( error, response, body ){
  persistedData.ip = JSON.parse( body )[0].internalipaddress;
  jsonfile.writeFile( persist, persistedData );

  apiBaseUrl = 'http://' + persistedData.ip + '/api/';
  console.log( apiBaseUrl );

  // Do we need to create a user?
  if( typeof persistedData.username == 'undefined' || ! persistedData.username )
  {
    request.post( apiBaseUrl, {
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
  console.log( apiBaseUrl + persistedData.username + '/lights' );

  request( apiBaseUrl + persistedData.username + '/lights', function( error, response, body ){
  	body = JSON.parse( body );
  	var newState = ! body[4].state.on;

    setState( newState, brightness );

  });

});


var previousA, previousB;


function setBrightness()
{
	if( brightness >= 255 ) brightness = 255;
	if( brightness <= 1 ) brightness = 1;

	console.info( 'Setting brightness to ' + brightness );

  setState( true, brightness );
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
});


function exit() {
    btn.unexport();
    a.unexport();
    b.unexport();
    process.exit();
}

process.on('SIGINT', exit);
