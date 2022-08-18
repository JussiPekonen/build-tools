# Try to find the shellcheck package first
find_package(Shellcheck QUIET)

# If shellcheck package is not found, try to find it ourselves
if(NOT SHELLCHECK_FOUND)
  # Use which, it is supported the most
  execute_process(COMMAND which ARGS shellcheck
    OUTPUT_VARIABLE SHELLCHECK_EXECUTABLE
    ERROR_QUIET)
  # Strip the newline from the end
  string(REGEX REPLACE "\n" "" SHELLCHECK_EXECUTABLE ${SHELLCHECK_EXECUTABLE})
  # Set the boolean flag depending on the executable path
  if (NOT EXISTS ${SHELLCHECK_EXECUTABLE})
    set(SHELLCHECK_FOUND FALSE)
  else()
    set(SHELLCHECK_FOUND TRUE)
  endif()
endif()

macro(_shellcheck_target target_suffix shell files)
  if (TARGET shellcheck${target_suffix})
    message(WARNING "Target shellcheck${target_suffix} already exists! These files are NOT going to be added to the target: ${files}")
    return()
  endif()
  add_custom_target(shellcheck${target_suffix}
    DEPENDS ${files}
    )
  set(command_options)
  string(COMPARE EQUAL "${shell}" "" result)
  if(NOT result)
    set(command_options "--shell=${shell}")
  endif()
  add_custom_command(TARGET shellcheck${target_suffix}
    COMMAND ${SHELLCHECK_EXECUTABLE} ARGS "--external-sources" "${command_options}" ${files}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endmacro()

# Function to setting up targets to run shellcheck on files
function(shellcheck files)
  # Add targets only if it is possible
  if(SHELLCHECK_FOUND)
    # Handle the optional arguments
    set(optional_arguments ${ARGN})
    list(LENGTH optional_arguments optional_arguments_length)
    set(shellcheck_runner_target)
    set(custom_target)
    set(shell)
    if(${optional_arguments_length} GREATER 1)
      list(GET optional_arguments 1 custom_target)
      list(GET optional_arguments 0 shell)
      set(shellcheck_runner_target "-${custom_target}-${shell}")
    elseif(${optional_arguments_length} GREATER 0)
      list(GET optional_arguments 0 shell)
      set(shellcheck_runner_target "-${shell}")    
    endif()
    _shellcheck_target("${shellcheck_runner_target}" "${shell}" ${files})
    if(${optional_arguments_length} GREATER 1)
      if (TARGET shellcheck-${shell})
        add_dependencies(shellcheck-${shell} shellcheck-${custom_target}-${shell})
      else()
        add_custom_target(shellcheck-${shell}
          DEPENDS shellcheck-${custom_target}-${shell}
          )
      endif()
    endif()
    if(${optional_arguments_length} GREATER 0)
      if (TARGET shellcheck)
        add_dependencies(shellcheck shellcheck-${shell})
      else()
        add_custom_target(shellcheck
          DEPENDS shellcheck-${shell}
          )
      endif()
    endif()
  endif()
endfunction()
