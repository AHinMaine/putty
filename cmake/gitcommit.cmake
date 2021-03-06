# Pure cmake script to write out cmake_commit.h

set(DEFAULT_COMMIT "unavailable")
set(commit "${DEFAULT_COMMIT}")

execute_process(
  COMMAND ${GIT_EXECUTABLE} -C ${TOPLEVEL_SOURCE_DIR}
    rev-parse --show-toplevel
  OUTPUT_VARIABLE git_worktree
  ERROR_VARIABLE stderr
  RESULT_VARIABLE status)
string(REGEX REPLACE "\n$" "" git_worktree "${git_worktree}")

if(status EQUAL 0)
  if(git_worktree STREQUAL TOPLEVEL_SOURCE_DIR)
    execute_process(
      COMMAND ${GIT_EXECUTABLE} -C ${TOPLEVEL_SOURCE_DIR}
        rev-parse HEAD
      OUTPUT_VARIABLE git_commit
      ERROR_VARIABLE stderr
      RESULT_VARIABLE status)
    if(status EQUAL 0)
      string(REGEX REPLACE "\n$" "" commit "${git_commit}")
    else()
      if(commit STREQUAL "unavailable")
        message("Unable to determine git commit: 'git rev-parse HEAD' returned status ${status} and error output:\n${stderr}\n")
      endif()
    endif()
  else()
    if(commit STREQUAL "unavailable")
      message("Unable to determine git commit: top-level source dir ${TOPLEVEL_SOURCE_DIR} is not the root of a repository")
    endif()
  endif()
else()
  if(commit STREQUAL "unavailable")
    message("Unable to determine git commit: 'git rev-parse --show-toplevel' returned status ${status} and error output:\n${stderr}\n")
  endif()
endif()

file(WRITE "${OUTPUT_FILE}" "\
/*
 * cmake_commit.h - string literal giving the source git commit, if known.
 *
 * Generated by cmake/gitcommit.cmake.
 */

const char commitid[] = \"${commit}\";
")
