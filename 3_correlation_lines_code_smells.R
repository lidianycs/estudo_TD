#Fazer os Testes de correlação

#carregar a contagem de code smells e linhas editadas de cada dev
sql_query = tbl(con, sql("select * from  COUNT_LINES_TD"))
count_lines_TD = as.data.frame(sql_query)
count_lines_TD[is.na(count_lines_TD)] = 0

#count_lines_TD = na.omit(count_lines_TD)

#eliminar os outliers
# Q <- quantile(count_lines_TD$linesEdited, probs=c(.25, .75), na.rm = FALSE)
# iqr <- IQR(count_lines_TD$linesEdited)
# eliminated<- subset(count_lines_TD, count_lines_TD$linesEdited > (Q[1] - 1.5*iqr) & count_lines_TD$linesEdited < (Q[2]+1.5*iqr))
# count_lines_TD = eliminated

#calcular quartis
quantile(count_lines_TD$codeSmells)

#REMOVE  QUARTIL
count_lines_TD = count_lines_TD[count_lines_TD$codeSmells > quantile(count_lines_TD$codeSmells, p = 0.5),]
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

# Regression line
abline(lm(KTD ~ KLOC), col = "red")

# Pearson correlation
text(paste("Correlation:", round(cor(x, y), 2)), x = 25, y = 95)

hist(KLOC,
     xlab = "Lines edited",
     main = "Histogram of Lines edited",
     breaks = 500
) #


