P2T_DIR ?= ../p2t
PREFIX ?= /usr/local
PACKAGE_DIR ?= $(PREFIX)/share/octave-cdt

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  P2T_LIB ?= /tmp/libp2t.dylib
  P2T_LDFLAGS ?= -L/tmp -lp2t -Wl,-rpath,/tmp
else
  P2T_LIB ?= /tmp/libp2t.so
  P2T_LDFLAGS ?= -L/tmp -lp2t -Wl,-rpath,/tmp
endif

OCT ?= octave
MKOCTFILE ?= mkoctfile

OCT_OUT := inst/cdt_oct.oct inst/cdt_pointset_oct.oct

.PHONY: all clean install test

all: $(OCT_OUT)

inst/cdt_oct.oct inst/cdt_pointset_oct.oct: src/cdt_oct.cc $(P2T_DIR)/include/p2t.h $(P2T_LIB)
	$(MKOCTFILE) -I$(P2T_DIR)/include src/cdt_oct.cc $(P2T_LDFLAGS) -o $@

test: all
	$(OCT) --quiet --path inst --path test --eval "test_cdt"

install: all
	mkdir -p "$(PACKAGE_DIR)/inst" "$(PACKAGE_DIR)/examples" "$(PACKAGE_DIR)/docs"
	cp inst/*.m inst/*.oct "$(PACKAGE_DIR)/inst/"
	cp -R examples/* "$(PACKAGE_DIR)/examples/"
	cp -R docs/* "$(PACKAGE_DIR)/docs/"
	cp README.md COPYING DESCRIPTION INDEX NEWS "$(PACKAGE_DIR)/"
	printf 'addpath ("%s/inst");\naddpath ("%s/examples");\naddpath ("%s/examples/fixtures");\n' "$(PACKAGE_DIR)" "$(PACKAGE_DIR)" "$(PACKAGE_DIR)" > "$(PACKAGE_DIR)/cdt_setup.m"

clean:
	rm -f $(OCT_OUT) src/*.o
