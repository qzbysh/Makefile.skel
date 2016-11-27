#
# Makefile written by Cifer on Sep 05, 2014
#
# Copyright (C) 2014 -
#

# Where are the source files
src_dir = src

# Where the object files go
obj_dir = obj

# The name of the executable file
elf_name = ryuha

CFLAGS := $(CFLAGS) -w -pthread -pipe
#CPPFLAGS += -MMD -MP

LDFLAGS =
LDLIBS =

# All the source files ended in '.c' in $(src_dir) directory
srcs := $(wildcard $(src_dir)/*.c)

# Get the corresponding object file of each source file
objs := $(patsubst $(src_dir)/%.c,$(obj_dir)/%.o,$(srcs))

# Get the dependency file of each source file
deps := $(patsubst $(src_dir)/%.c,$(obj_dir)/%.d,$(srcs))

all : $(obj_dir)/$(elf_name) ;

$(obj_dir)/$(elf_name) : $(objs)
	$(CC) $(LDFLAGS) -o $@ $(objs) $(LDLIBS)
	@echo
	@echo $(elf_name) build success!
	@echo

$(obj_dir)/%.o : $(src_dir)/%.c | $(obj_dir)
	$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

$(obj_dir)/%.d : $(src_dir)/%.c | $(obj_dir)
	@set -e; rm -f $@; \
	$(CC) -MM $(CFLAGS) $(CPPFLAGS) -MT $(@:.d=.o) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

ifneq ($(MAKECMDGOALS), clean)
-include $(deps)
endif

$(obj_dir) :
	@echo Creating obj_dir ...
	@mkdir $(obj_dir)
	@echo obj_dir created!

clean :
	@echo "cleanning..."
	-rm -rf $(obj_dir)
	@echo "clean done!"

# Debug this Makefile
z := foo
x = $(z)
y := $(x) bar
z := later
export z
test :
	echo $(deps)

.PHONY: all clean test
