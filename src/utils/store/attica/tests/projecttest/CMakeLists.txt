include(ECMMarkAsTest)

find_package(Qt5Widgets ${REQUIRED_QT_VERSION} CONFIG REQUIRED)
set_package_properties(Qt5Widgets PROPERTIES PURPOSE "Required for tests")

set(editproject_UI editproject.ui)
qt5_wrap_ui(editproject_UI_H ${editproject_UI})

set(projecttest_SRCS
    projecttest.cpp
    main.cpp
)

add_executable(projecttest ${projecttest_SRCS} ${editproject_UI_H})
ecm_mark_as_test(projecttest)

target_link_libraries(projecttest Qt5::Widgets KF5::Attica)
