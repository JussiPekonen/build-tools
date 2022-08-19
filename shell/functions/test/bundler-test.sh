#!/bin/sh

. ../bundler.sh

oneTimeSetUp() {
  out_file="test_output_file"
  example_file_shebang="#!/bin/sh"
}

setUp() {
  # Prepare test files
  #shellcheck disable=SC2006
  example_file1=`mktemp foo.XXXXX` || fail "Could not create the temp file"
  cat > "${example_file1}" << EOF
${example_file_shebang}
echo "1"
EOF
  #shellcheck disable=SC2006
  example_file2=`mktemp bar.XXXXX` || fail "Could not create the temp file"
  cat > "${example_file2}" << EOF
${example_file_shebang}
echo "2"
EOF
  #shellcheck disable=SC2006
  example_file3=`mktemp bork.XXXXX` || fail "Could not create the temp file"
  cat > "${example_file3}" << EOF
${example_file_shebang}

##shellcheck source="foo"
. "${example_file2}"
echo "3"
EOF
}

setPreface() {
  test "$#" -eq 1 && test ! -f "$1" && preface="$1" && return 0
  #shellcheck disable=SC2006
  test "$#" -eq 1 && preface=`cat "$1"` && return 0
  preface=""
}

parseHeader() {
  #shellcheck disable=SC2006
  number_of_preface_lines=`echo "${preface}" | wc -l | tr -d "\t "`
  test "${number_of_preface_lines}" -eq 0 && number_of_preface_lines=1
  #shellcheck disable=SC2006
  header=`head -n "${number_of_preface_lines}" "${out_file}"`
}

validateNumberOfShebangs() {
  #shellcheck disable=SC2006
  number_of_shebangs=`grep -c "#!" "${out_file}"`
  assertEquals "There are more than one shebang in the output!" "1" "${number_of_shebangs}"
  unset number_of_shebangs
}

cleanUp() {
  unset preface number_of_preface_lines header
}

tearDown() {
  cleanUp
  rm -f "${out_file}" "${example_file1}" "${example_file2}" "${example_file3}"
  unset example_file1 example_file2 example_file3
}

oneTimeTearDown() {
  unset out_file example_file_shebang
}

testBundlerWithOneFileWithoutPreface() {
  # Preface
  setPreface

  # Execute
  bundleScript "${out_file}" "${preface}" "${example_file1}" > /dev/null

  # Check the contents
  #shellcheck disable=SC2006
  input_content=`cat "${example_file1}"`
  #shellcheck disable=SC2006
  output_content=`cat "${out_file}"`
  assertEquals "The output file is not the same as the input file!" "${input_content}" "${output_content}"
  
  # Check the preface
  parseHeader
  assertNotEquals "The top of the output file is the same as the empty preface!" "${preface}" "${header}"
  assertEquals "The top of the output file is not the correct shebang!" "${example_file_shebang}" "${header}"

  # Check the number of shebangs
  validateNumberOfShebangs

  # Clean-up
  unset input_content output_content
}

testBundlerWithOneFileWithSimplePreface() {
  # Preface
  setPreface "${example_file_shebang} -e"

  # Execute
  bundleScript "${out_file}" "${preface}" "${example_file1}" > /dev/null

  # Check the contents
  #shellcheck disable=SC2006
  input_content=`cat "${example_file1}"`
  #shellcheck disable=SC2006
  output_content=`cat "${out_file}"`
  assertNotEquals "The output file is the same as the input file!" "${input_content}" "${output_content}"

  # Check the preface
  parseHeader
  assertEquals "The top of the output file is not the same as the requested preface!" "${preface}" "${header}"
  assertNotEquals "The top of the output file is the original shebang!" "${example_file_shebang}" "${header}"

  # Check the number of shebangs
  validateNumberOfShebangs

  # Clean-up
  unset input_content output_content
}

