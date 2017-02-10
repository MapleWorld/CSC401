import os
import re
import sys
import csv
import string
import StringIO
import itertools
import HTMLParser
import numpy as np

'''
Counts:
| First person pronouns (feat1)
| Second person pronouns (feat2)
| Third person pronouns (feat3)
| Coordinating conjunctions (feat4)
| Past-tense verbs (feat5)
| Future-tense verbs (feat6)
| Commas (feat7)
| Colons and semi-colons (feat8)
| Dashes (feat9)
| Parentheses (feat10)
| Ellipses (feat11)
| Common nouns (feat12)
| Proper nouns (feat13)
| Adverbs (feat14)
| wh-words (feat15)
| Modern slang acronyms (feat16)
| Words all in upper case (at least 2 letters long) (feat17)
Average length of sentences (in tokens) (feat18)
Average length of tokens, excluding punctuation tokens (in characters) (feat19)
Number of sentences (feat20)

'''

def split_tweet_into_sentences(tweet):
    tokens = [x.strip().split(' ') for x in tweet]
    return [y.split('/') for x in tokens for y in x]
    
def word_counter(token_split, candidate_words, index):
    
    count = 0
    
    for x in token_split:
        if (x[index].lower() in candidate_words):
            count += 1
            
    return count
    
def first_person_pronouns(token_split):
    candidate_words = ['i', 'me', 'my', 'mine', 'we', 'us', 'our', 'ours']
    return word_counter(token_split, candidate_words, 0)

def second_person_pronouns(token_split):
    candidate_words = ['you', 'your', 'yours', 'u', 'ur', 'urs']
    return word_counter(token_split, candidate_words, 0)
    
def third_person_pronouns(token_split):
    candidate_words = ['he', 'him', 'his', 'she', 'her', 'hers', 'it', 'its', 'they', 'them', 'their', 'theirs']
    return word_counter(token_split, candidate_words, 0)

def coordinating_conjunctions(token_split):
    candidate_words = ['CC']
    return word_counter(token_split, candidate_words, 1)

def past_tense_verbs(token_split):
    candidate_words = ['VBD']
    return word_counter(token_split, candidate_words, 1)

def future_tense_verbs(token_split):
    candidate_words = ["'ll", 'will', 'gonna']
    count = word_counter(token_split, candidate_words, 0)
    
    # Count sequences of going+to+VB
    for i in range(len(token_split) - 2):
        if (token_split[i][0].lower() == "going"):
            if (token_split[i + 1][0].lower() == "to"):
                if (token_split[i + 2][1].lower() == "VB"):
                    count += 1
    
    return count

def commas(token_split):
    candidate_words = [',']
    return word_counter(token_split, candidate_words, 1)

def colons(token_split):
    candidate_words = [':', ';']
    return word_counter(token_split, candidate_words, 0)
    
def dashes(token_split):
    candidate_words = ['-']
    return word_counter(token_split, candidate_words, 0)

def parantheses(token_split):
    candidate_words = ['(', ')']
    return word_counter(token_split, candidate_words, 0)

def ellipses(token_split):
    candidate_words = ['...']
    return word_counter(token_split, candidate_words, 0)
    
def common_nouns(token_split):
    candidate_words = ['NN', 'NNS']
    return word_counter(token_split, candidate_words, 1)

def proper_nouns(token_split):
    candidate_words = ['NNP', 'NNPS']
    return word_counter(token_split, candidate_words, 1)


def adverbs(token_split):
    candidate_words = ['RB', 'RBR', 'RBS']
    return word_counter(token_split, candidate_words, 1)


def wh_words(token_split):
    candidate_words = ['WDT', 'WP', 'WP$', 'WRB']
    return word_counter(token_split, candidate_words, 1)
    
def slang_acronyms(token_split):
    candidate_words = ['smh', 'fwb',  'lmfao', 'lmao', 'lms', 'tbh',  'rofl', 'wtf',
                       'bff', 'wyd',  'lylc',  'brb',  'atm', 'imao', 'sml',  'btw',
                       'bw',  'imho', 'fyi',   'ppl',  'sob', 'ttyl', 'imo',  'ltr',
                       'thx', 'kk',   'omg',   'ttys', 'afn', 'bbs',  'cya',  'ez',
                       'f2f', 'gtr',  'ic',    'jk',   'k',   'ly',   'ya',   'nm',  'np',
                       'plz', 'ru',   'so',    'tc',   'tmi', 'ym',   'ur',   'u',   'sol']
    return word_counter(token_split, candidate_words, 0)
  
