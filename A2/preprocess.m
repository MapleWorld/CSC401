function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French)
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz

global CSC401_A2_DEFNS

% first, convert the input sentence to lower-case and add sentence marks
inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

% trim whitespaces down
inSentence = regexprep( inSentence, '\s+', ' ');

% initialize outSentence
outSentence = inSentence;

% perform language-agnostic changes
% TODO: your code here
%    e.g., outSentence = regexprep( outSentence, 'TODO', 'TODO');

% separate punctuations
outSentence = regexprep(outSentence, '([^\s])([^\w\s''])', '$1 $2');
outSentence = regexprep(outSentence, '(\s)([^\w\s''])(\w)', '$1$2 $3');
% separate dashes
outSentence = regexprep(outSentence, '(\w+)(-)(\w+)', '$1 $2 $3');
% separate sentence end
outSentence = regexprep(outSentence, '([^\s])([^\w\s'']+) SENTEND', '$1 $2 SENTEND');

switch language
    case 'e'
        % TODO: your code here
        % Separate clitics
        outSentence = regexprep(outSentence, '(\<\w+)(n''t)', '$1 $2');
        outSentence = regexprep(outSentence, '(\<\w+)(''s)', '$1 $2');
        outSentence = regexprep(outSentence, '(\<\w+)(''m)', '$1 $2');
        outSentence = regexprep(outSentence, '(\<\w+)(''ve)', '$1 $2');
        outSentence = regexprep(outSentence, '(\<\w+)(''d)', '$1 $2');
        outSentence = regexprep(outSentence, '(\<\w+)(''ll)', '$1 $2');
    case 'f'
        
        % TODO: your code here
        % Seperate leading l' from concatenated word
        outSentence = regexprep(outSentence, '(\<l'')(\w+)', '$1 $2');
        
        % Seperate leading consonant and apostrophe from concatenated word
        outSentence = regexprep(outSentence, '\<([a-z])''([a-z])', '$1'' $2');
        
        % Seperate leading qu' from concatenated word
        outSentence = regexprep(outSentence, '(\<qu'')(\w+)', '$1 $2');
        
        % Separate following on or il from puisque and lorsque
        outSentence = regexprep(outSentence, '(\<puisqu'')([on|il])', '$1 $2');
        outSentence = regexprep(outSentence, '(\<lorsqu'')([on|il])', '$1 $2');
        
        % Put back togther the following words
        % d'abord d'accord d'ailleurs d'habitude
        outSentence = regexprep(outSentence, '(\<d'')(abord|accord|ailleurs|habitude)\>', '$1$2');
        
end

% trim extra whitespace again as we may have added excess spaces
outSentence = regexprep( outSentence, '\s+', ' ');
% change unpleasant characters to codes that can be keys in dictionaries
outSentence = convertSymbols( outSentence );

