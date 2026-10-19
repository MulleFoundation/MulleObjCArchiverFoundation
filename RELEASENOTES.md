## 0.23.0











feature: improve CMake package integration for library consumers

* `add_subdirectory` consumers now inherit the source include directory and transitive dependency link libraries
* `find_package()` exports namespaced targets with a config file that resolves dependencies by name via `find_dependency()`
* force-link (whole-archive) requirement is propagated to consumers through an INTERFACE wrapper, so atinit/atexit constructors survive in static linking
* Windows executables embed a UTF-8 activeCodePage manifest so argv and the environment arrive as UTF-8
* rename dependency mulle-objc-list to mulle-objc-tools (clib.json and sourcetree config)


### 0.22.6



* fix signed seek offset so table offsets at end-of-buffer are read correctly with ``MULLE_BUFFER_SEEK_END``
* make blob hash/compare/describe callbacks const-correct and add matching describe cast

### 0.22.5

Various small improvements
