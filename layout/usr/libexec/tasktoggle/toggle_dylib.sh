#!/bin/bash
EXTDIR="/Library/MobileSubstrate/DynamicLibraries"
if [ -f "$EXTDIR/$1.dylib" ]; then
        /bin/mv "$EXTDIR/$1.dylib" "$EXTDIR/$1.disabled"
else
        /bin/mv "$EXTDIR/$1.disabled" "$EXTDIR/$1.dylib"
fi
exit 0