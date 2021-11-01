##########################

# Calcular a correlação entre frequencia / quantidade de commits e codesmells
#por dev em cada projeto

##########################

#carregar a contagem de code smells e linhas editadas de cada dev

devs_xp_TD = dbGetQuery(dbcon, "SELECT author, projectID, codeSmells, xp_in_days, n_commits FROM DEVS_TD")

#remove quem não tem code smells
devs_xp_TD = na.omit(devs_xp_TD)

#quem fez apenas um commit, considera como 1 dia?
devs_xp_TD["xp_in_days"][devs_xp_TD["xp_in_days"] == 0] <- 1

#calcular quartis
quantile(devs_xp_TD$xp_in_days)

devs_xp_TD = devs_xp_TD[devs_xp_TD$xp_in_days > quantile(devs_xp_TD$xp_in_days, p = 0.25),]
quantile(devs_xp_TD$devs_xp_TD)

devs_xp_TD$avg_freq_commits = devs_xp_TD$n_commits / devs_xp_TD$xp_in_days

#testes
shapiro.test(devs_xp_TD$avg_freq_commits)
shapiro.test(devs_xp_TD$codeSmells)

wilcox.test(devs_xp_TD$avg_freq_commits, devs_xp_TD$codeSmells, paired=FALSE)

cor.test(devs_xp_TD$n_commits,devs_xp_TD$codeSmells, method = "pearson") 

n_commits = (devs_xp_TD$n_commits)/1000
KTD = (devs_xp_TD$codeSmells)/1000

# Creating the plot
plot(n_commits, KTD,  pch = 19, col = "lightblue")

# Regression line
abline(lm(KTD ~ n_commits), col = "red")
