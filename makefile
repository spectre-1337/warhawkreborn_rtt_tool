SRC = $(shell find . -name '*.cpp')
EXCLUDE_SRC =
FSRC = $(filter-out $(EXCLUDE_SRC), $(SRC))
OBJ = $(FSRC:=.o)

DEP_DIR = .deps

FLAGS = -Wall -Wno-unknown-pragmas
CXXFLAGS = -std=c++14
CFLAGS =
LIBS =
LINKFLAGS = -lpng -lstdc++fs

OUTFILE = rtt_tool

.PHONY: clean debug release debug_static release_static
.PRECIOUS: $(PROTOGEN) $(PROTOHEADERS)

release: FLAGS += -O2
release: LINKFLAGS := $(LIBS) $(LINKFLAGS)
release: $(OUTFILE)
	@strip --strip-unneeded $(OUTFILE)

debug: FLAGS += -g -O0
debug: LINKFLAGS := $(LIBS) $(LINKFLAGS)
debug: $(OUTFILE)

release_static: FLAGS += -O2
release_static: LINKFLAGS := -Wl,-Bstatic $(LIBS) -Wl,-Bdynamic  $(LINKFLAGS)
release_static: $(OUTFILE)
	@strip --strip-unneeded $(OUTFILE)

debug_static: FLAGS += -g -O0
debug_static: LINKFLAGS := -Wl,-Bstatic $(LIBS) -Wl,-Bdynamic  $(LINKFLAGS)
debug_static: $(OUTFILE)

$(OUTFILE): $(OBJ)
	@echo Generating binary
	@$(CXX) -o $@ $^ $(LINKFLAGS)
	@echo Build done

%.cc.o: %.cc
	@echo Building $<
	@$(CXX) -c $(FLAGS) $(CXXFLAGS) $< -o $@
	@mkdir -p `dirname $(DEP_DIR)/$@.d`
	@$(CXX) -c $(FLAGS) $(CXXFLAGS) -MT '$@' -MM $< > $(DEP_DIR)/$@.d

%.cpp.o: %.cpp
	@echo Building $<
	@$(CXX) -c $(FLAGS) $(CXXFLAGS) $< -o $@
	@mkdir -p `dirname $(DEP_DIR)/$@.d`
	@$(CXX) -c $(FLAGS) $(CXXFLAGS) -MT '$@' -MM $< > $(DEP_DIR)/$@.d

%.c.o: %.c
	@echo Building $<
	@$(CC) -c $(FLAGS) $(CFLAGS) $< -o $@
	@mkdir -p `dirname $(DEP_DIR)/$@.d`
	@$(CC) -c $(FLAGS) $(CFLAGS) -MT '$@' -MM $< > $(DEP_DIR)/$@.d

clean:
	@echo Removing binary
	@rm -f $(OUTFILE)
	@echo Removing objects
	@rm -f $(OBJ)
	@echo Removing dependency files
	@rm -rf $(DEP_DIR)

-include $(OBJ:%=$(DEP_DIR)/%.d)
