rmd_content <- readLines("Open_water_flow.Rmd")

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


writeLines(filtered_content, "Open_water_flow_start.Rmd")
