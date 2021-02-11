" Vim wrappers for ue4cli.
# https://github.com/adamrehn/ue4cli

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

function s:check_ue4cli()
	if !executable('ue4')
		throw 'ue4cli not installed. Run: pip3 install ue4cli'
	endif
endfunction

