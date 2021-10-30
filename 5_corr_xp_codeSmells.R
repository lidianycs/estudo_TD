#Fazer os Testes de correlação code smells por linhas editadas

#carregar a dbcontagem de code smells e linhas editadas de cada dev

devs_xp_TD = dbGetQuery(dbcon, "SELECT author, xp_in_days, codeSmells FROM DEVS_TD")

#remove quem não tem code smells
devs_xp_TD = na.omit(devs_xp_TD)

#quem fez apenas um commit, considera como 1 dia?
devs_xp_TD["xp_in_days"][devs_xp_TD["xp_in_days"] == 0] <- 1



#eliminar os outliers
# Q <- quantile(devs_xp_TD$xp_in_days, probs=c(.25, .75), na.rm = FALSE)
# iqr <- IQR(devs_xp_TD$xp_in_days)
# eliminated<- subset(devs_xp_TD, devs_xp_TD$xp_in_days > (Q[1] - 1.5*iqr) & devs_xp_TD$xp_in_days < (Q[2]+1.5*iqr))
# devs_xp_TD = eliminated

#calcular quartis
quantile(devs_xp_TD$codeSmells)

#REMOVE  QUARTIL
devs_xp_TD = devs_xp_TD[devs_xp_TD$codeSmells > quantile(devs_xp_TD$codeSmells, p = 0.25),]
quantile(devs_xp_TD$codeSmells)

#testes
shapiro.test(devs_xp_TD$xp_in_days)
shapiro.test(devs_xp_TD$codeSmells)

wilcox.test(devs_xp_TD$xp_in_days, devs_xp_TD$codeSmells, paired=FALSE)

cor.test(devs_xp_TD$xp_in_days,devs_xp_TD$codeSmells, method = "pearson") 

KXP_DAYS = (devs_xp_TD$xp_in_days)
KTD = (devs_xp_TD$codeSmells)

# Creating the plot
plot(KXP_DAYS, KTD,  pch = 19, col = "lightblue")

# Regression line
abline(lm(KTD ~ KXP_DAYS), col = "red")
