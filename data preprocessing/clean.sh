#!/bin/sh

for file in ntriples/*; 
do    
filename=$(basename $file)
grep -Eh -v '^<http://lod.b3kat.de/issn/|^<http://lod.b3kat.de/isbn/|^<http://lod.b3kat.de/ssg|#item|#vol' $file > cleanout/clean$filename
done

 
