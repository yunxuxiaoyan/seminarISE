
#1. create a dictionary
sed -i 's/,/ /g' final_item_weight.csv  >dic_item
sort dic_item >dic_item_sort
sed -i 's/,/ /g' final_author_weight.csv >dic_author
sort dic_author >dic_author_sort

#replace the properties with points
mkdir replace
mkdir replace/replace1
for file in relation/relation1/*;do
filename=$(basename $file)
awk 'FNR==NR { array[$1]=$2; next } { for (i in array) gsub(i, array[i]) }1' dic_item_sort  $file > replace/replace1/$filename
done
#sort relation2 according to prop 
mkdir relation/sort2_c2
for file in relation/relation2/*;do
filename=$(basename $file)
j=$(echo ${filename:0:11})
sort -k2 $file >relation/sort2_c2/$j
done
mkdir replace/replace2
for file in relation/sort2_c2/*;do
filename=$(basename $file)
join -1 2 -2 1 -t ' ' -o 1.1 2.2 $file dic_item_sort >replace/replace2/$filename
done
#sort relation4 according to prop
mkdir relation/sort4_c2
for file in relation/relation4/*;do
filename=$(basename $file)
sort -k2 $file >relation/sort4_c2/$filename
done
mkdir replace/replace4
for file in relation/sort4_c2/*;do
filename=$(basename $file)
join -1 2 -2 1 -t ' ' -o 1.1 2.2 $file dic_author_sort >replace/replace4/$filename
done

mkdir replace/replace1234
for file in replace/replace1/*;do
filename=$(basename $file)
cat $file replace/replace2/$filename replace/replace3/$filename replace/replace4/$filename >replace/replace1234/$filename
done

#3. sum the points based on URIs
mkdir result
mkdir result/sum
for file in replace/replace1234/*;do
filename=$(basename $file)
awk '{s[$1] += $2}END{ for(i in s){  print i, s[i] } }' $file >result/sum/$filename
done
#get 400result
mkdir result/top400result
for file in result/sum/*;do
filename=$(basename $file)
sort -r -t " " -k2 -g $file | head -400 >result/top400result/$filename
done
mkdir result/top400can
for file in result/sum/*;do
filename=$(basename $file)
sort -r -t " " -k2 -g $file | head -400 |cut -d " " -f1 >result/top400can/$filename
done

mkdir sheet/top400caninfo
for file in result/top400can/*;do
filename=$(basename $file)
grep -f $file caninfo/$filename | grep -Eh '<http://purl.org/dc/elements/1.1/title>|<http://purl.org/dc/terms/issued>|<http://purl.org/dc/terms/publisher> |<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>' >sheet/top400caninfo/$filename
done

for file in sheet/top400caninfo/*;do
sed -i 's&\^\^<http://www.w3.org/2001/XMLSchema#gYear> &&' $file
sed -i 's#<http://purl.org/ontology/bibo/Document> #Document#' $file
sed -i 's#<http://purl.org/dc/dcmitype/Text> #Text#' $file
sed -i 's#<http://purl.org/ontology/bibo/Book> #Book#' $file
sed -i 's#<http://xmlns.com/foaf/0.1/Document> #Ducument#' $file 
sed -i 's#<http://purl.org/ontology/bibo/Website> #Website#' $file
sed -i 's#<http://purl.org/ontology/bibo/Thesis> #Thesis#' $file
sed -i 's#<http://purl.org/ontology/bibo/Article> #Article#' $file
sed -i 's#<http://purl.org/dc/dcmitype/Software> #Software#' $file
sed -i 's#<http://purl.org/ontology/bibo/Collection> #Collection#' $file
sed -i 's#<http://purl.org/ontology/bibo/MultiVolumeBook> #Multi_volume_Book#' $file
sed -i 's#<http://purl.org/ontology/bibo/Periodical> #Periodical#' $file
sed -i 's#<http://purl.org/ontology/bibo/Proceedings> #Proceedings#' $file
sed -i 's#<http://purl.org/ontology/bibo/Series> #Series#' $file
sed -i 's#<http://purl.org/ontology/bibo/Map> #Map#' $file
sed -i 's#<http://rdvocab.info/termList/RDAMediaType/1002> #RDA_Media_Type#' $file
sed -i 's#<http://purl.org/ontology/bibo/AudioDocument> #Audio_Document#' $file
sed -i 's#<http://purl.org/ontology/bibo/AudioVisualDocument> #Audio_Visual_Document#' $file
sed -i 's#<http://purl.org/ontology/bibo/Manuscript> #Manuscript#' $file
sed -i 's#<http://purl.org/ontology/bibo/Report> #Report#' $file
sed -i 's#<http://purl.org/ontology/bibo/Newspaper> #Newspaper#' $file
sed -i 's#<http://purl.org/dc/dcmitype/Collection> #Collection#' $file
sed -i 's#<http://purl.org/ontology/bibo/Image> #Image#' $file
sed -i 's#<http://purl.org/library/BrailleBook> #Braille_Book#' $file
done

mkdir sheet/top400caninfotemp1
for file in sheet/top400caninfo/*;do
filename=$(basename $file)
sed 's/ /,,,/2'  $file |awk 'BEGIN{FS=OFS=",,,"} {a[$1]=($1 in a ? a[$1] " " : "") $2} END{for (i in a) print i, a[i]}'|sort > sheet/top400caninfotemp1/$filename
done

mkdir sheet/top400caninfotemp2
for file in sheet/top400caninfotemp1/*;do
filename=$(basename $file)
sed -i 's/ /,,,/'  $file
awk -v FS=",,," '{a[$1,$2]=$3; count[$1]; indic[$2]} END {for (j in indic) printf " ,,, %s", j; printf "\n"; for (i in count) {printf "%s ", i; for (j in indic) printf " ,,, %s", a[i,j]; printf "\n"}}' $file > sheet/top400caninfotemp2/$filename
done

for file in sheet/top400caninfotemp2/*;do
sed -i '1d' $file
done

#find candidate items 
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

#get author label

mkdir canwikiwith_sort
for file in canwikiwith/*;do
filename=$(basename $file)
sort -k2 $file >canwikiwith_sort/$filename
done

mkdir sheet/canautlabel
for file in canwikisort_c2/*;do
filename=$(basename $file)
join -1 2 -2 1 $file author_label_sort >sheet/canautlabel/$filename
done

mkdir sheet/canautlabeltemp
for file in sheet/canautlabel/*;do
filename=$(basename $file)
cut -d " " -f2- $file >sheet/canautlabeltemp/$filename
done

for file in sheet/canautlabeltemp/*;do
sed -i -e 's/$/./' $file
done

mkdir sheet/canautlabelnew
for file in sheet/canautlabeltemp/*;do
filename=$(basename $file)
sed 's/ /,,,/1'  $file |awk 'BEGIN{FS=OFS=",,,"} {a[$1]=($1 in a ? a[$1] " " : "") $2} END{for (i in a) print i, a[i]}'|sort > sheet/canautlabelnew/$filename
done

mkdir sheet/top400autlabel
for file in result/top400can/*;do
filename=$(basename $file)
grep -f $file sheet/canautlabelnew/$filename >sheet/top400autlabel/$filename
done




