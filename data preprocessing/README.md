# data pre-processing
This file presents detail data preprocessing step of the book recommender.
There are in total 30 original turtle files in the dataset, which can be downloaded in https://lod.b3kat.de/doc/download/.
We shorten the name of the original files as "part0.ttl" to "part30.ttl".

## how many books per category?
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
Further steps can be found in file dctsubject.ipynb.
The output "dctsubject.csv" contains two columns "dctsubject" and "number"(the number of book per dctsubject).
In the same way, we can get "dcsubject.csv".

## transfer the turtle files into n-triple
Let's take "part1.ttl" for an example.
We find out that the file size is too large to transfer, so we seperate part1.ttl into two files "split1aa" and "split1ab".
```
split -l 30000000 part1.ttl split/split1 
```
Since the spliting is based on number of lines, the facts of an item can occur in the end of "splitaa" and the start "splitab". It requires some manual steps to modify the two split files.
check for start lines of "splitab"
'''

'''
