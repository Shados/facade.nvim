MOONC?=moonc
MOON_DIR=moon
LUA_OUT_DIR=lua
MOON_FILES=$(wildcard $(MOON_DIR)/**.moon)
LUA_FILES=$(patsubst moon/%,lua/%,$(patsubst %.moon,%.lua,$(MOON_FILES)))

PREFIX?=/usr/local
LUA_LIBDIR?=$(PREFIX)/lua/5.1

.PHONY: all install clean watch

all: build

watch: build
	moonc -w $(MOON_DIR)/ -t $(LUA_OUT_DIR)

build: $(LUA_FILES)

lua/%.lua: moon/%.moon
# $(@D) == lua/sub/directories
	@test -d $(@D) || mkdir -pm 755 $(@D)
	$(MOONC) $< -o $@

clean:
	rm -f $(LUA_FILES)

install: build
	@test -d $(LUA_LIBDIR) || mkdir -pm 755 $(LUA_LIBDIR)
	cp -rf $(LUA_OUT_DIR)/* $(LUA_LIBDIR)/
