options(timeout = 300)
install.packages("stringi")

install.packages("LexisNexisTools")
install.packages("dplyr")

library(LexisNexisTools)
library(dplyr)

# Define the directory containing your DOCX files
docx_directory <- "C:/Users/w2019/Desktop/Final Project/"

# List of DOCX files to process
docx_files <- c(
  "Harris.DOCX",
  "Pelosi.DOCX",
  "Klobuchar.DOCX",
  "Haley.DOCX",
  "Warren.DOCX",
  "Biden.DOCX",
  "Trump.DOCX",
  "Sanders.DOCX",
  "Obama.DOCX",
  "DeSantis.DOCX",
  "McCarthy.DOCX",
  "Whitmer.DOCX",
  "Vance.DOCX",
  "Stefanik.DOCX"
)

# Create a named vector mapping politicians to their genders
gender_map <- c(
  "Harris" = "Female",
  "Pelosi" = "Female",
  "Klobuchar" = "Female",
  "Haley" = "Female",
  "Warren" = "Female",
  "Biden" = "Male",
  "Trump" = "Male",
  "Sanders" = "Male",
  "Obama" = "Male",
  "DeSantis" = "Male",
  "McCarthy" = "Male",
  "Whitmer" = "Female",
  "Vance" = "Male",
  "Stefanik" = "Female"
)

process_docx_file <- function(file_name, directory, gender_mapping) {
  # Construct the full file path
  file_path <- file.path(directory, file_name)
  
  # Read the DOCX file
  lnt_output <- lnt_read(x = file_path)
  
  # Extract metadata and articles
  meta_df <- lnt_output@meta
  articles_df <- lnt_output@articles
  
  # Merge metadata and articles
  combined_df <- inner_join(meta_df, articles_df, by = "ID")
  
  # Extract the politician's name from the file name
  politician_name <- tools::file_path_sans_ext(file_name)
  
  # Add Politician and Gender columns
  combined_df <- combined_df %>%
    mutate(
      Politician = politician_name,
      Gender = gender_mapping[politician_name]
    )
  
  return(combined_df)
}

# Process each DOCX file and combine the results into a single data frame
combined_dataset <- lapply(docx_files, process_docx_file, directory = docx_directory, gender_mapping = gender_map) %>%
  bind_rows()
# Save the combined dataset as an RDS file
saveRDS(combined_dataset, file = file.path(docx_directory, "combined_dataset.rds"))

