include $(RTEMS_MAKEFILE_PATH)/Makefile.inc
include $(RTEMS_CUSTOM)
include $(PROJECT_ROOT)/make/leaf.cfg

INSTALL_DIR=/home/eduardo/devel/ins_lwip_bb

#### CONFIG ####################################################################
#For debugging symbols add -DLWIP_DEBUG 
# COMPILER/LINKER
CFLAGS+=-g -O2   \
 -Wall

# OUTPUT
LWIP_EXEC=lwip

#### PATHS #####################################################################

# LWIP
LWIP_PATH=.
LWIP_SRC_PATH=$(LWIP_PATH)/src
LWIP_API_PATH=$(LWIP_SRC_PATH)/api
LWIP_CORE_PATH=$(LWIP_SRC_PATH)/core
LWIP_INCL_PATH=$(LWIP_SRC_PATH)/include
LWIP_NETIF_PATH=$(LWIP_SRC_PATH)/netif

# ARCH
LWIPARCH_PATH=$(LWIP_PATH)/ports
LWIPARCH_SRC_PATH=$(LWIPARCH_PATH)
LWIPARCH_INCL_PATH=$(LWIPARCH_PATH)/include

# DRIVER
LWIPDRIVER_PATH=$(LWIP_PATH)/ports
LWIPDRIVER_SRC_PATH=$(LWIPDRIVER_PATH)/netif
LWIPDRIVER_INCL_PATH=$(LWIPDRIVER_PATH)/include/netif

#### SOURCES ###################################################################

## CORE
CORE_SRC=$(wildcard $(LWIP_CORE_PATH)/*.c)

## IPv4
IPV4_SRC=$(wildcard $(LWIP_CORE_PATH)/ipv4/*.c)

## IPv6
IPV6_SRC=$(wildcard $(LWIP_CORE_PATH)/ipv6/*.c)

## SNMP
SNMP_SRC=$(wildcard $(LWIP_CORE_PATH)/snmp/*.c)

## API
API_SRC=$(wildcard $(LWIP_API_PATH)/*.c )

## NETIF
NETIF_SRC=$(wildcard $(LWIP_NETIF_PATH)/*.c) \
          $(wildcard $(LWIP_NETIF_PATH)/ppp/*.c) \
          $(wildcard $(LWIP_NETIF_PATH)/ppp/polarssl/*.c)


ARCH_SRC= $(wildcard $(LWIPARCH_SRC_PATH)/*.c)

# DRIVER
DRIVER_SRC=$(wildcard $(LWIPDRIVER_SRC_PATH)/*.c ) \
	$(wildcard $(LWIPDRIVER_SRC_PATH)/*.S )


SOURCES =  $(DRIVER_SRC) $(SNMP_SRC)\
	$(CORE_SRC) $(IPV4_SRC) $(API_SRC) $(NETIF_SRC) $(ARCH_SRC)


#### HEADERS ###################################################################

## CORE
CORE_H=$(LWIP_INCL_PATH)

## IPv4
#IPV4_H=$(LWIP_INCL_PATH)/ipv4

## IPv6
#IPV6_H=$(LWIP_INCL_PATH)/ipv6

## POSIX
POSIX_H=$(LWIP_INCL_PATH)/posix

##POSIX_SYS
POSIX_SYS_H=$(LWIP_INCL_PATH)/posix/sys


## NETIF
NETIF_H=$(LWIP_INCL_PATH)/netif
NETIF_H_PPP=$(LWIP_INCL_PATH)/netif/ppp
NETIF_H_PPP_POLARSSL=$(LWIP_INCL_PATH)/netif/ppp/polarssl

## ARCH
ARCH_H=$(LWIPARCH_INCL_PATH)

## DRIVER
DRIVER_H=$(LWIPDRIVER_INCL_PATH)

# HEADERS
HEADERS=-I$(CORE_H) -I$(POSIX_H) -I$(POSIX_SYS_H) -I$(NETIF_H) \
        -I$(NETIF_H_PPP) -I$(NETIF_H_PPP_POLARSSL) -I$(ARCH_H) \
        -I$(DRIVER_H)


################################################################################


BIN=${ARCH}/$(LWIP_EXEC).bin
LIB=${ARCH}/lib$(LWIP_EXEC).a

# optional managers required
MANAGERS=all

# C source names
CSRCS=$(filter %.c ,$(SOURCES))
COBJS=$(patsubst %.c,${ARCH}/%.o,$(notdir $(CSRCS)))

ASMSRCS=$(filter %.S , $(SOURCES))
ASMOBJS=$(patsubst %.S,${ARCH}/%.o,$(notdir $(ASMSRCS)))

OBJS=$(COBJS) $(ASMOBJS)

all:${ARCH} $(LIB)

$(LIB): $(OBJS)
	$(AR)  rcs  $@ $^

${ARCH}/%.o: $(LWIP_CORE_PATH)/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIP_CORE_PATH)/ipv4/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIP_CORE_PATH)/ipv6/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIP_CORE_PATH)/snmp/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIP_API_PATH)/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIP_NETIF_PATH)/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIP_NETIF_PATH)/ppp/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIP_NETIF_PATH)/ppp/polarssl/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIPARCH_SRC_PATH)/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIPDRIVER_SRC_PATH)/%.S
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIPDRIVER_SRC_PATH)/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<


install:
	rm -rf $(INSTALL_DIR)
	mkdir -p $(INSTALL_DIR)/include
	mkdir -p $(INSTALL_DIR)/lib
	cp $(LIB) $(INSTALL_DIR)/lib  
	cp -r $(CORE_H) $(INSTALL_DIR)
#	cp -r $(IPV4_H)/lwip $(INSTALL_DIR)/include 
	cp $(LWIPARCH_INCL_PATH)/lwipopts.h $(INSTALL_DIR)/include
	cp $(LWIPARCH_INCL_PATH)/lwip_bbb.h $(INSTALL_DIR)/include 
	cp -r $(LWIPARCH_INCL_PATH)/arch $(INSTALL_DIR)/include

CPPFLAGS+=$(HEADERS)
