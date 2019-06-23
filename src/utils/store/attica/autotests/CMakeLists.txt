include(ECMAddTests)

find_package(Qt5 ${REQUIRED_QT_VERSION} NO_MODULE REQUIRED Test)
set_package_properties(Qt5Test PROPERTIES PURPOSE "Required for autotests")

ecm_add_tests(
  configtest.cpp
  persontest.cpp
  providertest.cpp
  LINK_LIBRARIES Qt5::Test KF5::Attica
)
