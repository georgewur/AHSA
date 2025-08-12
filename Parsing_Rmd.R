###Simple to create a start version of an Rmd file without the answer blocks
##
##
## G.Bier May, 2025
############################################################

#usage
#add the filename between quotes in the  rmd_content line
#and run the script
#add the required start rmd name in the writeLines line between brackets


rmd_content <- readLines("Stat_profiles.Rmd")

in_answer_block <- FALSE
filtered_content <- c()

for (line in rmd_content) {
  if (grepl("^::: answer", line)) {
    in_answer_block <- TRUE
  } else if (grepl("^:::", line) && in_answer_block) {
    in_answer_block <- FALSE
  } else if (!in_answer_block) {
    filtered_content <- c(filtered_content, line)
  }
}


writeLines(filtered_content, "Stat_profiles_start.Rmd")
