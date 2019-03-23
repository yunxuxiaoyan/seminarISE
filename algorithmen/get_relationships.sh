#get r1
mkdir relation
curl -o relation/s1p1s2 \
     -G 'http://192.168.146.1:9999/blazegraph/namespace/data00/sparql' \
     --header "Accept: text/csv"  \
     --data-urlencode query='
 SELECT ?s1 ?p1 ?s2 WHERE {
                  ?s2 <http://purl.org/dc/terms/subject> ?subject2.
                  ?s1 ?p1 ?s2.}'
sed 's/^.//' itemuri > newitemuri
sed -i 's/.$//' newitemuri
grep -f newitemuri relation/s1p1s2 >relation/news1p1s2
sort relation/news1p1s2 |uniq >relation/uniqs1p1s2
mkdir relation/tempr1
for i in $(cat newitemuri);do
j=$(echo ${i:26:11})
grep -Eh ''$i'' relation/uniqs1p1s2 >relation/tempr1/$j
done
mkdir relation/r1
for file in relation/tempr1/*;do 
filename=$(basename $file)
grep -f itemcandidate/$filename $file >relation/r1/$filename
done
for file in relation/r1/*;do
filename=$(basename $file)
j='http://lod.b3kat.de/title/'$filename''
sed -i 's#'$j'# #g' $file
done 
#relation1
mkdir relation/cut12
mkdir relation/cut23
for file in relation/r1/*;do
filename=$(basename $file)
cut -d ',' -f 1,2 $file >relation/cut12/$filename 
cut -d ',' -f 2,3 $file >relation/cut23/$filename
done
mkdir relation/newc12
for file in relation/cut12/*;do
filename=$(basename $file)
grep -v ' ' $file >relation/newc12/$filename
done
mkdir relation/newc23
for file in relation/cut23/*;do
filename=$(basename $file)
grep -v ' ' $file >relation/newc23/$filename
done
for file in relation/newc23/*;do
filename=$(basename $file)
cut -d ',' -f 1 $file >newc23/c1/c1_$filename
cut -d ',' -f 2 $file >newc23/c2/c2_$filename
done 
for file in newc23/c1/*;do
sed -i '/./{s/^/<&/;s/$/&>/}' $file 
done
for file in newc23/c2/*;do
sed -i 's/\(.*\)\r/<\1>/g' $file
done
mkdir relation/c23
for file in newc23/c2/*;do
filename=$(basename $file)
j=$(echo ${filename:3:11})
paste $file newc23/c1/c1_$j >relation/c23/$j
done 
mkdir relation/c12
for file in relation/newc12/*;do
filename=$(basename $file)
cut -d ',' -f 1 $file >relation/c12/c1_$filename 
cut -d ',' -f 2 $file >relation/c12/c2_$filename
done
for file in relation/c12/*;do
filename=$(basename $file)
cat $file relation/c23/$filename >relation/relation1/$filename
done

#get relation2
mkdir relation/relation2
for file in iteminfo/*;do
filename=$(basename $file)
grep -f $file caninfo/$filename |cut -d " " -f 1-2 > relation/relation2/$filename
done

#get r3
for file in itemwiki/*;
do    
  filename=$(basename $file)
  while read line;
  do 
    grep "$line" a1p1a2.txt > grepauthor/$filename;
    while read autline;
    do
      canaut="$(cut -d' ' -f2 <<< $autline)"
      if [ "$canaut" == "$line" ];then
        echo $line $autline "same">> output/output_$filename
      else
        result="$(cat grepauthor/$filename | grep "$canaut"|cut -d " " -f2)"
        if [[ ! -z "$result" ]];then
            echo $line $autline $result >> output/output_$filename 
        fi   
      fi

    done < canwikiwith/$filename
  done < itemwiki/$filename
done
#r3 remove same
mkdir relation/relation3
for file in relation/r3/*;do
filename=$(basename $file)
grep -v 'same' $file |cut -d ' ' -f 2,4  >relation/relation3/$filename
done
#replace
mkdir replace/replace3
for file in relation/relation3/*;do
filename=$(basename $file)
awk 'FNR==NR { array[$1]=$2; next } { for (i in array) gsub(i, array[i]) }1' dic_author_sort  $file > replace/replace3/$filename
done


#get r4
mkdir relation/r4
for file in itemautprop/*;do
filename=$(basename $file)
grep -f $file canautinfo/$filename |cut -d " " -f 1-2 > relation/r4/$filename
done
#replace author with item
mkdir canwikisort_c2
for file in canwikiwith/*;do
filename=$(basename $file)
sort -k2 $file > canwikisort_c2/$filename
done
#sort r4 according to authoruri
mkdir relation/sortr4_c1
for file in relation/r4/*;do
filename=$(basename $file)
sort $file >relation/sortr4_c1/$filename
done
#merge 
mkdir relation/relation4
for file in relation/sortr4_c1/*;do
filename=$(basename $file)
join -1 2  -2 1 -o 1.1 2.2 canwikisort_c2/$filename $file >relation/relation4/$filename
done
