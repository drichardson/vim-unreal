" Vim wrappers for ue4cli.
" https://github.com/adamrehn/ue4cli

function s:check_ue4cli()
	if !executable('ue4')
		throw 'ue4cli not installed. Run: pip3 install ue4cli'
	endif
endfunction

function s:is_windows()
	return has('win32') || has('win64')
endfunction

" Run ue4 build using a quickfix window
" https://docs.adamrehn.com/ue4cli/descriptor-commands/build
function ue4#build()
	call s:check_ue4cli()
	call ue4#make('build')
endfunction

" Run ue4 using make to get a quickfix window.
function ue4#make(target)
	call s:check_ue4cli()
	setlocal makeprg=ue4
	execute 'make' a:target
endfunction

" Start ue4 run detached so that Vim doesn't block.
function ue4#run()
	call s:check_ue4cli()
	" https://docs.adamrehn.com/ue4cli/descriptor-commands/run
	!start ue4 run
endfunction

function ue4#root()
	call s:check_ue4cli()
endfunction

function ue4#generate_tags()
	call system('ue4 ctags update')
endfunction

function ue4#engine_tags()
	" ue4cli can print info before the command output, so grab the last line
	return system('ue4 ctags engine-path')->split()[-1]
endfunction

function ue4#set_tags()
	set tags=
	set tags=./tags
	set tags+=tags
	execute 'set tags+=' . ue4#engine_tags()
endfunction

function ue4#generate_and_use_tags()
	call ue4#generate_tags()
	call ue4#set_tags()
endfunction
