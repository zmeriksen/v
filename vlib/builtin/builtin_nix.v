// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

module builtin

fn print_backtrace_skipping_top_frames_msvc(skipframes int) bool {
	println('not implemented, see builtin_windows.v')
	return false
}

fn print_backtrace_skipping_top_frames_mingw(skipframes int) bool {
	println('not implemented, see builtin_windows.v')
	return false
}

fn print_backtrace_skipping_top_frames_nix(xskipframes int) bool {
	skipframes := xskipframes + 2
	$if mac { return print_backtrace_skipping_top_frames_mac(skipframes) }
	$if linux { return print_backtrace_skipping_top_frames_linux(skipframes) }
	return false
}

// the functions below are not called outside this file,
// so there is no need to have their twins in builtin_windows.v
fn print_backtrace_skipping_top_frames_mac(skipframes int) bool {
	$if mac {
	buffer := [100]byteptr
	nr_ptrs := C.backtrace(*voidptr(buffer), 100)
	C.backtrace_symbols_fd(*voidptr(&buffer[skipframes]), nr_ptrs-skipframes, 1)
	}
	return true
}

fn print_backtrace_skipping_top_frames_linux(skipframes int) bool {
	$if tinyc {
		println('TODO: print_backtrace_skipping_top_frames_linux $skipframes with tcc fails tests with "stack smashing detected" .')
		return false
	}
	$if !android {
		$if glibc {
		// backtrace is not available on Android.
		//if C.backtrace_symbols_fd != 0 {
			buffer := [100]byteptr
			nr_ptrs := C.backtrace(*voidptr(buffer), 100)
			nr_actual_frames := nr_ptrs-skipframes
			mut sframes := []string
			csymbols := *byteptr(C.backtrace_symbols(*voidptr(&buffer[skipframes]), nr_actual_frames))
			for i in 0..nr_actual_frames {  sframes << tos2(csymbols[i]) }
			for sframe in sframes {
				executable := sframe.all_before('(')
				addr := sframe.all_after('[').all_before(']')
				beforeaddr := sframe.all_before('[')
				cmd := 'addr2line -e $executable $addr'

				// taken from os, to avoid depending on the os module inside builtin.v
				f := C.popen(cmd.str, 'r')
				if isnil(f) {
					println(sframe) continue
				}
				buf := [1000]byte
				mut output := ''
				for C.fgets(voidptr(buf), 1000, f) != 0 {
					output += tos(buf, vstrlen(buf))
				}
				output = output.trim_space()+':'
				if 0 != int(C.pclose(f)) {
					println(sframe) continue
				}
				if output in ['??:0:','??:?:'] { output = '' }
				println( '${output:-46s} | ${addr:14s} | $beforeaddr')
			}
			//C.backtrace_symbols_fd(*voidptr(&buffer[skipframes]), nr_actual_frames, 1)
			return true
		}$else{
			C.printf('backtrace_symbols_fd is missing, so printing backtraces is not available.\n')
			C.printf('Some libc implementations like musl simply do not provide it.\n')
		}
	}
	return false
}
