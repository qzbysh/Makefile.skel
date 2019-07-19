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

# Define the installation command package
# define run_install
  # install -v -d /etc/h2o ~/h2o
  # install -v -p -D *.conf /etc/h2o
  # install -v -p -D -m 0755 $(BUILD_PATH)/$(BIN_NAME) ~/h2o
# endef
#### END PROJECT SETTINGS ####


# Optionally you may move the section above to a separate config.mk file, and
# uncomment the line below
include config.mk


# Generally should not need to edit below this line

# Clear built-in rules
.SUFFIXES:


# Verbose option, to output compile and link commands
# V := true
ifeq ($(strip $(V)), true)
  CMD_PREFIX =
else
  CMD_PREFIX = @
endif#### PROJECT SETTINGS ####
SUBDIRS :=

# The name of the executable to be created
BIN_NAME :=

# Add additional include paths
INCLUDES :=

# General linker settings
LDLIBS :=
LDFLAGS :=

# General compiler flags
CFLAGS := -Wall -Wextra -std=c11
CXXFLAGS := -Wall -Wextra -std=c++11

# Path to the source directory, relative to the makefile
SRC_PATH :=

# Build and output paths
BUILD_PATH := build

# Compiler used
CC := gcc
CXX := g++
ARFLAGS := cr

# Define the installation command package
# define run_install
  # install -v -d /etc/h2o ~/h2o
  # install -v -p -D *.conf /etc/h2o
  # install -v -p -D -m 0755 $(BUILD_PATH)/$(BIN_NAME) ~/h2o
# endef
#### END PROJECT SETTINGS ####


# Optionally you may move the section above to a separate config.mk file, and
# uncomment the line below
include config.mk


# Generally should not need to edit below this line

# Clear built-in rules
.SUFFIXES:


# Verbose option, to output compile and link commands
# V := true
ifeq ($(strip $(V)), true)
  CMD_PREFIX :=
else
  CMD_PREFIX := @
endif


ifeq ($(suffix $(BIN_NAME)),)
  BIN_NAME_FULL := $(BIN_NAME).out
else
  BIN_NAME_FULL := $(BIN_NAME)
endif


# Combine compiler and linker flags
VPATH += $(SRC_PATH) $(BUILD_PATH)
release: export CFLAGS += -D NDEBUG -O3
release: export CXXFLAGS += -D NDEBUG -O3
debug: export CFLAGS += -D DEBUG  -g
debug: export CXXFLAGS += -D DEBUG  -g
debug: ARGV := debug
clean: ARGV := clean


# Set the object file names, with the source directory stripped
# from the path, and the build path prepended in its place
OBJECTS := $(patsubst $(SRC_PATH)%.c,%.o, $(wildcard $(SRC_PATH)*.c))
OBJECTS += $(patsubst $(SRC_PATH)%.cpp,%.o, $(wildcard $(SRC_PATH)*.cpp))

# Set the dependency files that will be used to add header dependencies
DEPS := $(OBJECTS:.o=.d)


# Standard, non-optimized release build
.PHONY: release
release: $(OBJECTS) $(SUBDIRS)
	@mkdir -p $(BUILD_PATH)
	$(CMD_PREFIX)$(MAKE) $(BIN_NAME_FULL) --no-print-directory --no-builtin-rules
	@echo "Build release end."


# Debug build for gdb debugging
.PHONY: debug
debug: $(OBJECTS) $(SUBDIRS)
	@mkdir -p $(BUILD_PATH)
	$(CMD_PREFIX)$(MAKE) $(BIN_NAME_FULL) --no-print-directory --no-builtin-rules
	@echo "Build debug end."


# Removes all build files
.PHONY: clean
clean: $(SUBDIRS)
	@echo "Clear build file of $(BIN_NAME)."
	$(CMD_PREFIX)$(RM) -r $(BUILD_PATH)


.PHONY: run
run:
	$(CMD_PREFIX)./$(BUILD_PATH)/$(BIN_NAME)


.PHONY: install
install:
	$(run_install)


ifdef SUBDIRS
  .PHONY: $(SUBDIRS)
  $(SUBDIRS):
	  $(CMD_PREFIX)$(MAKE) -C $@ $(ARGV) --no-print-directory --no-builtin-rules
	  @echo
endif


# Function used to check variables. Use on the command line:
# make print-VARNAME
# Useful for debugging and adding features
d-%::
	@echo '$*=(*)'
	@echo '	origin = $(origin *)'
	@echo '	flavor = $(flavor *)'
	@echo '		value = $(value  $*)'


# Source file rules
# After the first compilation they will be joined with the rules from the
# dependency files to provide header dependencies
%.o: %.c
	@echo "Compiling: $< -> $@"
	$(CMD_PREFIX)$(CC) $(CFLAGS) $(INCLUDES) -MP -MMD -c $< -o $(BUILD_PATH)/$@

