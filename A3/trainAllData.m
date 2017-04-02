% Code to run in command line in parallel
%{
matlab -r 'try myTrainFn(8, 3, 0.6, 14); catch; end; quit'
matlab -r 'try myTrainFn(8, 3, 0.6, 7); catch; end; quit'
matlab -r 'try myTrainFn(8, 3, 0.3, 14); catch; end; quit'
matlab -r 'try myTrainFn(8, 3, 0.3, 7); catch; end; quit'

matlab -r 'try myTrainFn(8, 5, 0.6, 14); catch; end; quit'
matlab -r 'try myTrainFn(8, 5, 0.6, 7); catch; end; quit'
matlab -r 'try myTrainFn(8, 5, 0.3, 14); catch; end; quit'
matlab -r 'try myTrainFn(8, 5, 0.3, 7); catch; end; quit'

matlab -r 'try myTrainFn(4, 3, 0.6, 14); catch; end; quit'
matlab -r 'try myTrainFn(4, 3, 0.6, 7); catch; end; quit'
matlab -r 'try myTrainFn(4, 3, 0.3, 14); catch; end; quit'
matlab -r 'try myTrainFn(4, 3, 0.3, 7); catch; end; quit'

matlab -r 'try myTrainFn(4, 5, 0.6, 14); catch; end; quit'
matlab -r 'try myTrainFn(4, 5, 0.6, 7); catch; end; quit'
matlab -r 'try myTrainFn(4, 5, 0.3, 14); catch; end; quit'
matlab -r 'try myTrainFn(4, 5, 0.3, 7); catch; end; quit'
%}

% Change in proportion and dimensionaility
myTrainFn(8, 3, 0.6, 14);
myTrainFn(8, 3, 0.6, 7);
myTrainFn(8, 3, 0.3, 14);
myTrainFn(8, 3, 0.3, 7);

% Change in number of state, proportion and dimensionaility
myTrainFn(8, 5, 0.6, 14);
myTrainFn(8, 5, 0.6, 7);
myTrainFn(8, 5, 0.3, 14);
myTrainFn(8, 5, 0.3, 7);

% Change in mixture size, proportion and dimensionaility
myTrainFn(4, 3, 0.6, 14);
myTrainFn(4, 3, 0.6, 7);
myTrainFn(4, 3, 0.3, 14);
myTrainFn(4, 3, 0.3, 7);

% Change in mixture size, number of state, , proportion and dimensionaility
myTrainFn(4, 5, 0.6, 14);
myTrainFn(4, 5, 0.6, 7);
myTrainFn(4, 5, 0.3, 14);
myTrainFn(4, 5, 0.3, 7);