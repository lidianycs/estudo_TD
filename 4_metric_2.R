#######################

#Calcular o tempo de exp dos desenvolvedores de um projeto

#######################

library(DBI)
library(RSQLite)
library(dbplyr)
library(dplyr)


#conecta ao BD
dbcon = dbConnect(SQLite(), "TechnicalDebtDataset_20200606.db") 

#pega lista de projetos analisados

project_list = dbGetQuery(dbcon, "SELECT projectID FROM PROJECTS ")
project_list = project_list[["projectID"]]

#pega um projeto (projectID) para analisar
projectID = project_list[15]

start_time <- Sys.time()

for (i in 22:33){
    projectID = project_list[i]
    
    devs_data = dbGetQuery(dbcon, "SELECT author, MAX(authorDate), MIN(authorDate)  
                                      FROM GIT_COMMITS 
                                      WHERE projectID = ? AND merge='False' GROUP BY author"
                                      , params = c(projectID))

    #renomear colunas
    colnames(devs_data) <- c('author','last_commit', 'first_commit')
    
    
    
    #devs_data$xp_in_hours = difftime(devs_data$last_commit, devs_data$first_commit, units = "hours")
    
    devs_data$xp_in_days = difftime(devs_data$last_commit, devs_data$first_commit, units = "days")
    
    devs_data$xp_in_weeks = difftime(devs_data$last_commit, devs_data$first_commit, units = "weeks")
    
    devs_xp = devs_data %>% select(author, xp_in_days, xp_in_weeks)
    
    #dbWriteTable(database, "DEVS_TD", devs_xp, append=TRUE)
    
    dbExecute(dbcon, "UPDATE DEVS_TD 
                      SET xp_in_days =:xp_in_days, xp_in_weeks =:xp_in_weeks
                      WHERE author = :author AND projectID =:projectID ",
              params=data.frame(xp_in_days=devs_xp$xp_in_days,
                                xp_in_weeks=devs_xp$xp_in_weeks,
                                author=devs_xp$author, projectID=projectID))
    
}

end_time <- Sys.time()

print(end_time - start_time)

dbDisconnect(database)
RM(database)


