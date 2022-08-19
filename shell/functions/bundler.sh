#!/bin/sh

# Script bundle function
bundleScript() {
  output="$1"
  preface="$2"
  shift 2
  input_files="$*"
  # Create script bundle
  echo "Bundling the script ${output}..."
  test -f "${output}" && rm -f "${output}"
  # Add the preface if requested by the parameters
  test "${preface}" != "" && echo "${preface}" > "${output}"
  for file in ${input_files}
  do
    test -f "${output}" && grep -E -v -e "^#(!/|shellcheck source)" -e "^(\.|source) " "${file}" >> "${output}"
    test ! -f "${output}" && cat "${file}" >> "${output}"
  done
  # Set the script executable
  echo "Setting the script ${output} executable..."
  chmod 0555 "${output}"
  unset output preface input_files file
}
