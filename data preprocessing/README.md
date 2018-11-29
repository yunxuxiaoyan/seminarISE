# data pre-processing
This file presents detail data preprocessing step of the book recommender.
There are in total 30 original turtle files in the dataset, which can be downloaded in https://lod.b3kat.de/doc/download/.
We shorten the name of the original files as "part0.ttl" to "part30.ttl".

## how many books per category?
There are two properties describe the cateagories of books, namely dc:subject and dct:subject.
First, grep all lines containing"dc:subject"/"dct;subject" save as "dc:subject" and "dctsubject"
```
grep -Eh 'dc:subject' * >dcsubject
```
```
grep -Eh 'dct:subject' * >dctsubject
```

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
