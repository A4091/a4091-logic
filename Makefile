
SOURCES:=u202.pld u203.pld u205.pld u207.pld u303.pld u304.pld u305.pld u306.pld

SRC := $(SOURCES:%.pld=source/%.pld)
JED := $(SOURCES:%.pld=jedec/%.jed)
CUPL = LIBCUPL=C:\\Wincupl\\Shared\\cupl.dl WINEDEBUG=-all wine c:Wincupl/Shared/cupl.exe
OPT  = 1

all: $(JED)

jedec/%.jed: source/%.pld Makefile util/jedcrc
	$(CUPL) -jm$(OPT) $(LIBCUPL) $<
	mv $(<:source/u%.pld=source/U%.jed) $(<:source/%.pld=jedec/%.jed)
	util/fixup_jed.sh $< $(<:source/%.pld=jedec/%.jed)

jedec/u305.jed : OPT=3 # U305 says: COMPILE -M3

util/jedcrc : util/jedcrc.c

clean:
	rm -f util/jedcrc
distclean: clean
	rm -f $(JED)

