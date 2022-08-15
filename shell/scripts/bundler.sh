#!/bin/sh

# Script bundle function
bundleScript() {
  output="$1"
  precheck="$2"
  shift 2
  input_files="$*"
  # Create script bundle
  echo "Bundling the script ${output}..."
  test -f "${output}" && rm -f "${output}"
  # Add the pre-check, if requested by the parameters
  test "${precheck}" != "" && echo "${precheck}" > "${output}"
  for file in ${input_files}
  do
    test -f "${output}" && grep -E -v -e "^#(!/|shellcheck source)" -e "^(\.|source) " "${file}" >> "${output}"
    test ! -f "${output}" && cat "${file}" >> "${output}"
  done
  # Set the script executable
  echo "Setting the script ${output} executable..."
  chmod 0555 "${output}"
  unset output precheck input_files file
}
