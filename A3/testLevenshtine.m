
hypothesis = './Testing/hypotheses.txt';
annotation_dir = './Testing';

gg = Levenshtein(hypothesis, annotation_dir);
disp(gg);

%Levenshtein_test(hypothesis,annotation_dir);
%disp('yolo');
%Levenshtein_test2(hypothesis,annotation_dir);
