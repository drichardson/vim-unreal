command! Ue4Run call ue4#run()
command! Ue4Build call ue4#build()
command! -nargs=1 Ue4Make call ue4#make(<f-args>)
command! Ue4Tags call ue4#generate_and_use_tags()
