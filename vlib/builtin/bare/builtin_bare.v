module builtin

pub fn isnil(p voidptr) bool {
	return p == 0
}

pub fn print(s string) {
	sys_write(1, s.str, u64(s.len))
}

pub fn println(s string) {
	print(s)
	sys_write(1, "\n".str, 1)
}

// replaces panic when -debug arg is passed
fn panic_debug(line_no int, file,  mod, fn_name, s string) {
	println('================ V panic ================')
	print('   module: ')
	println('mod')
	print(' function: ')
	print(fn_name)
	println('()')
	println('     file: ')
	println(file)
	//println('     line: ${line_no}')
	print('  message: ')
	println(s)
	println('=========================================')
	sys_exit(1)
}

pub fn panic(s string) {
	print('V panic: ')
	println(s)
	sys_exit(1)
}

pub fn eprintln(s string) {
	if isnil(s.str) {
		panic('eprintln(NIL)')
	}
	println(s)
}
