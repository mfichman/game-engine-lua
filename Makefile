LUAFILES=$(shell find src -name '*.lua')
OBJFILES=$(patsubst src/%.lua, bld/%.o, $(LUAFILES))

LDFLAGS=-llua

all: bin/main

bld/%.o: src/%.lua
	@mkdir -p $(dir $@)
	luajit -b $^ $@

bin/main: src/main.c $(OBJFILES)
	$(CC) $(LDFLAGS) -o $@ $^
