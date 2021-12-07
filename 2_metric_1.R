#######################

# 1 - linhas editadas por dev

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
#projectID = project_list[1]

start_time <- Sys.time()

for (i in project_list){
  projectID = i
  
  devs_data = dbGetQuery(dbcon, 
                         "SELECT GIT_COMMITS.author, 
                            SUM(GIT_COMMITS_CHANGES.linesAdded) AS [linesAdded], 
                            SUM(GIT_COMMITS_CHANGES.linesRemoved) AS [linesRemoved] 
                          FROM GIT_COMMITS 
                          INNER JOIN GIT_COMMITS_CHANGES ON GIT_COMMITS.commitHash=GIT_COMMITS_CHANGES.commitHash
                          WHERE 
                          	GIT_COMMITS.merge='False'
                          	AND GIT_COMMITS.projectID=?
                          GROUP BY GIT_COMMITS.author"
                         , params = c(projectID))

  devs_data$projectID = projectID

  #transformar char em num
  devs_data = transform(devs_data, linesAdded = as.numeric(linesAdded),
                        linesRemoved = as.numeric(linesRemoved))

  #soma as colunas pra chegar ao número de linhas editadas
  devs_data$linesEdited = devs_data$linesAdded + devs_data$linesRemoved
 

  dbExecute(dbcon, "UPDATE DEVS_TD
                      SET linesEdited =:linesEdited
                      WHERE author = :author AND projectID =:projectID ",
            params=data.frame(linesEdited=devs_data$linesEdited,
                              author=devs_data$author, projectID=devs_data$projectID))

  
}

end_time <- Sys.time()

print(end_time - start_time)


