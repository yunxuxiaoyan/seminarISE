
#1. create a dictionary in folder ISEdata
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
