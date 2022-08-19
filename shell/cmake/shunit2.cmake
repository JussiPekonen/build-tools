# Find the shunit2 program first
find_program(SHUNIT2_EXECUTABLE shunit2)
string(COMPARE EQUAL "${SHUNIT2_EXECUTABLE}" "SHUNIT2_EXECUTABLE-NOTFOUND" SHUNIT2_NOTFOUND)
if(SHUNIT2_NOTFOUND)
  message(NOTICE "*** Shunit2 targets cannot be created because the program is not installed! ***")
endif()

# A list of valid shells for shunit2
set(SHUNIT2_VALID_SHELLS
  dash
  bash
  ksh
  sh
  #zsh -> Need to be investigated a bit still why this shell does not work with shunit2
  )

# Internal macro for setting shunit2 target for optional shell
macro(_shunit2_target target_suffix shell files)
  # Target exists, ignore the call
  if (TARGET shunit2${target_suffix})
    message(WARNING "Target shunit2${target_suffix} already exists! These files are NOT going to be added to the target: ${files}")
    return()
  endif()
  # Set the shunit2 shell option, if shell is given
  set(running_shell "${shell}")
  string(COMPARE EQUAL "${shell}" "" result)
  if(result)
    set(running_shell "sh")
  endif()
  # Custom target
  add_custom_target(shunit2${target_suffix})
  # Create custom targets for each test file
  foreach(file ${files})
    # Custom target that depends on the files
    add_custom_target(shunit2${target_suffix}-${file}
      DEPENDS ${file}
      )
    # Set the target command
    add_custom_command(TARGET shunit2${target_suffix}-${file}
      COMMAND ${running_shell} ARGS ${SHUNIT2_EXECUTABLE} ${file}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      )
    # Add dependency to the top-level target
    add_dependencies(shunit2${target_suffix}
      shunit2${target_suffix}-${file}
      )
  endforeach()
endmacro()

# Function to setting up targets to run shunit2 on files
function(shunit2 files)
  # Do not add targets if the file list is empty
  list(LENGTH files number_of_files)
  if (${number_of_files} EQUAL 0)
    return()
  endif()
  # Add targets only if it is possible
  if(NOT SHUNIT2_NOTFOUND)
    # Parse the optional arguments
    set(optional_arguments ${ARGN})
    list(LENGTH optional_arguments optional_arguments_length)
      # Set a bunch of variables
    set(shunit2_runner_target)
    set(custom_target)
    set(shell)
    # Called with 2 optional arguments, the shell and the custom target
    if(${optional_arguments_length} GREATER 1)
      list(GET optional_arguments 1 custom_target)
      list(GET optional_arguments 0 shell)
      set(shunit2_runner_target "-${custom_target}-${shell}")
    # Called with 1 optional argument, the shell
    elseif(${optional_arguments_length} GREATER 0)
      list(GET optional_arguments 0 shell)
      set(shunit2_runner_target "-${shell}")    
    endif()
    # Create the target
    _shunit2_target("${shunit2_runner_target}" "${shell}" "${files}")
    # Add the custom shell-specific target as a dependency to the generic shell-specific target
    if(${optional_arguments_length} GREATER 1)
      # Shell target exists, add the custom target as a dependency
      if (TARGET shunit2-${shell})
        add_dependencies(shunit2-${shell} shunit2-${custom_target}-${shell})
      # Otherwise, just create the shell-specific target and add the custom target as its dependency
      else()
        add_custom_target(shunit2-${shell}
          DEPENDS shunit2-${custom_target}-${shell}
          )
      endif()
    endif()
    # Add the shell-specific target as a dependency to the generic shunit2 target
    if(${optional_arguments_length} GREATER 0)
      # Generic target exists, add the shell-specific target as a dependency
      if (TARGET shunit2)
        add_dependencies(shunit2 shunit2-${shell})
      # Otherwise, just create the generic target and add the shell-specific target as its dependency
      else()
        add_custom_target(shunit2
          DEPENDS shunit2-${shell}
          )
      endif()
    endif()
  endif()
endfunction()