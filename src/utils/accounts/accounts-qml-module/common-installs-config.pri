#-----------------------------------------------------------------------------
# Common installation configuration for all projects.
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
# setup the installation prefix
#-----------------------------------------------------------------------------
INSTALL_PREFIX = /usr  # default installation prefix

# default prefix can be overriden by defining PREFIX when running qmake
isEmpty( PREFIX ) {
    message("====")
    message("==== NOTE: To override the installation path run: `qmake PREFIX=/custom/path'")
    message("==== (current installation path is `$${INSTALL_PREFIX}')")
} else {
    INSTALL_PREFIX = $${PREFIX}
    message("====")
    message("==== install prefix set to `$${INSTALL_PREFIX}'")
}


#-----------------------------------------------------------------------------
# default installation target for applications
#-----------------------------------------------------------------------------
contains( TEMPLATE, app ) {
    target.path  = $${INSTALL_PREFIX}/bin
    INSTALLS    += target
    message("====")
    message("==== INSTALLS += target")
}


#-----------------------------------------------------------------------------
# default installation target for libraries
#-----------------------------------------------------------------------------
contains( TEMPLATE, lib ) {

    target.path  = $${INSTALL_PREFIX}/lib
    INSTALLS    += target
    message("====")
    message("==== INSTALLS += target")

    # reset the .pc file's `prefix' variable
    #include( tools/fix-pc-prefix.pri )

}

#-----------------------------------------------------------------------------
# target for header files
#-----------------------------------------------------------------------------
!isEmpty( headers.files ) {
    headers.path  = $${INSTALL_PREFIX}/include/$${TARGET}
    INSTALLS     += headers
    message("====")
    message("==== INSTALLS += headers")
} else {
    message("====")
    message("==== NOTE: Remember to add your API headers into `headers.files' for installation!")
}


# End of File
