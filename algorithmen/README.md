# process-data-in-blazegraph
## 1. upload item dataset in blazegraph 
>There were two lines which doesn't match the N-triple format, and had to be modified. <br>
>> line 31739563, contains a predicate list to a subject<br>
>> line 41849202, contains an unexpected "." in object<br>
>we splited line 31739563 into two lines, and deleted line 41849202.<br> 
```Bash
sed '31739563 i<http://lod.b3kat.de/title/BV025911824> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/ontology/bibo/Book> .' -i data1208.nt
sed '31739562 i<http://lod.b3kat.de/title/BV025911824> <http://purl.org/dc/terms/subject> <http://d-nb.info/gnd/4025243-7> .' -i data1208.nt
sed -i '31739564d' data1208.nt
sed -i '41849202d' data1208.nt
```
`the uoload process totally took 7264933 milliseconds (around 121 minites), and modified 88323860 triples.`

## 2. search for direct links between items in local dataset
With the help of namespace in blazegraph, we can query different graphs with SPARQL. 
```Bash
curl -o pro_btw_item.csv -G 'http://192.168.146.1:9999/blazegraph/namespace/data00/sparql' \
     --header "Accept: text/csv"  \
     --data-urlencode query='
 SELECT ?p WHERE {?s1 <http://purl.org/dc/terms/subject> ?subject1.
                  ?s2 <http://purl.org/dc/terms/subject> ?subject2.
                  ?s1 ?p ?s2}'
```
Then count distinct properties and their coverage 
```Python
result = data['p'].value_counts()
```
`1792308 triples matched, in which 6 distinct properties exist. `<br>
The results are saved in file distinct_pro_btw_items.csv. 

## 3. upload author dataset in blazegraph

# algorithmen with bash command line
>there are three scripts:
>> script get_information.sh describes how to find candidate items, get information about target,candidate items and item authors from dataset

>> script get_relationship.sh describes how to get four kinds of relationships from blazegraph and some further processing of them

>> script get_results.sh describes how to compute the affinity score and get the final recommendation results 
