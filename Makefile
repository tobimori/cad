# Exports every part to out/. flat_bin.scad is the shared module, drawer.scad shows the exported parts together.
# make exports STL for index.html, make print exports 3MF to print: STL stores rounded vertices without
# sharing them, which can join vertices that are very close and break the mesh, 3MF keeps the exact mesh
OPENSCAD ?= openscad
STL := --export-format binstl
PARTS := $(filter-out flat_bin drawer,$(basename $(wildcard *.scad)))
MODELS := $(PARTS) drawer
# Parts with a show_items parameter, which makes the items that go in the bin
ITEMS := spice_jars palatti_spouts nanofoamer_controllers nutmeg_grater codale_presser
# Parts with a test_fit parameter, which makes a small part of the bin to test the fit before the full print
TESTS := palatti_spouts nanofoamer_controllers nutmeg_grater codale_presser
comma := ,

all: $(MODELS:%=out/%.stl) $(ITEMS:%=out/%.items.stl) $(TESTS:%=out/%.test.stl) out/models.json

out/%.stl: %.scad flat_bin.scad | out
	$(OPENSCAD) $(STL) -o $@ $<

# The items, for the fit preview in index.html
out/%.items.stl: %.scad flat_bin.scad | out
	$(OPENSCAD) $(STL) -D show_items=true -o $@ $<

out/%.test.stl: %.scad flat_bin.scad | out
	$(OPENSCAD) $(STL) -D test_fit=true -o $@ $<

print: $(PARTS:%=out/%.3mf) $(TESTS:%=out/%.test.3mf)

out/%.3mf: %.scad flat_bin.scad | out
	$(OPENSCAD) -o $@ $<

out/%.test.3mf: %.scad flat_bin.scad | out
	$(OPENSCAD) -D test_fit=true -o $@ $<

out/drawer.stl: drawer.scad $(PARTS:%=out/%.stl) | out
	$(OPENSCAD) $(STL) -o $@ $<

# Model list for index.html
out/models.json: $(MODELS:%=out/%.stl)
	echo '[$(subst " ","$(comma)",$(patsubst %,"%",$(MODELS)))]' > $@

out:
	mkdir -p out

clean:
	rm -rf out

.PHONY: all print clean
