library(readr)
library(rmarkdown)

cran_meta <- read_csv("metadata/cran.csv")

newpkg_to_install <- unique(cran_meta$pkg_name)[
  !unique(cran_meta$pkg_name) %in% installed.packages()
] 
if(length(newpkg_to_install) != 0){
  try(install.packages(unique(cran_meta$pkg_name)))
}
update.packages(oldPkgs = unique(cran_meta$pkg_name), ask = FALSE)

failed_list <- NULL

for(i in 1:nrow(cran_meta)){
  attempt_success <- try(render(
    system.file(paste0(sub("inst/", "", cran_meta$path[i]), 
                       "/skeleton/skeleton.Rmd"),
                package = cran_meta$pkg_name[i]),
    output_dir = paste0("outputs/temp/", i, "/")
  ))
  if(class(attempt_success) == "try-error"){
    failed_case <- cran_meta[i,]
    failed_case$error_message <- attempt_success[1]
    failed_list <- rbind(failed_list, failed_case)
  }else{
    
    if(file.exists(paste0("outputs/temp/", i, "/skeleton.pdf"))){
      file.rename(paste0("outputs/temp/", i, "/skeleton.pdf"), 
                  paste0("outputs/pdf/", cran_meta$pkg_name[i], "-", 
                         cran_meta$template_name[i], ".pdf"))
    }
    if(file.exists(paste0("outputs/temp/", i, "/skeleton.html"))){
      file.rename(paste0("outputs/temp/", i, "/skeleton.html"), 
                  paste0("outputs/html/", cran_meta$pkg_name[i], "-", 
                         cran_meta$template_name[i], ".html"))
    }
    if(file.exists(paste0("outputs/temp/", i, "/skeleton.md"))){
      file.rename(paste0("outputs/temp/", i, "/skeleton.md"), 
                  paste0("outputs/md/", cran_meta$pkg_name[i], "-", 
                         cran_meta$template_name[i], ".md"))
    }
    if(file.exists(paste0("outputs/temp/", i, "/skeleton.tex"))){
      file.rename(paste0("outputs/temp/", i, "/skeleton.tex"), 
                  paste0("outputs/tex/", cran_meta$pkg_name[i], "-", 
                         cran_meta$template_name[i], ".tex"))
    }
  }
}
