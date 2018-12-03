# data pre-processing
This file presents detail data preprocessing step of the book recommender.  
There are in total 30 original turtle files in the dataset, which can be downloaded in https://lod.b3kat.de/doc/download/.  
We shorten the name of the original files as "part0.ttl" to "part30.ttl".  

## data overview
### how many books per category?
There are two properties describe the cateagories of books, namely dc:subject and dct:subject.  
Let's take "dct:subject" as an example.  
First, grep all lines containing "dct;subject" save as "dctsubject".  
```
grep -Eh 'dct:subject' * > dctsubject
```
The "dctsubject" fille is like:
```
        dct:subject               <http://lod.b3kat.de/ssg/9.2> ;
        dct:subject               <http://lod.b3kat.de/ssg/6.12> ;
        dct:subject               <http://rvk.uni-regensburg.de/api/xml/node/BS%204780> .
```
Next, delete all punctuations and white space in the end of each line.
```
sed -i 's/;$//' dctsubject
```
```
sed -i 's/.$//' dctsubject
```
```
sed -i 's/ $//' dctsubject
```
Then sort the dctsubject0 file and count the occurance of each unique line.  
Transfer into a csv file.
```
sort dctsubject|uniq -c|sed 's/  \+/,/g' > dctsubject_count.csv
```
Delete the leading comma.
```
sed -i 's/^,//' dctsubject_count.csv
```
Further steps can be found in file "dctsubject+dcsubject.ipynb".
Input dctsubject_count.csv.
The output "dctsubject.csv" contains two columns "dctsubject" and "number"(the number of book per dctsubject).  
In the same way, we can get "dcsubject.csv".  

### transfer the turtle files into n-triple
Let's take "part1.ttl" for an example.  
We find out that the file size is too large to transfer, so we seperate part1.ttl into two files "split1aa" and "split1ab".
```
split -l 30000000 part1.ttl split/split1 
```
Since the spliting is based on number of lines, the facts of an item can occur in the end of "splitaa" and the start "splitab". It requires some manual steps to modify the two split files to make sure the second file starts with a new item and the first ends with the complete facts of a item.  
Check ?x leading lines of "splitab".  
```
head -?x splitab
```
Find out and save the incomplete facts to a temp file.
```
head -?y split1ab > temp
```
Add temp to split1aa.
```
cat split1aa temp > split1-1
```
Add prefix(file with all the prefix in the dataset) to split1ab.
```
cat prefix split1ab > split1-2
```
Transfer into n-triple.
```
rapper -i turtle split1-1 >out1-1
rapper -i turtle split1-2 >out1-2
```
Save all n-triple files into a folder "ntriples".

### remove needless items
There are 110,698,504 distinct items in the dataset. After overviewing the names of all items, we found out there is information about 5 kinds of items, which we should exclude from our dataset:  
- isbn eg. <http://lod.b3kat.de/isbn/0002111225>  
tells about the corresponding book to the isbn through owl:sameAs  
- issn eg. <http://lod.b3kat.de/issn/9090-0069>  
tells about the corresponding book to the isbn through owl:sameAs  
- ssg eg. <https://lod.b3kat.de/page/ssg/fre>  
represents one kind of dctsubject  
tells about which books have the certain subject through “is dcterms:subject of”  
- #item eg. <http://lod.b3kat.de/title/BV000180845#item-DE-188>  
tells about the exemplar of a certain book  
- #vol eg. <http://lod.b3kat.de/title/BV000203120#vol-12>  
tells about the volume of a certain book  
Use "clean.sh" to remove all the needless items and save in "cleanout" folder.  
After removing these kind of information, we got a dataset with 31,029,224 distinct items.

### how many types(rdf:type) of items are in the dataset?
Grep all lines containing "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>"
```
grep -Eh '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>' cleanout/* > rdftype
```
Delete the punctuation and white spaces and the end of each line.   
Remove the subject and property in the triple.  
Sort and count unique types.
Save as a csv file.
```
sed -i 's/ .$//' rdftype
cut -d ' ' -f3 rdftype |sort|uniq -c|sed 's/ \+/,/g' > rdftype.csv
sed -i 's/^,//' rdftype.csv
```