%.o: %.cpp
	@echo "Compiling: $< -> $@"
	$(CMD_PREFIX)$(CXX) $(CXXFLAGS) $(INCLUDES) -MP -MMD -c $< -o $(BUILD_PATH)/$@


# Create static library
%.a: $(OBJECTS) $(LDLIBS)
	@echo "Create static library: $@"
	$(CMD_PREFIX)$(AR) $(ARFLAGS) $(BUILD_PATH)/$@ $^


# Create a shared library
%.so: $(OBJECTS) $(LDLIBS)
	@echo "Create shared library: $@"
	$(CMD_PREFIX)$(CXX) -fPIC -shared $(LDFLAGS) -o $(BUILD_PATH)/$@ $^


# Link the executable
%.out: $(OBJECTS) $(LDLIBS)
	@echo "Linking: $(BIN_NAME)"
	$(CMD_PREFIX)$(CXX) $(LDFLAGS) -o $(BUILD_PATH)/$(BIN_NAME) $^


# Add dependency files, if they exist
-include $(DEPS)



ifeq ($(suffix $(BIN_NAME)),)
  BIN_NAME_FULL := $(BIN_NAME).out
else
  BIN_NAME_FULL := $(BIN_NAME)
endif


# Combine compiler and linker flags
release: export CFLAGS += -D NDEBUG -O3
release: export CXXFLAGS += -D NDEBUG -O3
debug: export CFLAGS += -D DEBUG  -g
debug: export CXXFLAGS += -D DEBUG  -g
debug: ARGV := debug
clean: ARGV := clean


# Set the object file names, with the source directory stripped
# from the path, and the build path prepended in its place
OBJECTS := $(patsubst $(SRC_PATH)%.c,%.o, $(wildcard $(SRC_PATH)*.c))
OBJECTS += $(patsubst $(SRC_PATH)%.cpp,%.o, $(wildcard $(SRC_PATH)*.cpp))

# Set the dependency files that will be used to add header dependencies
DEPS := $(OBJECTS:.o=.d)


# Standard, non-optimized release build
.PHONY: release
release: $(OBJECTS) $(SUBDIRS)
	@mkdir -p $(BUILD_PATH)
	$(CMD_PREFIX)$(MAKE) $(BIN_NAME_FULL) --no-print-directory --no-builtin-rules
	@echo "Build release end."


# Debug build for gdb debugging
.PHONY: debug
debug: $(OBJECTS) $(SUBDIRS)
	@mkdir -p $(BUILD_PATH)
	$(CMD_PREFIX)$(MAKE) $(BIN_NAME_FULL) --no-print-directory --no-builtin-rules
	@echo "Build debug end."


# Removes all build files
.PHONY: clean
clean: $(SUBDIRS)
	@echo "Clear build file of $(BIN_NAME)."
	$(CMD_PREFIX)$(RM) -r $(BUILD_PATH)


.PHONY: run
run:
	$(CMD_PREFIX)./$(BUILD_PATH)/$(BIN_NAME)


.PHONY: install
install:
	$(run_install)


ifdef SUBDIRS
  .PHONY: $(SUBDIRS)
  $(SUBDIRS):
	  $(CMD_PREFIX)$(MAKE) -C $@ $(ARGV) --no-print-directory --no-builtin-rules
	  @echo
endif


# Function used to check variables. Use on the command line:
# make print-VARNAME
# Useful for debugging and adding features
d-%::
	@echo '$*=(*)'
	@echo '	origin = $(origin *)'
	@echo '	flavor = $(flavor *)'
	@echo '		value = $(value  $*)'


# Source file rules
# After the first compilation they will be joined with the rules from the
# dependency files to provide header dependencies
%.o: %.c
	@echo "Compiling: $< -> $@"
	$(CMD_PREFIX)$(CC) $(CFLAGS) $(INCLUDES) -MP -MMD -c $< -o $(BUILD_PATH)/$@

%.o: %.cpp
	@echo "Compiling: $< -> $@"
	$(CMD_PREFIX)$(CXX) $(CXXFLAGS) $(INCLUDES) -MP -MMD -c $< -o $(BUILD_PATH)/$@


# Create static library
%.a: $(OBJECTS) $(LDLIBS)
	@echo "Create static library: $@"
	$(CMD_PREFIX)$(AR) $(ARFLAGS) $(BUILD_PATH)/$@ $^


# Create a shared library
%.so: $(OBJECTS) $(LDLIBS)
	@echo "Create shared library: $@"
	$(CMD_PREFIX)$(CXX) -fPIC -shared $(LDFLAGS) -o $(BUILD_PATH)/$@ $^


# Link the executable
%.out: $(OBJECTS) $(LDLIBS)
	@echo "Linking: $(BIN_NAME)"
	$(CMD_PREFIX)$(CXX) $(LDFLAGS) -o $(BUILD_PATH)/$(BIN_NAME) $^


# Add dependency files, if they exist
-include $(DEPS)
