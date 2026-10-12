# Exports every part to out/. flat_bin.scad is the shared module, drawer.scad shows the exported parts together
OPENSCAD ?= openscad
PARTS := $(filter-out flat_bin drawer,$(basename $(wildcard *.scad)))
MODELS := $(PARTS) drawer
comma := ,

all: $(MODELS:%=out/%.stl) out/spice_jars.items.stl out/models.json

out/%.stl: %.scad flat_bin.scad | out
	$(OPENSCAD) -o $@ $<

# The jars, for the fit preview in index.html
out/spice_jars.items.stl: spice_jars.scad flat_bin.scad | out
	$(OPENSCAD) -D show_jars=true -o $@ $<

out/drawer.stl: drawer.scad $(PARTS:%=out/%.stl) | out
	$(OPENSCAD) -o $@ $<

# Model list for index.html
out/models.json: $(MODELS:%=out/%.stl)
	echo '[$(subst " ","$(comma)",$(patsubst %,"%",$(MODELS)))]' > $@

out:
	mkdir -p out

clean:
	rm -rf out

.PHONY: all clean
