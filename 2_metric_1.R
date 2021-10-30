#######################

#1ª métrica linhas editadas X TD - code Smells

#######################

#carregar pacotes necessários
library(DBI)
library(RSQLite)
library(dbplyr)
library(dplyr)


#conecta ao BD
con <- dbConnect(SQLite(), "TechnicalDebtDataset_20200606.db")  

#pega lista de projetos analisados
sql_query = tbl(con, sql("select DISTINCT projectID from GIT_COMMITS "))
project_list = as.data.frame(sql_query %>% select(projectID))
project_list = project_list[["projectID"]]

#pega um projeto (projectID) para analisar
projectID = project_list[1]

start_time <- Sys.time()

# Consulta 1 - Total de Linhas Adicionadas e Removidas pelos desenvolvedores de um projeto
# projectID
sql_query = toString(paste(" 
  SELECT GIT_COMMITS.projectID,GIT_COMMITS.commitHash,GIT_COMMITS.author, 
  GIT_COMMITS_CHANGES.linesAdded,GIT_COMMITS_CHANGES.linesRemoved FROM GIT_COMMITS 
  INNER JOIN GIT_COMMITS_CHANGES ON GIT_COMMITS.commitHash=GIT_COMMITS_CHANGES.commitHash
  WHERE GIT_COMMITS.merge='False' and GIT_COMMITS.projectID='", projectID, "'", sep = "")) 

#transforma a consulta em um dataframe
data = tbl(con, sql(sql_query))
proj1_count_lines = as.data.frame(data %>% select(projectID, commitHash, author, linesAdded, linesRemoved))

#Calcular total de linhas editadas por dev

#transformar char em num
temp_data = transform(proj1_count_lines, linesAdded = as.numeric(linesAdded), 
                      linesRemoved = as.numeric(linesRemoved))

#seleciona só as colunas necessárias
temp_data = temp_data %>% select(author, linesAdded, linesRemoved)

#soma a quantidade de linhas add e removidas por cada dev
library(dplyr)
proj1_lines_edited = temp_data %>% 
  group_by(author) %>% 
  summarise(across(everything(), sum))

#soma as colunas pra chegar ao número de linhas editadas
proj1_lines_edited$linesEdited = proj1_lines_edited$linesAdded + proj1_lines_edited$linesRemoved

#finaliza com a quantidade de linhas editadas
proj1_lines_edited = proj1_lines_edited %>% select(author, linesEdited)

rm(temp_data)


#Consulta 2 - SELECIONAR COMMITS COM CODE SMELLS DO PROJETO


#SELECIONAR COMMITS COM CODE SMELLS DO PROJETO
sql_query = toString(paste(" SELECT SONAR_ISSUES.creationCommitHash, 
                           SONAR_ISSUES.type from SONAR_ISSUES 
                           WHERE SONAR_ISSUES.projectID='", 
                           projectID , "' and SONAR_ISSUES.type ='CODE_SMELL'", sep = "")) 

#dataframe
data = tbl(con, sql(sql_query))
proj1_td = as.data.frame(data %>% select(creationCommitHash, type))

#renomear colunas
colnames(proj1_td) <- c('commitHash','type')

#faz a contagem de code smells por commits
library("plyr")
x = count(proj1_td, 'commitHash')
detach("package:plyr")#evitar conflito com o pacote dplyr

#seleciona só as colunas necessárias 
#contém a lista de commits de cada dev
temp_data = proj1_count_lines %>% select(commitHash, author)

#inner_join com a lista de autores e a contagem de commits com smells
committers_code_smells = inner_join(temp_data, x, by="commitHash") %>% group_by(commitHash) %>% filter (! duplicated(commitHash)) 

committers_code_smells = committers_code_smells %>% ungroup() %>% select(author, freq)

library(dplyr)
#calcular a frequencia de code smells de cada dev - somar
code_smells_count = committers_code_smells %>%
  group_by(author) %>%
  summarise(Freq = sum(freq))

#renovemar as colunas
colnames(code_smells_count) <- c('author','codeSmells')

#juntar com a outra tabela de linhas editadas
count_code_smells_lines_edited = full_join(proj1_lines_edited, code_smells_count , by="author")

#add coluna com Id do projeto para separar por projeto
count_code_smells_lines_edited$projectID = projectID

#salva no banco
dbWriteTable(con, "DEVS_TD", count_code_smells_lines_edited, append=TRUE)


end_time <- Sys.time()

print(end_time - start_time)

#rodar no final
dbDisconnect(con)
rm(proj1_count_lines)
rm(proj1_lines_edited)
rm(proj1_td)
rm(committers_code_smells)
rm(projectID)
rm(code_smells_count)
rm(temp_data)
rm(x)
rm(sql_query)
rm(data)
rm(con)


