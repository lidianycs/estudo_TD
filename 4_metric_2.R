#######################

#Calcular o tempo de exp dos desenvolvedores de um projeto

#######################

library(DBI)
library(RSQLite)
library(dbplyr)
library(dplyr)
library(lubridate)
#conecta ao BD
dbcon = dbConnect(SQLite(), "TechnicalDebtDataset_20200606.db") 

#pega lista de projetos analisados

project_list = dbGetQuery(dbcon, "SELECT projectID FROM PROJECTS ")
project_list = project_list[["projectID"]]

#pega um projeto (projectID) para analisar
# projectID = project_list[1]

# devs_data = dbGetQuery(dbcon, "SELECT author, MAX(authorDate), MIN(authorDate)
#                                       FROM GIT_COMMITS
#                                       WHERE projectID = ? AND merge='False' GROUP BY author"
#                        , params = c(projectID))
# 
# #renomear colunas
# colnames(devs_data) <- c('author','last_commit', 'first_commit')
# 
#         first_dat = ymd_hms(devs_data$first_commit)
#         last_dat = ymd_hms(devs_data$last_commit)
# 
#         total_hours=difftime(last_dat, first_dat, units = "hours")
#         h =  length(last_dat)
# 

          # laço for que percorre o array das datas, manipulando uma por uma
          # para evitar dados neperiano.
#         for(i in 1:h){
#           p=difftime(last_dat[i], first_dat[i], units = "hours")
#           print(p)
#         }
#         # print(total_hours)

start_time <- Sys.time()

for (i in 15:15){
    projectID = project_list[i]
    print(projectID)
    
    devs_data = dbGetQuery(dbcon, "SELECT author, MAX(authorDate), MIN(authorDate)
                                      FROM GIT_COMMITS
                                      WHERE projectID = ? AND merge='False' GROUP BY author"
                           , params = c(projectID))
    

   
#   #renomear colunas
    colnames(devs_data) <- c('author','last_commit', 'first_commit')

        # cria as datas
        first_dat = ymd_hms(devs_data$first_commit)
        last_dat = ymd_hms(devs_data$last_commit)

        
          
        devs_data$xp_in_hours = difftime(last_dat, first_dat, units = "hours")

        devs_data$xp_in_days = difftime(last_dat, first_dat, units = "days")
          
        devs_data$xp_in_weeks = difftime(last_dat, first_dat, units = "weeks")
          
        devs_xp = devs_data %>% select(author, xp_in_days, xp_in_weeks)
          
          # dbWriteTable(database, "DEVS_TD", devs_xp, append=TRUE)
          
          # dbExecute(dbcon, "UPDATE DEVS_TD
          #                 SET xp_in_days =:xp_in_days, xp_in_weeks =:xp_in_weeks
          #                 WHERE author = :author AND projectID =:projectID ",
          #           params=data.frame(xp_in_days=devs_xp$xp_in_days,
          #                             xp_in_weeks=devs_xp$xp_in_weeks,
          #                             author=devs_xp$author, projectID=projectID))
          
}

end_time <- Sys.time()

print(end_time - start_time)

# dbDisconnect(database)
# RM(database)


