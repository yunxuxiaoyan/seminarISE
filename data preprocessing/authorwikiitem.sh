#!/bin/sh

#for all the file in grepdctsubject folder
for file in grepdctsubject/*; 
do    

#save the name of the file as filename
filename=$(basename $file)
#save all items with marcrelaut/dctsubject and save in folder “authoritem”
grep -Eh "<http://purl.org/dc/terms/creator>|<http://id.loc.gov/vocabulary/relators/aut>" $file|cut -d ' ' -f1|sort|uniq > authoritem/authoritem_$filename;
#grep all items existing in Wikidata and save in folder “authorwikiitem”
awk -F ' '  'FNR==NR {hash[$1]; next} $1 in hash' authoritem/authoritem_$filename authorwikiitem.csv > authorwikiitem/authorwikiitem_$filename
#grep all information about items in “authorwikiitem” and save in “grepauthor_grepdctsubject”
awk -F ' '  'FNR==NR {hash[$1]; next} $1 in hash' authorwikiitem/authorwikiitem_$filename $file > grepauthor_grepdctsubject/grepauthor_$filename

done

 
