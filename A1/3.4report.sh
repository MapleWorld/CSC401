#!/bin/bash

file_type="bayes"
prefix="./output/3.4/"
train_file_path="./output/3.4/single_partition_analysis_output_"$file_type"_"
output_file=${prefix}"3.4output_"$file_type".txt"

start=0
end=10

for ((i=$start; i<$end; i++))
do
    echo "

Partition $i:" >> $output_file
    tail -n 5 $train_file_path$i.txt >> $output_file
    output=`tail -n 3 $train_file_path$i.txt`
    output_arr=($output)
    

    aa=${output_arr[0]}
    ab=${output_arr[1]}
    ba=${output_arr[6]}
    bb=${output_arr[7]}

    acc=$(awk -v aa=$aa -v bb=$bb -v ab=$ab -v ba=$ba 'BEGIN { print (aa + bb) / (aa + bb + ab + ba) }')
    prec_a=$(awk -v aa=$aa -v ba=$ba 'BEGIN { print aa / (aa + ba) }')
    prec_b=$(awk -v bb=$bb -v ab=$ab 'BEGIN { print bb / (bb + ab) }')
    rec_a=$(awk -v aa=$aa -v ab=$ab 'BEGIN { print aa / (aa + ab) }')
    rec_b=$(awk -v bb=$bb -v ba=$ba 'BEGIN { print bb / (bb + ba) }')

    accuracy_lst[i]=$acc

    echo Accuracy - $acc % >> $output_file
    echo "Precision - A: $prec_a %
            B: $prec_b %" >> $output_file
    echo "Recall - A: $rec_a %
         B: $rec_b %" >> $output_file
    echo $acc,
done

echo "" >> $output_file
echo -n "[" >> $output_file
for ((i=$start; i<$end; i++))
do
    echo -n "${accuracy_lst[i]}, " >> $output_file
done
echo -n "]" >> $output_file
 
