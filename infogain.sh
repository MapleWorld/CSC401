#!/bin/sh
#java -cp ./WEKA/weka.jar weka.attributeSelection.InfoGainAttributeEval -i $1 -s " weka.attributeSelection.Ranker -T -1.7976931348623157E308 -N -1"
java -cp /u/cs401/WEKA/ weka.attributeSelection.InfoGainAttributeEval -i $1 -s " weka.attributeSelection.Ranker -T -1.7976931348623157E308 -N -1"
