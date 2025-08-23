# Makefile for DFET (Linux CLI Version)
#
# --- USAGE ---
# make            -> Builds/updates the optimized release version.
# make release    -> Explicitly builds/updates the optimized release version.
# make debug      -> Builds/updates the unoptimized version with debug symbols.
# make clean      -> Removes all generated files.

# Compiler and Linker
CXX = g++

# --- Build Configuration ---

# Base flags, common to both release and debug builds
BASE_CXXFLAGS = -std=c++17 -Wno-narrowing -DDFET_CLI_MODE

# Release-specific flags
RELEASE_CXXFLAGS = -O2

# Debug-specific flags:
# -g : Include full debugging symbols for GDB.
# -O0: Disable all optimizations for accurate line-by-line stepping.
DEBUG_CXXFLAGS = -g -O0

# Include paths for headers.
INCLUDE_PATHS = -I./ -Ilibs/DFfile -Ilibs/DFfile/DFset

# --- Directory and File Definitions ---

BIN_DIR = build
TARGET_NAME = dfet
TARGET = $(BIN_DIR)/$(TARGET_NAME)

# This file stores the last build type ('release' or 'debug').
# It is placed in the bin/ directory and named .log to be ignored by default gitignore patterns.
BUILD_STATE_FILE = $(BIN_DIR)/build.log

SRCS := $(shell find . -name "*.cpp")
OBJS := $(SRCS:.cpp=.o)


# --- Build Rules ---

.PHONY: all release debug clean

# The default target, executed when you just run 'make'.
all: release

# Release build target.
release: | $(BIN_DIR) # Ensure bin directory exists before checking the state file
	@# Check the state file. If the last build was not 'release', then force a clean.
	@# The '2>/dev/null' silences errors if the state file doesn't exist yet.
	@if [ "$$(cat $(BUILD_STATE_FILE) 2>/dev/null)" != "release" ]; then \
		echo "Switching build mode to Release. Cleaning first..."; \
		$(MAKE) clean; \
	fi
	@# Proceed with the actual build, passing the correct flags.
	$(MAKE) $(TARGET) BUILD_MODE_FLAGS="$(RELEASE_CXXFLAGS)"
	@# After a successful build, update the state file.
	@echo "release" > $(BUILD_STATE_FILE)

# Debug build target.
debug: | $(BIN_DIR) # Ensure bin directory exists before checking the state file
	@# Check the state file. If the last build was not 'debug', then force a clean.
	@if [ "$$(cat $(BUILD_STATE_FILE) 2>/dev/null)" != "debug" ]; then \
		echo "Switching build mode to Debug. Cleaning first..."; \
		$(MAKE) clean; \
	fi
	@# Proceed with the actual build, passing the correct flags.
	$(MAKE) $(TARGET) BUILD_MODE_FLAGS="$(DEBUG_CXXFLAGS)"
	@# After a successful build, update the state file.
	@echo "debug" > $(BUILD_STATE_FILE)


# This is the internal linking rule, called by the 'release' and 'debug' targets.
$(TARGET): $(OBJS) | $(BIN_DIR)
	@echo "Linking Target..."
	$(CXX) $(OBJS) -o $@ -lstdc++fs
	@echo "Build complete. Executable is '$(TARGET)'."

# This is the internal compilation rule.
# It uses the CXXFLAGS passed down from the 'release' or 'debug' target's recursive call.
%.o: %.cpp
	$(CXX) $(BASE_CXXFLAGS) $(BUILD_MODE_FLAGS) $(INCLUDE_PATHS) -c $< -o $@

# Rule to create the bin directory.
$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

# Clean rule: Removes the executable, all object files, and the state file.
clean:
	@echo "Cleaning up..."
	@rm -f $(TARGET)
	@rm -f $(BUILD_STATE_FILE)
	@find . -name "*.o" -delete
	@echo "Cleanup complete."

