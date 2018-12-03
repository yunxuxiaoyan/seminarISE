#!/bin/sh

#for all the file in cleanout folder
for file in grepdctsubject/*; 
do    

#save the name of the file as filename
filename=$(basename $file)
#save all items with marcrelaut and save in folder “autitem”
grep -Eh "<http://id.loc.gov/vocabulary/relators/aut>" $file|cut -d ' ' -f1|sort|uniq > autitem/autitem_$filename;
#grep all items existing in Wikidata and save in folder “autwikiitem”
awk -F ' '  'FNR==NR {hash[$1]; next} $1 in hash' autitem/autitem_$filename autwikiitem.csv > autwikiitem/autwikiitem_$filename
#grep all information about items in “autwikiitem” and save in “grepaut_grepdctsubject”
awk -F ' '  'FNR==NR {hash[$1]; next} $1 in hash' autwikiitem/autwikiitem_$filename $file > grepaut_grepdctsubject/grepaut_$filename

done

 
