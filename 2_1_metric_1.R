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
# 
project_list = dbGetQuery(dbcon, "SELECT projectID FROM PROJECTS ")
project_list = project_list[["projectID"]]



start_time <- Sys.time()

for (i in project_list){
  projectID = i
  print(projectID)
  smells_devs = dbGetQuery(dbcon,
                           "SELECT COUNT (DISTINCT SONAR_ISSUES.creationCommitHash) AS sonar_smells,
    GIT_COMMITS.author AS [author],
    GIT_COMMITS.projectID AS [projectID]
    FROM GIT_COMMITS
    INNER JOIN SONAR_ISSUES ON GIT_COMMITS.commitHash=SONAR_ISSUES.creationCommitHash
    WHERE GIT_COMMITS.projectID= ? AND GIT_COMMITS.merge='False' AND SONAR_ISSUES.type ='CODE_SMELL' GROUP BY GIT_COMMITS.author"
                          
                         , params = c(projectID))

  # print(smells_devs)

dbExecute(dbcon, "UPDATE DEVS_TD
                    SET sonar_smells =:sonar_smells
                    WHERE author = :author AND projectID =:projectID ",
          params=data.frame(sonar_smells=smells_devs$sonar_smells,
                            author=smells_devs$author, projectID=smells_devs$projectID))
  
  # dbWriteTable(dbcon,"DEVS_TD",smells_devs, append=TRUE)
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

###
#SONAR SMELLS

# "SELECT COUNT (DISTINCT SONAR_ISSUES.creationCommitHash) AS sonar_smells,
#     GIT_COMMITS.author AS [author],
#     GIT_COMMITS.projectID AS [projectID]
#     FROM GIT_COMMITS
#     INNER JOIN SONAR_ISSUES ON GIT_COMMITS.commitHash=SONAR_ISSUES.creationCommitHash
#     WHERE GIT_COMMITS.projectID= ? AND GIT_COMMITS.merge='False' AND SONAR_ISSUES.type ='CODE_SMELL' GROUP BY GIT_COMMITS.author"