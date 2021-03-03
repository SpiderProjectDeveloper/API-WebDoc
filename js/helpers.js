export function setCookie( cname, cvalue ) {
	if( !document || !window ) { 	// Not a browser?
		return;
	}
	document.cookie = `${cname}=${cvalue}; path=/`; // ''
}


export function deleteCookie( cname ) {
	if( !document || !window ) { 	// Not a browser?
		return;
	}
	document.cookie = 'cname=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/';
}


export function getCookie( cname, type='string' ) {
	if( !document || !window ) { 	// Not a browser?
		return null;
	}
	let name = cname + "=";
	let decodedCookie = decodeURIComponent(document.cookie);
	let ca = decodedCookie.split(';');
	for( let i = 0 ; i < ca.length ; i++ ) {
		let c = ca[i];
		while( c.charAt(0) == ' ' ) {
			c = c.substring(1);
		}
		if( c.indexOf(name) == 0 ) {
			let value = c.substring(name.length, c.length);
			if( type == 'string' ) {
				return value;
			}
			if( type == 'int' ) {
				let intValue = parseInt(value);
				if( !isNaN(intValue) ) {
					return intValue;
				}
			}
			if( type == 'float' ) {
				let floatValue = parseFloat(value);
				if( !isNaN(floatValue) ) {
					return floatValue;
				}
			}
			return null;
		}
	}
	return null;
}
