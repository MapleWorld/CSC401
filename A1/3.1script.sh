#!/bin/sh
#java -cp ./WEKA/weka.jar weka.classifiers.functions.SMO -t ./output/train.arff -T ./output/test.arff -o > ./output/3.1/3.1output_svm.txt
#java -cp ./WEKA/weka.jar weka.classifiers.bayes.NaiveBayes -t ./output/train.arff -T ./output/test.arff -o > ./output/3.1/3.1output_bayes.txt
#java -cp ./WEKA/weka.jar weka.classifiers.trees.J48 -t ./output/train.arff -T ./output/test.arff -o > ./output/3.1/3.1output_tree.txt

java -cp /u/cs401/WEKA/weka.jar weka.classifiers.functions.SMO -t ./output/train.arff -T ./output/test.arff -o > ./output/3.1/3.1output_svm.txt
java -cp /u/cs401/WEKA/weka.jar weka.classifiers.bayes.NaiveBayes -t ./output/train.arff -T ./output/test.arff -o > ./output/3.1/3.1output_bayes.txt
java -cp /u/cs401/WEKA/weka.jar weka.classifiers.trees.J48 -t ./output/train.arff -T ./output/test.arff -o > ./output/3.1/3.1output_tree.txt