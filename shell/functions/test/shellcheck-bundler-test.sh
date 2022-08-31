#!/bin/sh

. ../shellcheck-bundler.sh

oneTimeSetUp() {
  _SHELLCHECK_BUNDER_SCRIPT_OUTPUT_FILE="script-output"
  _SHELLCHECK_BUNDLER_OUTPUT_FILE="output"
  _SHELLCHECK_BUNDLER_TEST_FILE1="foo"
  cat > "${_SHELLCHECK_BUNDLER_TEST_FILE1}" << EOF
#!/bin/sh

echo "foo"
EOF
  _SHELLCHECK_BUNDLER_TEST_FILE2="bar"
  cat > "${_SHELLCHECK_BUNDLER_TEST_FILE2}" << EOF
#!/bin/sh

echo "bar"
EOF
  _SHELLCHECK_BUNDLER_BORKED_TEST_FILE="bork"
  cat > "${_SHELLCHECK_BUNDLER_BORKED_TEST_FILE}" << EOF
#!/bin/sh

\`echo "bork"\`
EOF
}

oneTimeTearDown() {
  rm -f "${_SHELLCHECK_BUNDLER_TEST_FILE1}" "${_SHELLCHECK_BUNDLER_TEST_FILE2}" "${_SHELLCHECK_BUNDLER_BORKED_TEST_FILE}"
  unset _SHELLCHECK_BUNDER_SCRIPT_OUTPUT_FILE _SHELLCHECK_BUNDLER_TEST_FILE1 _SHELLCHECK_BUNDLER_TEST_FILE2 _SHELLCHECK_BUNDLER_BORKED_TEST_FILE
}

tearDown() {
  rm -f "${_SHELLCHECK_BUNDER_SCRIPT_OUTPUT_FILE}" "${_SHELLCHECK_BUNDLER_OUTPUT_FILE}"
}

testShellcheckBundlerWithNoFilesGiven() {
  generateShellcheckRunner "${_SHELLCHECK_BUNDER_SCRIPT_OUTPUT_FILE}" > /dev/null
  ./"${_SHELLCHECK_BUNDER_SCRIPT_OUTPUT_FILE}" > "${_SHELLCHECK_BUNDLER_OUTPUT_FILE}"
  assertEquals "$?" "0"
  #shellcheck disable=SC2006
  _output=`cat "${_SHELLCHECK_BUNDLER_OUTPUT_FILE}"`
  assertEquals "${_output}" ""
  unset _output
}

testShellcheckBundlerWithOneFile() {
  generateShellcheckRunner "${_SHELLCHECK_BUNDER_SCRIPT_OUTPUT_FILE}" "${_SHELLCHECK_BUNDLER_TEST_FILE1}" > /dev/null
  ./"${_SHELLCHECK_BUNDER_SCRIPT_OUTPUT_FILE}" > "${_SHELLCHECK_BUNDLER_OUTPUT_FILE}"
  assertEquals "$?" "0"
  #shellcheck disable=SC2006
  _output=`cat "${_SHELLCHECK_BUNDLER_OUTPUT_FILE}"`
  assertEquals "${_output}" ""
  unset _output
}

testShellcheckBundlerWithMoreThanOneFile() {
  generateShellcheckRunner "${_SHELLCHECK_BUNDER_SCRIPT_OUTPUT_FILE}" "${_SHELLCHECK_BUNDLER_TEST_FILE1}" "${_SHELLCHECK_BUNDLER_TEST_FILE2}" > /dev/null
  ./"${_SHELLCHECK_BUNDER_SCRIPT_OUTPUT_FILE}" > "${_SHELLCHECK_BUNDLER_OUTPUT_FILE}"
  assertEquals "$?" "0"
  #shellcheck disable=SC2006
  _output=`cat "${_SHELLCHECK_BUNDLER_OUTPUT_FILE}"`
  assertEquals "${_output}" ""
  unset _output
}

testShellcheckBundlerWithBrokenFile() {
  generateShellcheckRunner "${_SHELLCHECK_BUNDER_SCRIPT_OUTPUT_FILE}" "${_SHELLCHECK_BUNDLER_BORKED_TEST_FILE}" > /dev/null
  ./"${_SHELLCHECK_BUNDER_SCRIPT_OUTPUT_FILE}" > "${_SHELLCHECK_BUNDLER_OUTPUT_FILE}"
  assertEquals "$?" "1"
  #shellcheck disable=SC2006
  _output=`cat "${_SHELLCHECK_BUNDLER_OUTPUT_FILE}"`
  assertNotEquals "${_output}" ""
  unset _output
}

#shellcheck disable=SC1091
test -z "${SHUNIT_VERSION:-}" && . shunit2