# Script files
set(script_files
  bundler.sh
  shellcheck-bundler.sh
  )

# Add shellcheck targets for the various shells
foreach(shell ${SHELLCHECK_VALID_SHELLS})
  shellcheck("${script_files}" ${shell})
endforeach()

add_subdirectory(test)
