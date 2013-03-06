SQLite3
=======

**sqlite3 monkey wrapper**

Installation:

##Visual Studio 10:

1) Make the directory project.build/glfw/sqlite3

2) Put sqlite3.c and sqlite3.h in project.build/glfw/sqlite3/

3) Update the native project

  a) Add project.build/glfw/sqlite3/ to the native project
  
  b) Add project.build/glfw/sqlite3/ to the additional include directories
  
  c) Make sure that sqlite3.c is compiled as C code


##gcc/MinGW:

1) Make the directory project.build/glfw/sqlite3

2) Put sqlite3.c and sqlite3.h in project.build/glfw/sqlite3/

3) Edit project.build/glfw/mingw/Makefile

  a) add "-I../sqlite3" (without quote marks) to the end of the CPPFLAGS line.
  b) add "../sqlite3/sqlite3.o" (without quote marks) to the end of the OBJS line.

4) Edit project.build/glfw/CONFIG.MONKEY

  a) make sure #GLFW_USE_MINGW=true

