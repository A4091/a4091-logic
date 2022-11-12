
SOURCES:=u202.pld u203.pld u205.pld u207.pld u303.pld u304.pld u305.pld u306.pld

SRC := $(SOURCES:%.pld=source/%.pld)
JED := $(SOURCES:%.pld=jedec/%.jed)
CUPL = LIBCUPL=C:\\Wincupl\\Shared\\cupl.dl WINEDEBUG=-all wine c:Wincupl/Shared/cupl.exe
OPT  = 1

all: $(JED)

clean:
	rm -f $(JED)

jedec/%.jed: source/%.pld Makefile
	$(CUPL) -jm$(OPT) $(LIBCUPL) $<
	mv $(<:source/u%.pld=source/U%.jed) $(<:source/%.pld=jedec/%.jed)

jedec/u305.jed : OPT=3 # U305 says: COMPILE -M3

