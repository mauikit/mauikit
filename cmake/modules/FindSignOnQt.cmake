# - Try to find SignOnQt
# Once done this will define
#  SIGNONQT_FOUND - System has libsignon-qt
#  SIGNONQT_INCLUDE_DIRS - The libsignon-qt include directories
#  SIGNONQT_LIBRARIES - The libraries needed to use libsignon-qt

find_path(SIGNONQT_INCLUDE_DIR SignOn/AuthService PATH_SUFFIXES signon-qt )

find_library(SIGNONQT_LIBRARY NAMES signon-qt libsignon-qt)

set(SIGNONQT_LIBRARIES ${SIGNONQT_LIBRARY} )
set(SIGNONQT_INCLUDE_DIRS ${SIGNONQT_INCLUDE_DIR} )

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set  SIGNONQT_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(signonqt  DEFAULT_MSG
                                  SIGNONQT_LIBRARY SIGNONQT_INCLUDE_DIR)

mark_as_advanced(SIGNONQT_INCLUDE_DIR SIGNONQT_LIBRARY )
