#!/bin/sh

generateShellcheckRunner() {
  _generate_shellcheck_script="$1"
  shift
  _generate_shellcheck_files="$*"
  echo "Generating shellcheck runner ${_generate_shellcheck_script}..."
  cat > "${_generate_shellcheck_script}" << EOF
#!/bin/sh

shellcheck --version > /dev/null
test "$?" -ne 0 && echo "Shellcheck not installed! Aborting." > /dev/stderr && exit 1

_current_dir=\`pwd\`
for _file in ${_generate_shellcheck_files}
do
  _dir=\`dirname "\${_file}"\`
  _filename=\`basename "\${_file}"\`
  cd "\${_dir}"
  for shell in bash dash ksh sh # Only these are supported by the shellcheck tool
  do
    shellcheck --external-sources --shell="\${shell}" "\${_filename}"
    test "\$?" -ne 0 && unset _current_dir _file _dir _filename && exit 1
  done
  cd "\${_current_dir}"
done
unset _current_dir _file _dir _filename
EOF
  echo "Setting the script ${_generate_shellcheck_script} executable..."
  chmod +x "${_generate_shellcheck_script}"
  unset _generate_shellcheck_script _generate_shellcheck_files
}