# Build the Linux command-line version of DFET.
#
# Targets:
#   make          Build an optimized binary in build/bin/dfet.
#   make debug    Build a debug binary in build/debug/bin/dfet.
#   make clean    Remove generated build files.

CXX ?= g++

BUILD_DIR ?= build
OBJ_DIR := $(BUILD_DIR)/obj
BIN_DIR := $(BUILD_DIR)/bin
TARGET := $(BIN_DIR)/dfet

CPPFLAGS += -DDFET_CLI_MODE -I. -Ilibs/DFfile -Ilibs/DFfile/DFset
CXXFLAGS ?= -O2 -std=c++17 -Wno-narrowing
LDLIBS += -lstdc++fs

SOURCES := \
	DFET.cpp \
	libs/DFfile/DFboot.cpp \
	libs/DFfile/DFfile.cpp \
	libs/DFfile/DFmov.cpp \
	libs/DFfile/DFpup.cpp \
	libs/DFfile/DFscript.cpp \
	libs/DFfile/lodepng.cpp \
	libs/DFfile/DFset/DFset.cpp \
	libs/DFfile/DFset/sceneTransition.cpp \
	libs/DFfile/DFset/scenes.cpp

OBJECTS := $(SOURCES:%.cpp=$(OBJ_DIR)/%.o)
DEPENDENCIES := $(OBJECTS:.o=.d)

.PHONY: all release debug clean

all release: $(TARGET)

debug:
	$(MAKE) BUILD_DIR=$(BUILD_DIR)/debug CXXFLAGS="$(filter-out -O% -g,$(CXXFLAGS)) -O0 -g" all

$(TARGET): $(OBJECTS)
	@mkdir -p $(@D)
	$(CXX) $(LDFLAGS) -o $@ $^ $(LDLIBS)

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

-include $(DEPENDENCIES)
