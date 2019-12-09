# usage: 
#        $ make
#        $ make v=1     # verbose ouput
#        $ make debug=y # debug


# target executable file or .a or .so or .out
TARGET := a.out

# Add additional include paths
INCLUDES := 

# Extra flags to give to compilers when they are supposed to invoke the linker,
# ‘ld’, such as -L. Libraries (-lfoo) should be added to the LDLIBS variable instead. 
LDFLAGS :=

# Library flags or names given to compilers when they are supposed to invoke the linker, 
# ‘ld’. LOADLIBES is a deprecated (but still supported) alternative to LDLIBS. 
# Non-library linker flags, such as -L, should go in the LDFLAGS variable. 
LDLIBS :=

# General compiler flags
CFLAGS = -std=c11
CXXFLAGS = -std=c++11

# Path to the source directory, relative to the makefile
SRC_DIR = 

# Build and output paths
BUILD_DIR = build/

# Search Path for All Prerequisites
VPATH := 

# Compiler used
CC := gcc
CXX := g++
ARFLAGS := cr


# Define the installation command package
define run_install
  install -v -d destination
  install -v -p -D source destination
  install -v -p -D -m 0755 source destination
endef
#### END PROJECT SETTINGS ####


# Generally should not need to edit below this line

.SECONDARY:


ifeq ($(v),1)
    Q  =
    NQ = true
else
    Q  = @
    NQ = echo
endif


ifeq ($(debug), y)
    CFLAGS += -Wall -Wextra  -D DEBUG  -g
    CXXFLAGS += -Wall -Wextra  -D DEBUG  -g
else
    CFLAGS += -Wall -Wextra  -D NDEBUG -O3
    CXXFLAGS += -Wall -Wextra  -D NDEBUG -O3
endif


%.so: CFLAGS += -fPIC -shared
%.so: CXXFLAGS += -fPIC -shared

VPATH := $(SRC_DIR) $(BUILD_DIR)


# Set the object file names, with the source directory stripped
# from the path, and the build path prepended in its place
OBJECTS := $(patsubst $(SRC_DIR)%.c,$(BUILD_DIR)%.o, $(wildcard $(SRC_DIR)*.c))
OBJECTS += $(patsubst $(SRC_DIR)%.cpp,$(BUILD_DIR)%.o, $(wildcard $(SRC_DIR)*.cpp))

# Set the dependency files that will be used to add header dependencies
DEPS := $(OBJECTS:.o=.d)


all: $(TARGET)


# Create static library
%.a: $(OBJECTS)
	@$(NQ) "Generating static lib file..."  $@
	$(Q)$(AR) $(ARFLAGS) $(BUILD_DIR)$@ $^


# Create dynamic library
%.so: $(OBJECTS)
	@$(NQ) "Generating dynamic lib file..." $@
	$(Q)$(CXX) $^ -o $(BUILD_DIR)$@ $(LDFLAGS)  $(LDLIBS)


# Generating executable file
%.out: $(OBJECTS)
	@$(NQ) "Generating executable file..." $@
	$(Q)$(CXX) $^ -o $(BUILD_DIR)$@ $(LDFLAGS) $(LDLIBS)


.PHONY: run
run:
	$(Q)./$(BUILD_DIR)/$(TARGET)


.PHONY: install
install:
	$(run_install)


# Removes all build files
.PHONY: clean
clean: 
	@$(NQ) "Clear build directory of $(TARGET)..."
	$(Q)$(RM) -r $(BUILD_DIR)


$(BUILD_DIR):
	@$(NQ) Creating build directory ...
	$(Q) mkdir -p $@
	@$(NQ) Build directory created!
	@$(NQ) 


# Function used to check variables. Use on the command line:
# make print-VARNAME
# Useful for debugging and adding features
d-%::
	@$(NQ) '$*=(*)'
	@$(NQ) '	origin = $(origin *)'
	@$(NQ) '	flavor = $(flavor *)'
	@$(NQ) '		value = $(value  $*)'


# Source file rules
# After the first compilation they will be joined with the rules from the
# dependency files to provide header dependencies
$(BUILD_DIR)%.o: %.c | $(BUILD_DIR)
	@$(NQ) "Compiling: $< -> $@"
	$(Q)$(CC) $(CFLAGS) $(INCLUDES) -MP -MMD -c $< -o $@

$(BUILD_DIR)%.o: %.cpp | $(BUILD_DIR)
	@$(NQ) "Compiling: $< -> $@"
	$(Q)$(CXX) $(CXXFLAGS) $(INCLUDES) -MP -MMD -c $< -o $@


# Add dependency files, if they exist
-include $(DEPS)
