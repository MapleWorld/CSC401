run('./code/csc401_a2_defns.m');

% French test
%preprocess('l''election', 'f')
%preprocess('je t''aime', 'f')
%preprocess('qu''on', 'f')
%preprocess('puisqu''on', 'f')
%preprocess('d''abord', 'f')

%lm_train('./Toy','e','part2_test.mat');
%lm_train('./Training','e','part2_english.mat');
%lm_train('./Training','f','part2_french.mat');

%A3_test = load('./part2_test.mat','LM', '-mat');
%LM_t = A3_test.LM;
%disp(LM_t);
%perplexity(LM_t, './Testing', 'e', '', 0)

%A3_english = load('./part2_english.mat','LM', '-mat');
%A3_french = load('./part2_french.mat','LM', '-mat');

%LM_e = A3_english.LM;
%LM_f = A3_french.LM;

%perplexity(LM_e, './Testing', 'e', '', 0);
%perplexity(LM_e, './Testing', 'e', 'smooth', 0.2);
%perplexity(LM_e, './Testing', 'e', 'smooth', 0.4);
%perplexity(LM_e, './Testing', 'e', 'smooth', 0.6);
%perplexity(LM_e, './Testing', 'e', 'smooth', 0.8);
%perplexity(LM_e, './Testing', 'e', 'smooth', 1.0);

%perplexity(LM_f, './Testing', 'f', '', 0);
%perplexity(LM_f, './Testing', 'f', 'smooth', 0.2);
%perplexity(LM_f, './Testing', 'f', 'smooth', 0.4);
%perplexity(LM_f, './Testing', 'f', 'smooth', 0.6);
%perplexity(LM_f, './Testing', 'f', 'smooth', 0.8);
%perplexity(LM_f, './Testing', 'f', 'smooth', 1.0);

%AM = align_ibm1('./Toy/', 3, 5, './part4.mat');
%disp(AM.SENTSTART);
%disp(AM.a);
%disp(AM.b);
%disp(AM.c);
%disp(AM.SENTEND);










