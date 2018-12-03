#!/bin/sh

#for all the file in cleanout folder
for file in cleanout/*; 
do
    
#save the name of the file as filename
filename=$(basename $file)
# save all items with dctsubject in a new file “dctsubjectitems”
grep -Eh "<http://purl.org/dc/terms/subject>" $file|cut -d ' ' -f1|sort|uniq > dctsubjectitems/dctsubjectitem$filename;
#grep all information about items in “dctsubjectitems” and save in “grepdctsubject”
awk -F ' '  'FNR==NR {hash[$1]; next} $1 in hash' dctsubjectitems/dctsubjectitem$filename $file > grepdctsubject/grepdctsubject_$filename

done

 
