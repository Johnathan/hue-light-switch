'use strict';

var Gpio = require('chip-gpio').Gpio;

var brightness = 255;

var a = new Gpio(0, 'in', 'both',{
    debounceTimeout: 50
});

var b = new Gpio(1, 'in', 'both',{
    debounceTimeout: 100
});

var previousA, previousB;


function setBrightness( brightness )
{
	console.log( brightness );
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
			brightness++;
		}
		else
		{
			direction = 'back';
			brightness--;
		}
	}

	/* console.log({
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
			brightness++;
		}
		else
		{
			direction = 'back';
			brightness--;
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
    a.unexport();
    b.unexport();
    process.exit();
}

process.on('SIGINT', exit);
