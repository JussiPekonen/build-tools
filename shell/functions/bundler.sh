#!/bin/sh

# Script bundle function
bundleScript() {
  __bundle_script_output="$1"
  __bundle_script_preface="$2"
  shift 2
  __bundle_script_input_files="$*"
  # Create script bundle
  echo "Bundling the script ${__bundle_script_output}..."
  test -f "${__bundle_script_output}" && rm -f "${__bundle_script_output}"
  # Add the preface if requested by the parameters
  test "${__bundle_script_preface}" != "" && echo "${__bundle_script_preface}" > "${__bundle_script_output}"
  for __bundle_script_file in ${__bundle_script_input_files}
  do
    test -f "${__bundle_script_output}" && grep -E -v -e "^#(!/|shellcheck source)" -e "^(\.|source) " "${__bundle_script_file}" >> "${__bundle_script_output}"
    test ! -f "${__bundle_script_output}" && cat "${__bundle_script_file}" >> "${__bundle_script_output}"
  done
  # Set the script executable
  echo "Setting the script ${__bundle_script_output} executable..."
  chmod +x "${__bundle_script_output}"
  unset __bundle_script_output __bundle_script_preface __bundle_script_input_files __bundle_script_file
}
