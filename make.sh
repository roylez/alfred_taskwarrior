#!/bin/bash
# vim:fdm=marker
#Description:

archive=taskwarrior.alfredworkflow

rm -rf $archive

echo "Packing all files in $archive"

zip -r $archive *
