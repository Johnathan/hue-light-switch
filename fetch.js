var fetch = require('node-fetch');

fetch( 'http://192.168.4.1/access-points', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
    },
    body: JSON.stringify( {
        ssid: 'testsside',
        password: 'testpassword',
        // ssid: this.state.selectedSsid,
        // password: this.state.password,
    } ),
} );
