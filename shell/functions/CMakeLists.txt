set(script_files
  bundler.sh
  )

foreach(shell dash bash ksh sh)
  shellcheck("${script_files}" ${shell})
endforeach()
