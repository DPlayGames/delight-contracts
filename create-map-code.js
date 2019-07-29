require(process.env.UPPERCASE_PATH + '/LOAD.js');

INIT_OBJECTS();

let size = 500;

let chrs = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
let code = 'let mapCode = \'';
REPEAT(size, (i) => {
	REPEAT(size, (j) => {
		code += chrs.charAt(RANDOM(chrs.length));
	});
});
code += '\';'

WRITE_FILE({
	path : 'map.txt',
	content : code,
	isSync : true
});
