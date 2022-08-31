# Script test files
set(script_test_files
  bundler-test.sh
  shellcheck-bundler-test.sh
  )

# Add shellcheck targets for the various shells
foreach(shell ${SHELLCHECK_VALID_SHELLS})
  shellcheck("${script_test_files}" ${shell} "test")
endforeach()

# Add shunit2 targets for the various shells
foreach(shell ${SHUNIT2_VALID_SHELLS})
  shunit2("${script_test_files}" ${shell})
endforeach()