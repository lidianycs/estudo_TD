#######################

# Calcular a quantidade de commits dos desenvolvedores de um projeto

#######################

# DEVE SER EXECUTADO PRIMEIRO - PARA TERMOS OS NOMES DE TODOS OS DEVS E DOS PROJETOS

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
#projectID = project_list[1]

start_time <- Sys.time()

for (i in project_list){
  projectID = i
  
  devs_data = dbGetQuery(dbcon, "SELECT COUNT(DISTINCT commitHash) AS n_commits, 
                                  author AS [author], projectID as [projectID]
                                  FROM GIT_COMMITS 
                                  WHERE projectID = ? AND merge='False'
                                  GROUP BY author"
                         , params = c(projectID))
  
  #Adiciona todos os commits de todos os desenvolvedores
  dbWriteTable(dbcon, "DEVS_TD", devs_data, append=TRUE)
  
  # dbExecute(dbcon, "UPDATE DEVS_TD 
  #                     SET n_commits =:n_commits
  #                     WHERE author = :author AND projectID =:projectID ",
  #           params=data.frame(n_commits=devs_data$n_commits,
  #                             author=devs_data$author, projectID=projectID))
}

end_time <- Sys.time()

print(end_time - start_time)
  