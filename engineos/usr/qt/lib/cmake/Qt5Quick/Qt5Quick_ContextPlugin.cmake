
add_library(Qt5::ContextPlugin MODULE IMPORTED)

_populate_Quick_plugin_properties(ContextPlugin RELEASE "scenegraph/libcustomcontext.so")

list(APPEND Qt5Quick_PLUGINS Qt5::ContextPlugin)