# Count words all in upper case (at least 2 letters long) (feat17)
def upper_case_words(token_split):
    
    count = 0
    
    for x in token_split:
        if (x[0].isupper() and len(x[0]) > 1):
            count += 1
            
    return count

# Average length of sentences (in tokens) (feat18)
def sentence_length(sentences, token_split):
    return len(token_split) / float(len(sentences))

# Questionable
# Average length of tokens, excluding punctuation tokens (in characters) (feat19)
def token_length(token_split):
    token_lengths = []
    candidate_words = ['#', '$', '.', ',', ':', '(', ')', '"', 'POS']
    
    for x in token_split:
         if x[1] not in candidate_words:
             token_lengths.append(len(x[0]))
             
    if (len(token_lengths) == 0):
        return 0
        
    return sum(token_lengths) / float(len(token_lengths))

# Number of sentences (feat20)
def number_sentences(sentences):
    return len(sentences)
    
    
def feature_extraction(tweet, class_label):
    
    sentence_list = split_tweet_into_sentences(tweet)
    
    feature_list = []
    feature_list.append(first_person_pronouns(sentence_list))
    feature_list.append(second_person_pronouns(sentence_list)) 
    feature_list.append(third_person_pronouns(sentence_list))
    feature_list.append(coordinating_conjunctions(sentence_list))
    feature_list.append(past_tense_verbs(sentence_list))
    feature_list.append(future_tense_verbs(sentence_list))
    feature_list.append(commas(sentence_list))
    feature_list.append(colons(sentence_list))
    feature_list.append(dashes(sentence_list))
    feature_list.append(parantheses(sentence_list))
    feature_list.append(ellipses(sentence_list))
    feature_list.append(common_nouns(sentence_list))
    feature_list.append(proper_nouns(sentence_list))
    feature_list.append(adverbs(sentence_list))
    feature_list.append(wh_words(sentence_list))
    feature_list.append(slang_acronyms(sentence_list))
    feature_list.append(upper_case_words(sentence_list))
    feature_list.append(sentence_length(tweet, sentence_list))
    feature_list.append(token_length(sentence_list))
    feature_list.append(number_sentences(tweet))
    
    output_str = ', '.join(str(x) for x in feature_list) 
    output_str += ", " + str(class_label) + "\n"
    
    return output_str
    
    
    
def buildarff(input_file, output_file, max_tweet_per_class):
    
    tweet = []
    output_str = ""
    class_label = 0
    class_counters = [-1, 0, 0, 0, 0]
    
    if max_tweet_per_class >= 20000:
        max_tweet_per_class = float("inf")
        
    for line in input_file: 
        if line.startswith('<A='):
            if tweet != []:
                output_str = feature_extraction(tweet, class_label)
                
            tweet = []
            class_label = int(line[3])
            
            if class_counters[class_label] < max_tweet_per_class:
                class_counters[class_label] += 1;
                output_file.write(output_str)
        else:
            tweet.append(line)
            
    output_str = feature_extraction(tweet, class_label)
    if class_counters[class_label] < max_tweet_per_class:
        class_counters[class_label] += 1;
        output_file.write(output_str)
    
    # print "Class Counter:" + class_counters
    
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

# For part 3.2 of the assignment
# Creating training output file with dataset ranging from 500 - 10000
def part_three_two():
    
    max_tweet_per_class = 500
    input_file_name = "./output/train.twt"
    
    while (max_tweet_per_class <= 10000):

        output_file_name = "./output/3.2/train" + str(max_tweet_per_class) + ".arff"
    
        with open(input_file_name, "r") as input:
            with open(output_file_name, "w") as output:
                write_attributes(output)
                buildarff(input, output, max_tweet_per_class)
                
        max_tweet_per_class = max_tweet_per_class + 500
        
    
    
    
if __name__ == "__main__":
    
    #input_file_name = "./output/test.twt"
    #output_file_name = "./output/test.arff"
    #input_file_name = "./output/train.twt"
    #output_file_name = "./output/train.arff"
    
    max_tweet_per_class = float("inf")
    
    if len(sys.argv) == 3:
        input_file_name = sys.argv[1]
        output_file_name = sys.argv[2]
    elif len(sys.argv) == 4:
        input_file_name = sys.argv[1]
        output_file_name = sys.argv[2]  
        max_tweet_per_class = sys.argv[3]
    else:
        print "Invalid number of parameters"
        sys.exit()

    with open(input_file_name, "r") as input:
        with open(output_file_name, "w") as output:
            write_attributes(output)
            buildarff(input, output, max_tweet_per_class)
    
    
    
    
    
    
    
    
    
    
    
    
    
    