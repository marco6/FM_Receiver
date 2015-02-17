# Compilation flags
GHDL_FLAGS := --ieee=synopsys

# First I need to find files in src dir.
# !!! With this script I won't support dubdirs in src. 
SRC_FILES := $(notdir $(wildcard src/*.vhd))

# Target names
SRC := $(SRC_FILES:.vhd=)

# Same as src, but with tests. Tests need an additional step to be performed
TEST_FILES := $(addprefix test/, $(notdir $(wildcard src/test/*.vhd)))
TEST := $(TEST_FILES:.vhd=)

# Just some dependencies
all: $(SRC) $(TEST)

%: src/%.vhd
	ghdl -a $(GHDL_FLAGS) --workdir=build src/$@.vhd
	
# Tests needs the compilation of the whole library to be complete, but 
# does not depends on other tests
test/%: src/test/%.vhd
	ghdl -a $(GHDL_FLAGS) --workdir=build src/$@.vhd
	
# run test: I just call ghdl and than gtkwave
run/%: test/%
	@echo "Running $* testcase..."
	ghdl --elab-run $(GHDL_FLAGS) --workdir=build $* --vcd="waves/$*.vcd"
#	gtkwave "waves/$*.vcd" &

# running depends on all tests by calling a run rule each
run:  $(addprefix run/, $(notdir $(TEST)))

# clean needs to be always executed
.PHONY: clean

# I just delete everything from folders and everything excepte the
# makefile from root!
clean:
	rm build/* waves/*
	find . -maxdepth 1 -type f -not -name 'Makefile' -delete
