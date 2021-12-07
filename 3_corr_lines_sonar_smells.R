#Fazer os Testes de correlação sonar smells por linhas editadas

library(DBI)
library(RSQLite)
library(dbplyr)
library(dplyr)


#conecta ao BD
dbcon = dbConnect(SQLite(), "DEVS_TD.db") 

#carregar a dbcontagem de code smells e linhas editadas de cada dev

count_lines_TD = dbGetQuery(dbcon, "select author, linesEdited, sonar_smells  from  DEVS_TD")

#remove quem não tem code smells
count_lines_TD = na.omit(count_lines_TD)

#eliminar os outliers
# Q <- quantile(count_lines_TD$linesEdited, probs=c(.25, .75), na.rm = FALSE)
# iqr <- IQR(count_lines_TD$linesEdited)
# eliminated<- subset(count_lines_TD, count_lines_TD$linesEdited > (Q[1] - 1.5*iqr) & count_lines_TD$linesEdited < (Q[2]+1.5*iqr))
# count_lines_TD = eliminated

#calcular quartis
quantile(count_lines_TD$sonar_smells)

#REMOVE  QUARTIL
# count_lines_TD = count_lines_TD[count_lines_TD$sonar_smells > quantile(count_lines_TD$sonar_smells, p = 0.25),]
# quantile(count_lines_TD$sonar_smells)

#testes
shapiro.test(count_lines_TD$linesEdited)
shapiro.test(count_lines_TD$sonar_smells)

wilcox.test(count_lines_TD$linesEdited, count_lines_TD$sonar_smells, paired=FALSE)

cor.test(count_lines_TD$linesEdited,count_lines_TD$sonar_smells, method = "pearson")

KLOC = (count_lines_TD$linesEdited)/1000
TD = (count_lines_TD$sonar_smells)
# Creating the plot
plot(KLOC, TD, pch = 23, ylim = c(0,800), xlim = c(0,800),  col = "black", main = "TD(Sonar Smells) x KLOC")

#plot(KLOC, KTD, pch = 19, ylim = c(0,40), xlim = c(0,250),  col = "lightblue")

# Regression line
abline(lm(TD ~ KLOC), col = "red")





