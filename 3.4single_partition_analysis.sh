#!/bin/bash

start=0
end=10

for (( i=$start; i<$end; i++ ))
    do
        java -cp ./WEKA/weka.jar weka.classifiers.bayes.NaiveBayes -t ./output/3.4/train_merge_$i.arff -T ./output/3.4/train_single_$i.arff -o > ./output/3.4/single_partition_analysis_output_bayes_$i.txt
        java -cp ./WEKA/weka.jar weka.classifiers.functions.SMO -t ./output/3.4/train_merge_$i.arff -T ./output/3.4/train_single_$i.arff -o > ./output/3.4/single_partition_analysis_output_svm_$i.txt
        java -cp ./WEKA/weka.jar weka.classifiers.trees.J48 -t ./output/3.4/train_merge_$i.arff -T ./output/3.4/train_single_$i.arff -o > ./output/3.4/single_partition_analysis_output_tree_$i.txt
done
