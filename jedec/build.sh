export LIBCUPL=C:\\Wincupl\\Shared\\cupl.dl

CUPL="WINEDEBUG=-all wine c:Wincupl/Shared/cupl.exe"

OLVL=2
#OLVL=3
SLVL=3 # optimization level for sensitive files (U305)

eval $CUPL -jm$OLVL u202.pld
mv U202.jed u202.jed
eval $CUPL -jm$OLVL u203.pld
mv U203.jed u203.jed
eval $CUPL -jm$OLVL u205.pld
mv U205.jed u205.jed
eval $CUPL -jm$OLVL u207.pld
mv U207.jed u207.jed
eval $CUPL -jm$OLVL u303.pld
mv U303.jed u303.jed
eval $CUPL -jm$OLVL u304.pld
mv U304.jed u304.jed
eval $CUPL -jm$SLVL u305.pld
mv U305.jed u305.jed
eval $CUPL -jm$OLVL u306.pld
mv U306.jed u306.jed


