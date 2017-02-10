# Tweet Tokenize and Tag

import re
import sys
import csv
import string
import NLPlib
import itertools
from HTMLParser import HTMLParser

# Remove html tags and attributes
def twtt1(tweet):
    new_tweet = re.sub(r'<[^>]+>', '', tweet).strip()
    #print "twtt1: " + new_tweet
    return new_tweet

# Replace html name with ASCII    
def twtt2(tweet):
    
    new_tweet = ""
    parser = HTMLParser()
    for char in tweet:
        if (char in string.printable):
            new_tweet += char
            
    new_tweet = parser.unescape(new_tweet)
    #print "twtt2: " + new_tweet
    return new_tweet
  
# Remove URL
def twtt3(tweet):
    case_insensitive = re.compile(r'(http:|www.)\S+', re.IGNORECASE)
    new_tweet = case_insensitive.sub('', tweet).strip()
    #print "twtt3: " + new_tweet
    return new_tweet
    
# Remove the first Twitter username (@) and hash tags
def twtt4(tweet):
    new_tweet = re.sub(r'@\S+', '', tweet, 1).strip()
    new_tweet = re.sub(r'#\S+', '', new_tweet).strip()
    #print "twtt4: " + new_tweet
    return new_tweet

def create_abbrev_set():
    abbrev_set = set()
    
    with open('./language/abbrev.english', 'rb') as abbrevs:
        for line in abbrevs:
            abbrev_set.add(line.strip())
            
    return abbrev_set
    
# split by sentence
def twtt5(tweet):
    '''
        # 1. Anything ending in .?! declared a sentence
        # 2. Sentence boundary moved after quotation mark, if any ex. He said, "I am coming."
        # 3. Period boundary is disqualified if it preceded by an element in abbrev_set
        #    <We could look for capitals after an EOS, but nobody uses capitals on twitter>
        #    <Both sides of :;- could also be thought of as sentence>
    '''
    
    tweet = re.sub(r' +', ' ', tweet).strip()
    
    if 0 == len(tweet): 
        return [tweet]
    
    abbrev_set = create_abbrev_set()
    split_by_space = tweet.split(' ')
    
    new_line = ""
    sentences = []
    
    for word in split_by_space:
        new_line += " " + word
        for puncution in {"?", "!", "."}:
            if (puncution in word):
                for abbrev in abbrev_set:
                    if (abbrev not in word):
                        sentences.append(new_line)
                        new_line = ""
                        break
    
    
    if (new_line != ""):
        sentences.append(new_line)
    
    if (len(sentences) == 0):
        sentences = [tweet]
    
    #print "twtt5:" + ', '.join(sentences) 
    return sentences
 
def twtt7(tweet):
    # 1. Split on all punctuation symbols, where a given symbol is repeated once or more
    sentence_1 = re.sub(r"((["+ string.punctuation + "])\\2*)", r" \1 ", tweet).strip()
    
    # 2. Remove double space
    sentence_2 = ' '.join(sentence_1.split('  '))
    
    # 3. Join clitics and contractions where ' occurs mid-word
    sentence_3 = re.sub(r"(') ([A-Za-z] )", r"\1\2", sentence_2)
    
    # 4. Join e.g.
    sentence_4 = re.sub(r" e . g . ", r" e.g. ", sentence_3)
    
    #print "twtt7: " + sentence_4
    return sentence_4

# Tag Sentence
# Each token is tagged with its part-of-speech.
# A tagged token consists of a word, the `/' symbol, and the tag (e.g., dog/NN)
def twtt8(tweet, tagger):
    word_list = tweet.split(" ")
    tag_list = tagger.tag(word_list)
    result = ' '.join([x[0] + "/" + x[1] for x in zip(word_list, tag_list)])
    #print "twtt8: " + result
    return result

# Before each tweet is demarcation A=# in <> which occurs on its own line
# where # is the numeric class of the tweet (0, or 4).
# The polarity of the tweet (0 = negative emotion, 4 = positive emotion)
def twtt9(tweet, class_type):
    prepend = "<A={}>".format(class_type)
    new_line = [prepend] + tweet
    #print new_line
    return new_line

##### Take in an input file name, and an output file, and a student ID.
# Negative group IDs use all samples available
def twtt(input_file_name, output_file_name, SID):
    
    X = SID % 80
    line_index_list = []
    row_count = sum(1 for row in csv.reader(open(input_file_name)))
    
    tagger = NLPlib.NLPlib()
    if (row_count >= 1600000):
        line_index_list.append([X * 10000, (X + 1) * 10000])
        line_index_list.append([800000 + X * 10000, 800000 + (X + 1) * 10000])
    else:   
        line_index_list.append([0, 20000])
        
    with open(output_file_name, "w") as output_file:
        with open(input_file_name, 'rb') as csvfile:
            
            spamreader = csv.reader(csvfile)
            
            for line_index in line_index_list:
                for row in itertools.islice(spamreader, line_index[0], line_index[1]):
                    tweet = row[5]
                    class_type = int(row[0])
                    new_line = twtt1(tweet)
                    new_line = twtt2(new_line)
                    new_line = twtt3(new_line)
                    new_line = twtt4(new_line)
                    sentences = twtt5(new_line)
                    
                    if len(sentences) > 0:
                        sentences = [twtt7(sentence) for sentence in sentences]
                        sentences = [twtt8(sentence, tagger) for sentence in sentences]
                    
                    sentences = twtt9(sentences, class_type)
                    
                    for sentence in sentences:
                        output_file.write(sentence + '\n')
                        
                    
if __name__ == "__main__":

    #twtt('testdata.manualSUBSET.2009.06.14.csv', './output/test.twt', 999768327)
    #twtt('training.1600000.processed.noemoticon.csv', './output/train.twt', 999768327)
    
    if len(sys.argv) == 4:
        input_file_name = sys.argv[1]
        SID = int(sys.argv[2])
        output_file_name = sys.argv[3]  
        twtt(input_file_name, output_file_name, SID)
    else:
        print "Invalid number of parameters"
        sys.exit()

    # Program arguments
    # python twtt.py /u/cs401/A1/tweets/testdata.manualSUBSET.2009.06.14.csv 999768327 train.twt
    # python twtt.py /u/cs401/A1/tweets/training.1600000.processed.noemoticon.csv 999768327 train.twt

