### how many authors are in the dataset?
There are two properties which decreibe authors, namely dct:creator(<http://purl.org/dc/terms/creator>) and marcrel:aut(<http://id.loc.gov/vocabulary/relators/aut>).   
Follow similar steps with "how many types(rdf:type) of items are in the dataset?"
Let's take "dct:creator" as an example.  
```
grep -Eh '<http://purl.org/dc/terms/creator>' cleanout/* > dctcreator
sed -i 's/ .$//' dctcreator
cut -d ' ' -f3 dctcreator |sort|uniq -c|sed 's/ \+/,/g' > dctcreator.csv
sed -i 's/^,//' dctcreator_count.csv
```
Further steps can be found in file "dctcerator+marcrelaut.ipynb". 
Input: dctcreator_count.csv
The output "dctsubject.csv" contains two columns "dctcreator" and "number"(the number of books per creator).  
In the same way, we can get "marcrelaut.csv".  

### what properties are used? the number of items per property and the coverage of the properties
Cut subject and property part of all the triples.
Sort and delete duplicate item_property group.
Save as "item_property"
```
cut -d ' ' -f 1-2 cleanout/* |sort|uniq > item_property
```
Cut property part of every unique item_property group.
Sort and count unique.
Save as "property_count.csv"
```
cut -d ' ' -f2 item_property|sort|uniq -c|sed 's/ \+/,/g' > property_count.csv
sed -i 's/^,//' property_count.csv
```
Further steps can be found in file "property.ipynb". 
Input: "property_count.csv"
The output "property_coverage.csv" contains three columns "property", "number"(the number of items per property) and "coverage".  
 
 ### how many distinct authors per subject?
Two properties describe subjects of books, namely dct:subject(<http://purl.org/dc/terms/subject>) and dc:subject(<http://purl.org/dc/elements/1.1/subject>).  
Two properties which decreibe authors, namely dct:creator(<http://purl.org/dc/terms/creator>) and marcrel:aut(<http://id.loc.gov/vocabulary/relators/aut>).
First we need to grep tables of items and dctsubject/dcsubject/dctcreator/marcrelaut.
Let's take "dct:subject" as an example. 
Grep all lines with dct:subject(<http://purl.org/dc/terms/subject>).
```
grep -Eh '<http://purl.org/dc/terms/subject>' cleanout/* >dctsubject_triple
```
Replace "<http://purl.org/dc/terms/subject>" with ",,,".
Save the output as "item_dctsubject.csv" with delimiter ",,,".
```
grep -Eh '<http://purl.org/dc/terms/subject>' cleanout/*  >dctsubject_triple
replacement="<http://purl.org/dc/terms/subject>"
sed -e "s@$replacement@,,,@" dctsubject_triple >item_dctsubject.csv
sed -i 's/ .$//' item_dctsubject.csv
```
Follow the same method we can ge "item_dcsubject.csv", "item_dctcreator.csv" ,"item_marcreal.csv".  
We found out "item_dctsubject.csv" and "item_dcsubject.csv" are too large to read as a dataframe in Python. So we split each of them into 3 files, namely   
"item_dctsubjectaa","item_dctsubjectaa","item_dctsubjectaa",  
"item_dcsubjectaa","item_dcsubjectaa","item_dcsubjectaa".  
```
split -l 20000000 item_dctsubject.csv item_dctsubject
```
```
split -l 20000000 item_dcsubject.csv item_dcsubject
```
Further steps can be found in:  
- "number of dctcreator and marcrelaut per dctsubject.ipynb"
input: "item_dctsubjectaa.csv", "item_dctsubjectab.csv", "item_dctsubjectac.csv", "item_dctcreator.csv" ,"item_marcreal.csv"
output: "cre_per_dct.csv", "aut_per_dct.csv"
- "number of dctcreator and marcrelaut per dcsubject.ipynb"
input: "item_dcsubjectaa", "item_dcsubjectab", "item_dcsubjectac", "item_dctcreator.csv" , "item_marcreal.csv"  
output: "cre_per_dc.csv", "aut_per_dc.csv"
