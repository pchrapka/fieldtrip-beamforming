#!/bin/bash

DESTDIR=anatomy
if [ ! -d "$DESTDIR" ]; then
    mkdir $DESTDIR
fi

TMPFILE=`mktemp`
TESTFILE=http://www.colorado.edu/conflict/peace/download/peace.zip
wget $TESTFILE -O $TMPFILE
#wget ftp://ftp.fieldtriptoolbox.org/pub/fieldtrip/tutorial/Subject01.zip -O $TMPFILE
unzip -d $DESTDIR/Subject01 $TMPFILE
rm $TMPFILE
