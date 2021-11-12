#######################

# Correao no calculo de commits com smells

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
  "SELECT COUNT (DISTINCT SONAR_ISSUES.creationCommitHash) AS sonar_smells, 
    GIT_COMMITS.author AS [author],
    GIT_COMMITS.projectID AS [projectID] 
    FROM GIT_COMMITS 
    INNER JOIN SONAR_ISSUES ON GIT_COMMITS.commitHash=SONAR_ISSUES.creationCommitHash
    WHERE GIT_COMMITS.projectID= ? AND GIT_COMMITS.merge='False' AND SONAR_ISSUES.type ='CODE_SMELL' GROUP BY GIT_COMMITS.author"
                         , params = c(projectID))
  
  dbExecute(dbcon, "UPDATE DEVS_TD 
                      SET sonar_smells =:sonar_smells
                      WHERE author = :author AND projectID =:projectID ",
            params=data.frame(sonar_smells=devs_data$sonar_smells,
                              author=devs_data$author, projectID=devs_data$projectID))
}

end_time <- Sys.time()

print(end_time - start_time)

###
#CODE SMELLS
# "SELECT COUNT (DISTINCT SONAR_ISSUES.creationCommitHash) AS code_smells,
#   GIT_COMMITS.author AS [author],
#   GIT_COMMITS.projectID AS [projectID]
#   FROM GIT_COMMITS
# INNER JOIN SONAR_ISSUES ON GIT_COMMITS.commitHash=SONAR_ISSUES.creationCommitHash
# WHERE GIT_COMMITS.projectID= ? AND GIT_COMMITS.merge='False' AND SONAR_ISSUES.squid LIKE 'code_smells:%' GROUP BY GIT_COMMITS.author
# "
