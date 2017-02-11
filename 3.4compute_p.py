from scipy import stats

if __name__ == "__main__":
    
    Bayes = [0.6095, 0.5945, 0.571, 0.561, 0.582, 0.596, 0.591, 0.583, 0.6015, 0.5915]
    SVM = [0.622, 0.5955, 0.587, 0.568, 0.5885, 0.599, 0.603, 0.596, 0.6225, 0.6145]
    Decision_Tree = [0.5845, 0.579, 0.574, 0.5645, 0.599, 0.589, 0.608, 0.594, 0.587, 0.587]

    S = stats.ttest_rel(Bayes, SVM)
    print "Bayes VS SVM: " + str(S.pvalue)
    
    S = stats.ttest_rel(Bayes, Decision_Tree)
    print "Bayes VS Decision Tree: " + str(S.pvalue)
    
    S = stats.ttest_rel(SVM, Decision_Tree)
    print "SVM VS Decision Tree: " + str(S.pvalue)