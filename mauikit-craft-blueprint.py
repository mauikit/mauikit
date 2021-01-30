import info


class subinfo(info.infoclass):
    def setTargets(self):
        self.svnTargets["master"] = "[git]https://invent.kde.org/maui/mauikit.git|master"

    def setDependencies(self):
        self.buildDependencies["virtual/base"] = None
        self.buildDependencies["kde/frameworks/extra-cmake-modules"] = None
        self.runtimeDependencies["libs/qt5/qtbase"] = None
        self.runtimeDependencies["libs/qt5/qtgraphicaleffects"] = None
        self.runtimeDependencies["libs/qt5/qtquickcontrols2"] = None


from Package.CMakePackageBase import *


class Package(CMakePackageBase):
    def __init__(self):
        CMakePackageBase.__init__(self)
