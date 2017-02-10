import re
import os
import sys
import csv
import string
import NLPlib
import itertools


def main():
    
    count = 0
    class_count = [0, 0, 0, 0, 0]
    tweet_list = [[],[], [], [], []]
    
    # Find the index where the tweet starts in the arff file
    with open("./train.arff", "r") as input:
        for row in input:
            if not row.startswith('@') and not row.startswith('\n'):
                break
            count += 1
           
    # Store all tweets in a list
    with open("./output/train.arff", "r") as input:
        for row in itertools.islice(input, count, count + 20000):
            if (check_class(row) == 0):
                tweet_list[0].append(row)
                class_count[0] += 1
            else:
                tweet_list[4].append(row)
                class_count[4] += 1
                
    # Create 10 single partition train sets with equal positive and negative
    partition_lst = []
    
    for t in range(0, 10):    
        partition_lst.append(fetch_thousand_positive_negative_tweets(tweet_list, t))        

    # Build the 10 single partition train arff files
    for t in range(0, 10):
        output_file_name = "./output/3.4/train_single_" + str(t) + ".arff"
        with open(output_file_name, "w") as output_file:
            write_attributes(output_file)
            for row in partition_lst[t]:
                output_file.write(row)
 
    # Create 10 merged partition train sets with equal positive and negative
    merged_partition_lst = []
    
    for x in range(0, 10):
        temp_lst = []
        for y in range(0, 10):
            if x != y:
                temp_lst.append(partition_lst[y])
      
        flattened = [val for sublist in temp_lst for val in sublist]
        merged_partition_lst.append(flattened)
    
    # Build the 10 merged partition train arff files
    for t in range(0, 10):
        output_file_name = "./output/3.4/train_merge_" + str(t) + ".arff"
        with open(output_file_name, "w") as output_file:
            write_attributes(output_file)
            for row in merged_partition_lst[t]:
                output_file.write(row)
        
def fetch_thousand_positive_negative_tweets(tweet_list, t):
    
    lst = []
    index = t * 1000
    
    for i in range(0, 1000):
        lst.append(tweet_list[0][index])
        index += 1

    index = t * 1000
    for i in range(0, 1000):
        lst.append(tweet_list[4][index])
        index += 1
        
    return lst
        
def check_class(line):
    if line[-2] == "0":
        return 0
    else:
        return 4
        
            
# Manually write the attribute and relation header to the output file
def write_attributes(output_file):
    file_name = os.path.basename(output_file.name)
    output_file.write("@relation " + file_name + "\n")
    output_file.write("@attribute first_person_pronouns numeric\n")
    output_file.write("@attribute second_person_pronouns numeric\n")
    output_file.write("@attribute 3rd_person_pronoun numeric\n")
    output_file.write("@attribute third_person_pronouns numeric\n")
    output_file.write("@attribute past_tense_verbs numeric\n")
    output_file.write("@attribute future_tense_verbs numeric\n")
    output_file.write("@attribute commas numeric\n")
    output_file.write("@attribute colons numeric\n")
    output_file.write("@attribute dashes numeric\n")
    output_file.write("@attribute parentheses numeric\n")
    output_file.write("@attribute ellipses numeric\n")
    output_file.write("@attribute common_nouns numeric\n")
    output_file.write("@attribute proper_nouns numeric\n")
    output_file.write("@attribute adverbs numeric\n")
    output_file.write("@attribute wh_words numeric\n")
    output_file.write("@attribute slang_acronyms numeric\n")
    output_file.write("@attribute upper_case_words numeric\n")
    output_file.write("@attribute sentence_length numeric\n")
    output_file.write("@attribute token_length numeric\n")
    output_file.write("@attribute number_sentences numeric\n\n")
    output_file.write("@attribute class {0, 4}\n\n")
    output_file.write("@data\n")
    
    
if __name__ == "__main__":
    main()