
fn opt_err_with_code() ?string {return error_with_code('hi',137)}
fn test_err_with_code(){
	v := opt_err_with_code() or {
		assert err == 'hi'
		assert errcode == 137
		return
	}
	assert false
	println(v) // suppress not used error
}

fn opt_err() ?string {return error('hi')}

fn test_err(){
	v := opt_err() or {
		assert err == 'hi'
		return
	}
	assert false
	println(v) // suppress not used error
}

fn err_call(ok bool) ?int {
	if !ok {
		return error('Not ok!')
	}
	return 42
}

fn ret_none() ?int {
	//return error('wtf') //none
	return none
}

fn test_option_for_base_type_without_variable() {
	val := err_call(true) or {
		panic(err)
	}
	assert val == 42
	println('hm')
	val2 := ret_none() or {
		println('yep')
		return
	}
	println('$val2 should have been `none`')
	assert false
	// This is invalid:
	//	x := 5 or {
	//		return
	//	}
}

fn test_if_opt() {
	if val := err_call(false) {
		assert val == 42
	}
	assert 1 == 1
	println('nice')
}

fn for_opt_default() ?string {
        return error('awww')
}

fn test_opt_default() {
	a := for_opt_default() or {
			// panic(err)
			'default'
	}
	assert a == 'default'
}

fn foo_ok() ?int {
	return 777
}	

fn test_q() {
	//assert foo_ok()? == true
}	
