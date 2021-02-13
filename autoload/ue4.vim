" Vim wrappers for ue4cli.
" https://github.com/adamrehn/ue4cli

function s:check_ue4cli()
	if !executable('ue4')
		throw 'ue4cli not installed. Run :Ue4Install'
	endif
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

	let saved = getcwd()
	execute 'cd' ue4#project_root()

	setlocal makeprg=ue4
	execute 'make' a:target

	execute 'cd' saved
endfunction

" Start ue4 run detached so that Vim doesn't block.
function ue4#run()
	call s:check_ue4cli()

	let saved = getcwd()
	execute 'cd' ue4#project_root()

	" https://docs.adamrehn.com/ue4cli/descriptor-commands/run
	!start ue4 run

	execute 'cd' saved
endfunction

" wrapper for system that sets the cwd to the location of the .uproject. Like
" system, this function blocks until command completes.
function ue4#system(cmd)
	let saved = getcwd()
	execute 'cd' ue4#project_root()
	let result = system(a:cmd)
	execute 'cd' saved
	return result
endfunction

function ue4#generate_tags()
	call ue4#system('ue4 ctags update')
endfunction

function ue4#engine_tags()
	return ue4#system('ue4 ctags engine-path')->split()[0]
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

" Run at top level since it needs to be done when executing a :source command.
let s:packagedir = expand('<sfile>:p:h:h')

function ue4#install()
	"
	" Build helptags
	"
	let docsdir = s:packagedir . '/doc'
	echom 'Building helptags for ' . docsdir
	execute ':helptags' docsdir

	"
	" Make sure pip is installed
	"
	let pip = 'pip3'
	if !executable(pip)
		let pip = 'pip'
	endif
	if !executable(pip)
		throw 'pip/pip3 not installed. Install Python3 and pip and try again.'
	endif
	echom 'Found ' . pip

	"
	" Use pip to install ue4cli
	"
	echom 'Installing ue4cli and ctags_ue4cli'
	call system(pip . ' install --upgrade ue4cli ctags_ue4cli')

	"
	" Check for ctags
	"
	echom 'Checking for ctags.exe...'
	if executable('ctags')
		echom 'ctags is installed'
	else
		echom 'ctags not installed'
		if has('win32') || has('win64')
			let url = 'https://github.com/universal-ctags/ctags-win32/releases'
			let choice = confirm('ctags not installed. Open ctags download page in browser?\n' . url, "Open\nCanel", 1)
			if choice == 1
				execute '!start' url
			endif
		else
			echo 'ctags not installed. Learn how to install here: https://github.com/universal-ctags/ctags'
		endif
	endif
endfunction

" Starting at start_path, seach for a filename matching pattern up the parent
" directories. Stop search after checking maxlevels parent directories.
function s:search_upward(start_path, pattern, maxlevels = 20)
	if isdirectory(a:start_path)
		let dir = a:start_path
	else
		let dir = fnamemodify(a:start_path, ':h')
	endif

	let lastdir = ''
	let levels=0

	while dir != lastdir
		let results = glob(dir . '/*.uproject', v:true, v:true)
		if !empty(results)
			return dir
		endif

		let lastdir=dir
		let dir=fnamemodify(dir, ':h')
		let levels=levels+1

		" Safety valve so we don't loop forever, in case of symbolic
		" link madness. Shouldn't happen, but just in case I'm wrong.
		if levels > 20
			echom 'Max upsearch search level ('.a:maxlevels.') reached.'
			return v:null
		endif
	endwhile

	return v:null
endfunction

" Return the project root, or raise an exception if not found.
function ue4#project_root()
	let dir = expand('%:p')
	if len(dir) == 0
		" no current filename, use working directory
		let dir = getcwd()
	endif

	let dir = s:search_upward(dir, '*.uproject')
	if dir == v:null
		throw '.uproject not found in any parent directory'
	endif
	return dir
endfunction

