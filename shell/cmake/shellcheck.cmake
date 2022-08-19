# Find the shellcheck program first
find_program(SHELLCHECK_EXECUTABLE shellcheck)
string(COMPARE EQUAL "${SHELLCHECK_EXECUTABLE}" "SHELLCHECK_EXECUTABLE-NOTFOUND" SHELLCHECK_NOTFOUND)
if(SHELLCHECK_NOTFOUND)
  message(NOTICE "*** Shellcheck targets cannot be created because the program is not installed! ***")
endif()


# Internal macro for setting shellcheck target for optional shell
macro(_shellcheck_target target_suffix shell files)
  # Target exists, ignore the call
  if (TARGET shellcheck${target_suffix})
    message(WARNING "Target shellcheck${target_suffix} already exists! These files are NOT going to be added to the target: ${files}")
    return()
  endif()
  # Custom target that depends on the files
  add_custom_target(shellcheck${target_suffix}
    DEPENDS ${files}
    )
  # Set the shellcheck shell option, if shell is given
  set(command_options)
  string(COMPARE EQUAL "${shell}" "" result)
  if(NOT result)
    set(command_options "--shell=${shell}")
  endif()
  # Set the target command
  add_custom_command(TARGET shellcheck${target_suffix}
    COMMAND ${SHELLCHECK_EXECUTABLE} ARGS "--external-sources" "${command_options}" ${files}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endmacro()

# Function to setting up targets to run shellcheck on files
function(shellcheck files)
  # Add targets only if it is possible
  if(NOT SHELLCHECK_NOTFOUND)
    # Parse the optional arguments
    set(optional_arguments ${ARGN})
    list(LENGTH optional_arguments optional_arguments_length)
    # Set a bunch of variables
    set(shellcheck_runner_target)
    set(custom_target)
    set(shell)
    # Called with 2 optional arguments, the shell and the custom target
    if(${optional_arguments_length} GREATER 1)
      list(GET optional_arguments 1 custom_target)
      list(GET optional_arguments 0 shell)
      set(shellcheck_runner_target "-${custom_target}-${shell}")
    # Called with 1 optional argument, the shell
    elseif(${optional_arguments_length} GREATER 0)
      list(GET optional_arguments 0 shell)
      set(shellcheck_runner_target "-${shell}")    
    endif()
    # Create the target
    _shellcheck_target("${shellcheck_runner_target}" "${shell}" ${files})
    # Add the custom shell-specific target as a dependency to the generic shell-specific target
    if(${optional_arguments_length} GREATER 1)
      # Shell target exists, add the custom target as a dependency
      if (TARGET shellcheck-${shell})
        add_dependencies(shellcheck-${shell} shellcheck-${custom_target}-${shell})
      # Otherwise, just create the shell-specific target and add the custom target as its dependency
      else()
        add_custom_target(shellcheck-${shell}
          DEPENDS shellcheck-${custom_target}-${shell}
          )
      endif()
    endif()
    # Add the shell-specific target as a dependency to the generic shellcheck target
    if(${optional_arguments_length} GREATER 0)
      # Generic target exists, add the shell-specific target as a dependency
      if (TARGET shellcheck)
        add_dependencies(shellcheck shellcheck-${shell})
      # Otherwise, just create the generic target and add the shell-specific target as its dependency
      else()
        add_custom_target(shellcheck
          DEPENDS shellcheck-${shell}
          )
      endif()
    endif()
  endif()
endfunction()
