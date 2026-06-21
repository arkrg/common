#Makefile

DB = $(notdir $(CURDIR))
TB         ?= tb_$(DB)
BUILD_DIR  = ./build/$(TB)

PKG_FILES  = $(wildcard ./pkg/*.sv)
RTL_FILES  = $(wildcard ./rtl/*.v) $(wildcard ./rtl/*.sv)
TB_FILES   = $(wildcard ./tb/$(TB).v) $(wildcard ./tb/$(TB).sv)

.PHONY: all run compile sim wave clean

all: compile sim wave

run: compile sim

compile:
	@mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && xvlog -sv -L uvm $(addprefix ../../, $(PKG_FILES) $(RTL_FILES) $(TB_FILES))
	cd $(BUILD_DIR) && xelab $(TB) -L uvm -debug typical -log compile.log -s $(TB)_snapshot

sim:
	cd $(BUILD_DIR) && xsim $(TB)_snapshot -R

wave:
	cd $(BUILD_DIR) && gtkwave *.vcd &


clean:
	rm -rf $(BUILD_DIR)
