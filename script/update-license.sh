find src -name \*.lua -exec luajit script/license.lua .skeleton.lua {} \;
find src -name \*.c -exec luajit script/license.lua .skeleton.c {} \;
find src -name \*.cpp -exec luajit script/license.lua .skeleton.cpp {} \;
find src -name \*.h -exec luajit script/license.lua .skeleton.h {} \;