testBundlerWithOneFileWithComplexPreface() {
  # Preface
  setPreface "${example_file1}"

  # Execute
  bundleScript "${out_file}" "${preface}" "${example_file2}" > /dev/null

  # Check the contents
  #shellcheck disable=SC2006
  input_content=`cat "${example_file2}"`
  #shellcheck disable=SC2006
  output_content=`cat "${out_file}"`
  assertNotEquals "The output file is the same as the input file!" "${input_content}" "${output_content}"

  # Check the preface
  parseHeader
  assertEquals "The top of the output file is not the same as the requested preface!" "${preface}" "${header}"

  # Check the number of shebangs
  validateNumberOfShebangs

  # Clean-up
  unset input_content output_content
}

testBundlerWithMoreThanOneFileWithoutPreface() {
  # Preface
  setPreface

  # Execute
  bundleScript "${out_file}" "${preface}" "${example_file1}" "${example_file2}" > /dev/null

  # Check the contents
  #shellcheck disable=SC2006
  input_content1=`cat "${example_file1}"`
  #shellcheck disable=SC2006
  input_content2=`cat "${example_file2}"`
  #shellcheck disable=SC2006
  output_content=`cat "${out_file}"`
  assertNotEquals "The output file is the same as the first input file!" "${input_content1}" "${output_content}"
  assertNotEquals "The output file is the same as the second input file!" "${input_content2}" "${output_content}"

  # Check the preface
  parseHeader
  assertNotEquals "The top of the output file is not the same as the requested preface!" "${preface}" "${header}"
  assertEquals "The top of the output file is the shebang!" "${example_file_shebang}" "${header}"

  # Check the number of shebangs
  validateNumberOfShebangs

  # Clean-up
  unset input_content1 input_content2 output_content
}

testBundlerWithMoreThanOneFileWithSimplePreface() {
    # Preface
  setPreface "${example_file_shebang} -e"

  # Execute
  bundleScript "${out_file}" "${preface}" "${example_file1}" "${example_file2}" > /dev/null

  # Check the contents
  #shellcheck disable=SC2006
  input_content1=`cat "${example_file1}"`
  #shellcheck disable=SC2006
  input_content2=`cat "${example_file2}"`
  #shellcheck disable=SC2006
  output_content=`cat "${out_file}"`
  assertNotEquals "The output file is the same as the first input file!" "${input_content1}" "${output_content}"
  assertNotEquals "The output file is the same as the second input file!" "${input_content2}" "${output_content}"

  # Check the preface
  parseHeader
  assertEquals "The top of the output file is not the same as the requested preface!" "${preface}" "${header}"
  assertNotEquals "The top of the output file is the original shebang!" "${example_file_shebang}" "${header}"

  # Check the number of shebangs
  validateNumberOfShebangs

  # Clean-up
  unset input_content1 input_content2 output_content
}

testBundlerWithMoreThanOneFileWithComplexPreface() {
    # Preface
  setPreface "${example_file3}"

  # Execute
  bundleScript "${out_file}" "${preface}" "${example_file1}" "${example_file2}" > /dev/null

  # Check the contents
  #shellcheck disable=SC2006
  input_content1=`cat "${example_file1}"`
  #shellcheck disable=SC2006
  input_content2=`cat "${example_file2}"`
  #shellcheck disable=SC2006
  output_content=`cat "${out_file}"`
  assertNotEquals "The output file is the same as the first input file!" "${input_content1}" "${output_content}"
  assertNotEquals "The output file is the same as the second input file!" "${input_content2}" "${output_content}"

  # Check the preface
  parseHeader
  assertEquals "The top of the output file is not the same as the requested preface!" "${preface}" "${header}"

  # Check the number of shebangs
  validateNumberOfShebangs

  # Clean-up
  unset input_content1 input_content2 output_content
}

#shellcheck disable=SC1091
test -z "${SHUNIT_VERSION:-}" && . shunit2