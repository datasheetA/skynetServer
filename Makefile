.PHONY: all clean build lua53

TOP=$(PWD)
CS_COMMON_DIR=./cs_common
BUILD_DIR=./build

INCLUDE_DIR=$(BUILD_DIR)/include
BUILD_CLUALIB_DIR=$(BUILD_DIR)/clualib
BUILD_CLIB_DIR=$(BUILD_DIR)/clib
BUILD_CSERVICE_DIR=$(BUILD_DIR)/cservice

#all instrunctions begin

all: build

clean:
	-rm -rf build/**
	$(CLEAN_ALL)

#all instrunctions end


#create all dynamic dir begin

build:
	-mkdir $(INCLUDE_DIR)
	-mkdir $(BUILD_CLUALIB_DIR)
	-mkdir $(BUILD_CLIB_DIR)
	-mkdir $(BUILD_CSERVICE_DIR)

#create all dynamic dir end

#build lua53 begin

all: lua53

LUA_LIB = $(BUILD_CLIB_DIR)/liblua.a
LUA_INC = $(INCLUDE_DIR)

lua53:
	cd skynet/3rd/lua/ && $(MAKE) MYCFLAGS="-O2 -fPIC -g -I../../skynet-src" linux
	install -p -m 0755 skynet/3rd/lua/lua $(BUILD_DIR)/lua
	install -p -m 0755 skynet/3rd/lua/luac $(BUILD_DIR)/luac
	install -p -m 0644 skynet/3rd/lua/liblua.a $(BUILD_CLIB_DIR)
	install -p -m 0644 skynet/3rd/lua/lua.h $(INCLUDE_DIR)
	install -p -m 0644 skynet/3rd/lua/lauxlib.h $(INCLUDE_DIR)
	install -p -m 0644 skynet/3rd/lua/lualib.h $(INCLUDE_DIR)
	install -p -m 0644 skynet/3rd/lua/luaconf.h $(INCLUDE_DIR)

#build lua53 end

#build skynet begin

.PHONY: skynet build-skynet
all: skynet
SKYNET_MAKEFILE=skynet/Makefile

skynet: build-skynet
	cp skynet/skynet-src/skynet_malloc.h $(INCLUDE_DIR)
	cp skynet/skynet-src/skynet.h $(INCLUDE_DIR)
	cp skynet/skynet-src/skynet_env.h $(INCLUDE_DIR)
	cp skynet/skynet-src/skynet_socket.h $(INCLUDE_DIR)

SKYNET_DEP_PATH = SKYNET_BUILD_PATH=../$(BUILD_DIR) \
		LUA_CLIB_PATH=../$(BUILD_CLUALIB_DIR) \
		CSERVICE_PATH=../$(BUILD_CSERVICE_DIR)

build-skynet: | $(SKYNET_MAKEFILE)
	cd skynet && $(MAKE) PLAT=linux $(SKYNET_DEP_PATH)

define CLEAN_SKYNET
	cd skynet && $(MAKE) cleanall
endef

CLEAN_ALL += $(CLEAN_SKYNET)

#build skynet end

#build zinc begin

all: zinc

CFLAGS = -g3 -O2 -rdynamic -Wall -I$(INCLUDE_DIR) 
LDFLAGS = -L$(BUILD_CLIB_DIR) -Wl,-rpath $(BUILD_CLIB_DIR) -pthread -lm -ldl -lrt
SHARED = -fPIC --shared

CLIB=rc4 pbc
CSERVICE=zinc_gate
CLUALIB=protobuf laoi

CLIB_TARGET=$(patsubst %, $(BUILD_CLIB_DIR)/lib%.so, $(CLIB))
CSERVICE_TARGET=$(patsubst %, $(BUILD_CSERVICE_DIR)/%.so, $(CSERVICE))
CLUALIB_TARGET=$(patsubst %, $(BUILD_CLUALIB_DIR)/%.so, $(CLUALIB))

zinc: \
	$(CLIB_TARGET) \
	$(CSERVICE_TARGET) \
	$(CLUALIB_TARGET)

PROTOBUFSRC = \
  clib/lua-protobuf/context.c \
  clib/lua-protobuf/varint.c \
  clib/lua-protobuf/array.c \
  clib/lua-protobuf/pattern.c \
  clib/lua-protobuf/register.c \
  clib/lua-protobuf/proto.c \
  clib/lua-protobuf/map.c \
  clib/lua-protobuf/alloc.c \
  clib/lua-protobuf/rmessage.c \
  clib/lua-protobuf/wmessage.c \
  clib/lua-protobuf/bootstrap.c \
  clib/lua-protobuf/stringpool.c \
  clib/lua-protobuf/decode.c

#clib
$(BUILD_CLIB_DIR)/librc4.so : clib/rc4/rc4.c clib/rc4/rc4.h clib/rc4/conn_keys.h
	cp clib/rc4/rc4.h $(INCLUDE_DIR)
	cp clib/rc4/conn_keys.h $(INCLUDE_DIR)
	gcc $(CFLAGS) -Iskynet/service-src $(SHARED) $^ -o $@ 

$(BUILD_CLIB_DIR)/libpbc.so : $(PROTOBUFSRC)
	cp clib/lua-protobuf/pbc.h $(INCLUDE_DIR)
	gcc $(CFLAGS) -Iskynet/service-src $(SHARED) $^ -o $@ $(LDFLAGS)

# cservice
$(BUILD_CSERVICE_DIR)/zinc_gate.so : clib/service-src/service_zinc_gate.c
	gcc $(CFLAGS) -Iskynet/service-src $(SHARED) $^ -o $@  $(LDFLAGS) -lrc4

#clualib
$(BUILD_CLUALIB_DIR)/protobuf.so : clib/lua-protobuf/pbc-lua53.c $(BUILD_CLIB_DIR)/libpbc.so
	gcc $(CFLAGS) $(SHARED) $^ -o $@ $(LDFLAGS)

$(BUILD_CLUALIB_DIR)/laoi.so : clib/aoi/aoi.c clib/aoi/lua-aoi.c
	cp clib/aoi/aoi.h $(INCLUDE_DIR)
	gcc $(CFLAGS) $(SHARED) $^ -o $@ $(LDFLAGS)

#build zinc end

all:
	@echo 'make finish!!!'
