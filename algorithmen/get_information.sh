#find candidate items 
#input: file itemuri.txt output: folder itemcandidate (1000 files for 1000 target items)
mkdir itemcandidate
for i in $(cat itemuri); 
do
j=$(echo ${i:27:11})
curl -G 'http://192.168.146.1:9999/blazegraph/namespace/data00/sparql' \
     --header "Accept: text/csv"  \
     --data-urlencode query=' PREFIX  dct:<http://purl.org/dc/terms/>
SELECT ?can WHERE {
                                     '$i'  dct:subject ?dctsubject.
                                     ?can dct:subject ?dctsubject.
                                    '$i' dct:language  ?lan1.
                                    ?can dct:language ?lan1.
                                    }'  >itemcandidate/$j
done
for file in itemcandidate/*;do
sed -i  '/./{s/^/<&/;s/$/&>/}' $file  
sed -i '1d' $file
done

#get target item information
#input:file itemuri.txt ourput:folder iteminfo (1000 files for 1000 target items)
mkdir iteminfo
for i in $(cat itemuri);do
j=$(echo ${i:27:11})
grep -Eh '^'$i'' data1208.nt |cut -d ' ' -f 2- > iteminfo/$j
done
mkdir caninfo
for file in itemcandidate/*;do
filename=$(basename $file)
awk -F ' '  'FNR==NR {hash[$1]; next} $1 in hash' $file data1208.nt > caninfo/$filename
done

#get author information for target and candidate
#get item author 
mkdir itemwiki
for i in $(cat itemuri);do
j=$(echo ${i:27:11})
grep -Eh '^'$i'' gndinfo.csv |cut -d ',' -f4- > itemwiki/$j
done
#add 
for file in itemwiki/*;do
sed -i '/./{s/^/<&/;s/$/&>/}' $file
done
#get can author(allline)
mkdir canwikiallline
for file in itemcandidate/*;do
filename=$(basename $file) 
awk -F ','  'FNR==NR {hash[$1]; next} $1 in hash' $file gndinfo.csv  >canwikiallline/$filename
done
#get can author(only)
mkdir canwikionly
for file in canwikiallline/*;do
filename=$(basename $file)
cut -d ',' -f4 $file >canwikionly/$filename
done
#add
for file in canwikionly/*;do
sed -i '/./{s/^/<&/;s/$/&>/}' $file
done
#get can author(with can)
mkdir temp
for file in canwikiallline/*;do
filename=$(basename $file)
cut -d ',' -f1 $file >temp/$filename
done
#paste
mkdir canwikiwith
for file in temp/*;do
filename=$(basename $file)
paste $file canwikionly/$filename >canwikiwith/$filename
done

#get author information
#get target item author information
mkdir itemautinfo
for file in itemwiki/*;do
filename=$(basename $file)
awk -F ' '  'FNR==NR {hash[$1]; next} $1 in hash' $file authorwiki.nt > itemautinfo/$filename
done
mkdir itemautprop
for file in itemautinfo/*;do
filename=$(basename $file)
cut -d " " -f 2- $file >itemautprop/$filename
done
#get candidate author information
mkdir canautuniq
for file in canwikionly/*;do
filename=$(basename $file)
sort $file|uniq > canautuniq/$filename
done
mkdir canautinfo
for file in canautuniq/*;do
filename=$(basename $file)
awk -F ' '  'FNR==NR {hash[$1]; next} $1 in hash' $file authorwiki.nt > canautinfo/$filename
done

#construct one sheet of item
mkdir sheet
for i in $(cat itemuri);do
grep -Eh '^'$i'' data1208.nt |grep -Eh '<http://purl.org/dc/elements/1.1/title>|<http://purl.org/dc/terms/issued>|<http://purl.org/dc/terms/publisher>|<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>' >> sheet/itemsheetinfo
done
#replace
sed -i 's&\^\^<http://www.w3.org/2001/XMLSchema#gYear> &&' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Document> #Document#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/dc/dcmitype/Text> #Text#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Book> #Book#' sheet/itemsheetinfo
sed -i 's#<http://xmlns.com/foaf/0.1/Document> #Ducument#' sheet/itemsheetinfo 
sed -i 's#<http://purl.org/ontology/bibo/Website> #Website#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Thesis> #Thesis#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Article> #Article#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/dc/dcmitype/Software> #Software#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Collection> #Collection#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/MultiVolumeBook> #Multi_volume_Book#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Periodical> #Periodical#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Proceedings> #Proceedings#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Series> #Series#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Map> #Map#' sheet/itemsheetinfo
sed -i 's#<http://rdvocab.info/termList/RDAMediaType/1002> #RDA_Media_Type#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/AudioDocument> #Audio_Document#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/AudioVisualDocument> #Audio_Visual_Document#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Manuscript> #Manuscript#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Report> #Report#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Newspaper> #Newspaper#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/dc/dcmitype/Collection> #Collection#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/ontology/bibo/Image> #Image#' sheet/itemsheetinfo
sed -i 's#<http://purl.org/library/BrailleBook> #Braille_Book#' sheet/itemsheetinfo
#generate iteminfosheet without author 
sed 's/ /,,,/2'  sheet/itemsheetinfo |awk 'BEGIN{FS=OFS=",,,"} {a[$1]=($1 in a ? a[$1] " " : "") $2} END{for (i in a) print i, a[i]}'|sort > sheet/testline
sed -i 's/ /,,,/'  sheet/testline
awk -v FS=",,," '{a[$1,$2]=$3; count[$1]; indic[$2]} END {for (j in indic) printf " ,,, %s", j; printf "\n"; for (i in count) {printf "%s ", i; for (j in indic) printf " ,,, %s", a[i,j]; printf "\n"}}' sheet/testline > sheet/itemsheetline






