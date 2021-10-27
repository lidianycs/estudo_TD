  
#instalar pacotes
install.packages("RSQLite")
  install.packages("dbplyr")
  install.packages("data.table")
  install.packages("plyr")
  
  #p/ config git
  install.packages("usethis")
  library(usethis)
  
  usethis::use_git_config(user.name = "Lidiany", # Seu nome
                          user.email = "lidianycs@gmail.com") # Seu email
  
  usethis::create_github_token()
  usethis::edit_r_environ()  
  
  usethis::use_git()
  