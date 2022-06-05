
add_library(Qt5::QEglFSMaliIntegrationPlugin MODULE IMPORTED)

_populate_Gui_plugin_properties(QEglFSMaliIntegrationPlugin RELEASE "egldeviceintegrations/libqeglfs-mali-integration.so")

list(APPEND Qt5Gui_PLUGINS Qt5::QEglFSMaliIntegrationPlugin)
