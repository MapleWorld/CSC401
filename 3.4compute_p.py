from scipy import stats

if __name__ == "__main__":
    
    Bayes = [0.600909, 0.600909, 0.589091, 0.606364, 0.600909, 0.591818, 0.606364, 0.622727, 0.602727, 0.603636]
    SVM = [0.627273, 0.636364, 0.629091, 0.619091, 0.604545, 0.600909, 0.612727, 0.647273, 0.629091, 0.627273]
    Decision_Tree = [0.595455, 0.575455, 0.570909, 0.614545, 0.588182, 0.562727, 0.590909, 0.619091, 0.605455, 0.595455]
    
    S = stats.ttest_rel(Bayes, SVM)
    print "Bayes VS SVM: " + str(S.pvalue)
    
    S = stats.ttest_rel(Bayes, Decision_Tree)
    print "Bayes VS Decision Tree: " + str(S.pvalue)
    
    S = stats.ttest_rel(SVM, Decision_Tree)
    print "SVM VS Decision Tree: " + str(S.pvalue)