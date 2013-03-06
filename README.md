SQLite3
=======

**sqlite3 monkey wrapper**

Installation:

**Visual Studio 10:**

*  Make the directory project.build/glfw/sqlite3

*  Put sqlite3.c and sqlite3.h in project.build/glfw/sqlite3/

*  Update the native project

* *  Add project.build/glfw/sqlite3/ to the native project
  
* *  Add project.build/glfw/sqlite3/ to the additional include directories
  
* *  Make sure that sqlite3.c is compiled as C code


**gcc/MinGW**

*  Make the directory project.build/glfw/sqlite3

*  Put sqlite3.c and sqlite3.h in project.build/glfw/sqlite3/

*  Edit project.build/glfw/mingw/Makefile

* *  add "-I../sqlite3" (without quote marks) to the end of the CPPFLAGS line.
* *  add "../sqlite3/sqlite3.o" (without quote marks) to the end of the OBJS line.

*  Edit project.build/glfw/CONFIG.MONKEY

* * make sure #GLFW_USE_MINGW=true

