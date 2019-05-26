#### PROJECT SETTINGS ####
# The name of the executable to be created
BIN_NAME :=
SUBDIRS :=
# Path to the source directory, relative to the makefile
SRC_PATH :=
# Build and output paths
BUILD_PATH := build
# General compiler flags
CFLAGS := -Wall -Wextra -std=c11
CXXFLAGS := -Wall -Wextra -std=c++11
ARFLAGS := cr
# General linker settings
LDLIBS :=
LDFLAGS :=
# Add additional include paths
INCLUDES :=
VPATH := $(SRC_PATH) $(BUILD_PATH)
# Compiler used
# CC := gcc
# CXX := g++
#### END PROJECT SETTINGS ####


# Optionally you may move the section above to a separate config.mk file, and
# uncomment the line below

include config.mk


# Generally should not need to edit below this line

# Combine compiler and linker flags
release: export CFLAGS += -D NDEBUG -O3
release: export CXXFLAGS += -D NDEBUG -O3
debug: export CFLAGS += -D DEBUG  -g
debug: export CXXFLAGS += -D DEBUG  -g
debug: ARGV := debug
clean: ARGV := clean

# Verbose option, to output compile and link commands
V ?= false
CMD_PREFIX := @
ifeq ($(V), true)
    CMD_PREFIX :=
endif


# Clear built-in rules
.SUFFIXES:


# Set the object file names, with the source directory stripped
# from the path, and the build path prepended in its place
OBJECTS := $(patsubst $(SRC_PATH)%.c,%.o, $(wildcard $(SRC_PATH)*.c))
OBJECTS += $(patsubst $(SRC_PATH)%.cpp,%.o, $(wildcard $(SRC_PATH)*.cpp))


# Set the dependency files that will be used to add header dependencies
DEPS := $(OBJECTS:.o=.d)


# Standard, non-optimized release build
.PHONY: release
release: dirs  $(OBJECTS) $(SUBDIRS)
	@$(MAKE) $(BIN_NAME) --no-print-directory --no-builtin-rule
	@echo "Build release end."


# Debug build for gdb debugging
.PHONY: debug
debug:  dirs  $(OBJECTS) $(SUBDIRS)
	@$(MAKE) $(BIN_NAME) --no-print-directory --no-builtin-rule
	@echo "Build debug end."


# Create the directories used in the build
.PHONY: dirs
dirs:
	@mkdir -p $(BUILD_PATH)


# Removes all build files
.PHONY: clean
clean: $(SUBDIRS)
	@echo "Deleting $</$(BUILD_PATH)"
	@$(RM) -r $(BUILD_PATH)


.PHONY: run
run:
	@$(BUILD_PATH)/$(BIN_NAME)


# Add dependency files, if they exist
-include $(DEPS)


ifdef SUBDIRS
  .PHONY: $(SUBDIRS)
  $(SUBDIRS):
	  @$(MAKE) -C $@ $(ARGV) --no-print-directory --no-builtin-rule
	  @echo
endif


ifndef $(suffix $(BIN_NAME))
  BIN_NAME := $(BIN_NAME).run
endif


# Link the executable
$(basename $(BIN_NAME)).run: $(LDLIBS)
	@echo "Linking: $(basename $@)"
	$(CMD_PREFIX)$(CXX) $(LDFLAGS) -o $(BUILD_PATH)/$(basename $@) $^


# Create a shared library
%.so: $(LDLIBS)
	@echo "Create shared library: $@"
	$(CMD_PREFIX)$(CXX) -fPIC -shared $(LDFLAGS) -o $(BUILD_PATH)/$@ $^


# Create static library
%.a: $(LDLIBS)
	@echo "Create static library: $@"
	$(CMD_PREFIX)$(AR) $(ARFLAGS) $(BUILD_PATH)/$@ $^


# Source file rules
# After the first compilation they will be joined with the rules from the
# dependency files to provide header dependencies
%.o: %.c
	@echo "Compiling: $< -> $@"
	$(CMD_PREFIX)$(CC) $(CFLAGS) $(INCLUDES) -MP -MMD -c $< -o $(BUILD_PATH)/$@

%.o: %.cpp
	@echo "Compiling: $< -> $@"
	$(CMD_PREFIX)$(CXX) $(CXXFLAGS) $(INCLUDES) -MP -MMD -c $< -o $(BUILD_PATH)/$@


# Function used to check variables. Use on the command line:
# make print-VARNAME
# Useful for debugging and adding features
d-%:
	@echo '$*=(*)'
	@echo '	origin = $(origin *)'
	@echo '	flavor = $(flavor *)'
	@echo '		value = $(value  $*)'
