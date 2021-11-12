#Fazer os Testes de correlação code smells por linhas editadas

#carregar a dbcontagem de code smells e linhas editadas de cada dev

count_lines_TD = dbGetQuery(dbcon, "select author, linesEdited, codeSmells from  DEVS_TD")

#remove quem não tem code smells
count_lines_TD = na.omit(count_lines_TD)

#eliminar os outliers
# Q <- quantile(count_lines_TD$linesEdited, probs=c(.25, .75), na.rm = FALSE)
# iqr <- IQR(count_lines_TD$linesEdited)
# eliminated<- subset(count_lines_TD, count_lines_TD$linesEdited > (Q[1] - 1.5*iqr) & count_lines_TD$linesEdited < (Q[2]+1.5*iqr))
# count_lines_TD = eliminated

#calcular quartis
quantile(count_lines_TD$codeSmells)

#REMOVE  QUARTIL
count_lines_TD = count_lines_TD[count_lines_TD$codeSmells > quantile(count_lines_TD$codeSmells, p = 0.25),]
quantile(count_lines_TD$codeSmells)

#testes
shapiro.test(count_lines_TD$linesEdited)
shapiro.test(count_lines_TD$codeSmells)

wilcox.test(count_lines_TD$linesEdited, count_lines_TD$codeSmells, paired=FALSE)

cor.test(count_lines_TD$linesEdited,count_lines_TD$codeSmells, method = "pearson") 

KLOC = (count_lines_TD$linesEdited)/1000
KTD = (count_lines_TD$codeSmells)/1000

# Creating the plot
plot(KLOC, KTD, pch = 19, ylim = c(0,40), xlim = c(0,250),  col = "lightblue")

#plot(KLOC, KTD, pch = 19, ylim = c(0,40), xlim = c(0,250),  col = "lightblue")

# Regression line
abline(lm(KTD ~ KLOC), col = "red")





