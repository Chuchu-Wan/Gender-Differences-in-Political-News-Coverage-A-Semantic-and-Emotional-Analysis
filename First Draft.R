library(quanteda)
library(stopwords)
library(readr)
library(dplyr)

# Step 1: Read the cleaned .rds dataset
combined_df <- readRDS("C:/Users/w2019/Desktop/Final Project/combined_dataset.rds")

# Step 2: Create a quanteda corpus from the article text
# Make sure your article column is named "Article" (change if needed)
corpus <- corpus(combined_df, text_field = "Article")

# Step 3: Add metadata (politician and gender)
docvars(corpus, "Politician") <- combined_df$Politician
docvars(corpus, "Gender") <- combined_df$Gender

# Step 4: Tokenize and clean text
toks_cleaned <- tokens(corpus,
                       remove_punct = TRUE,
                       remove_numbers = TRUE) %>%
  tokens_tolower() %>%
  tokens_remove(stopwords("en")) %>%
  tokens_keep(pattern = "^[a-z]+$", valuetype = "regex")  # keep only alphabetic tokens

# Step 5: Create Document-Feature Matrix (DFM)
dfm_cleaned <- dfm(toks_cleaned)

# Step 6: Trim low-frequency terms (optional, keeps terms that appear at least 5 times)
dfm_trimmed <- dfm_trim(dfm_cleaned, min_termfreq = 5)

# Step 7: Save cleaned DFM for later use
saveRDS(dfm_trimmed, file = "C:/Users/w2019/Desktop/Final Project/dfm_cleaned.rds")

# Step 8: View top 20 frequent words
topfeatures(dfm_trimmed, 20)
install.packages("quanteda.textplots")
library(quanteda)
library(quanteda.textplots)

dfm_trimmed <- readRDS("C:/Users/w2019/Desktop/Final Project/dfm_cleaned.rds")

#Word Cloud
textplot_wordcloud(dfm_trimmed,
                   max_words = 100,
                   min_count = 5,
                   color = "black",
                   random_order = FALSE,
                   rotation = 0.25,
                   font = NULL)


dfm_female <- dfm_subset(dfm_trimmed, Gender == "Female")
dfm_male <- dfm_subset(dfm_trimmed, Gender == "Male")

# female
textplot_wordcloud(dfm_female,
                   max_words = 100,
                   min_count = 5,
                   color = "darkred",
                   random_order = FALSE,
                   rotation = 0.25,
                   main = "Female Politicians")

# male
textplot_wordcloud(dfm_male,
                   max_words = 100,
                   min_count = 5,
                   color = "navyblue",
                   random_order = FALSE,
                   rotation = 0.25,
                   main = "Male Politicians")


install.packages("stm")
install.packages("tidyr")


library(stm)
library(quanteda)


# stopwords
custom_stopwords <- c(
  "harris", "kamala", "pelosi", "nancy", "klobuchar", "amy",
  "haley", "nikki", "warren", "elizabeth",
  "biden", "joe", "trump", "donald", "sanders", "bernie",
  "obama", "barack", "desantis", "ron",
  "mccarthy", "whitmer", "vance", "stefanik"
)

toks_cleaned <- tokens(corpus,
                       remove_punct = TRUE,
                       remove_numbers = TRUE) %>%
  tokens_tolower() %>%
  tokens_remove(stopwords("en")) %>%
  tokens_remove(custom_stopwords) %>%
  tokens_keep(pattern = "^[a-z]+$", valuetype = "regex")  
dfm_cleaned <- dfm(toks_cleaned)

#New DFM
saveRDS(dfm_cleaned, "C:/Users/w2019/Desktop/Final Project/dfm_cleaned_no_names.rds")


dfm_trimmed <- readRDS("C:/Users/w2019/Desktop/Final Project/dfm_cleaned_no_names.rds")

# meta:Gender
out <- convert(dfm_trimmed, to = "stm")

docs <- out$documents
vocab <- out$vocab
meta <- out$meta

stm_model <- stm(documents = docs, vocab = vocab,
                 data = meta,
                 K = 10,                    
                 prevalence = ~ Gender, 
                 max.em.its = 75,    
                 verbose = TRUE)

# 
labelTopics(stm_model, n = 10)  # 

# Define short English topic labels based on refined understanding
topic_labels <- c(
  "Elon Musk and DOGE",          # Topic 1
  "Talk Show Discussions",       # Topic 2
  "Presidential Campaigns",      # Topic 3
  "International Relations (India/US)",  # Topic 4
  "Student Loans and Military Housing",  # Topic 5
  "Tariffs and International Trade",     # Topic 6
  "News Platform Content",       # Topic 7
  "House Republicans and Leadership",   # Topic 8
  "Stocks and Financial Markets",       # Topic 9
  "Michigan Politics (Whitmer)"   # Topic 10
)


plot(stm_model,
     type = "summary",
     labeltype = "score",
     n=7,
     main = "Topic Summary")


# Assign names so you can call topics by "Topic 1", "Topic 2", etc.
names(topic_labels) <- paste0("Topic ", 1:10)

# Check the mapping
topic_labels

topic_props <- stm_model$theta %>% apply(2, mean)

topic_summary_df <- data.frame(
  Topic = factor(topic_labels, levels = topic_labels),
  Proportion = topic_props
)

# 
library(ggplot2)

ggplot(topic_summary_df, aes(x = Proportion, y = Topic)) +
  geom_col(fill = "steelblue") +
  theme_minimal() +
  labs(title = "Topic Summary with Custom Labels",
       x = "Expected Topic Proportion",
       y = "Topics") +
  theme(text = element_text(size = 12))



# Gender effect estimation
gender_effects <- estimateEffect(1:10 ~ Gender, stmobj = stm_model, metadata = meta)

plot(gender_effects, 
     covariate = "Gender", 
     topics = 1:10, 
     model = stm_model,
     method = "difference",
     cov.value1 = "Female", cov.value2 = "Male",
     labeltype = "custom",         
     custom.labels = topic_labels,  
     xlab = "More Associated with... (Female on positive, Male on negative)",
     main = "Topic Differences by Gender (Custom Labels)")



library(quanteda)
library(dplyr)
library(tidyr)
library(ggplot2)

dfm_cleaned <- readRDS("C:/Users/w2019/Desktop/Final Project/dfm_cleaned_no_names.rds")

#########################NRC

install.packages("textdata")
library(textdata)

nrc <- lexicon_nrc()

library(dplyr)

nrc_anger_disgust <- nrc %>%
  filter(sentiment %in% c("anger", "disgust")) %>%
  pull(word) %>%
  unique()

length(nrc_anger_disgust) 

dfm_cleaned <- readRDS("C:/Users/w2019/Desktop/Final Project/dfm_cleaned_no_names.rds")

attack_dict <- dictionary(list(
  Personal_Attack = nrc_anger_disgust
))

dfm_attack <- dfm_lookup(dfm_cleaned, dictionary = attack_dict)

df_attack_df <- convert(dfm_attack, to = "data.frame")
df_attack_df$Gender <- docvars(dfm_cleaned, "Gender")

doc_total_words <- ntoken(dfm_cleaned)

df_attack_df$Total_Words <- doc_total_words
df_attack_df <- df_attack_df %>%
  mutate(Personal_Attack_norm = Personal_Attack / Total_Words * 1000)

summary_attack <- df_attack_df %>%
  group_by(Gender) %>%
  summarise(Mean_Attack = mean(Personal_Attack_norm))

print(summary_attack)


t_test_attack <- t.test(Personal_Attack_norm ~ Gender, data = df_attack_df)

print(t_test_attack)
## stat significance in male(male related news are associated with a higher proportion of attack words)

######################### Emotion Comparison by Gender

# Continue using the NRC lexicon
# Get the list of all unique emotions
emotion_list <- unique(nrc$sentiment)

# Create a dictionary: each emotion maps to its list of words
emotion_dict <- dictionary(split(nrc$word, nrc$sentiment))

# Apply the dictionary to the cleaned DFM to count emotion words
dfm_emotions <- dfm_lookup(dfm_cleaned, dictionary = emotion_dict)

# Convert DFM to a data frame
df_emotion_df <- convert(dfm_emotions, to = "data.frame")

# Add back Gender metadata
df_emotion_df$Gender <- docvars(dfm_cleaned, "Gender")

# Add total number of words per document
df_emotion_df$Total_Words <- ntoken(dfm_cleaned)

# Normalize: calculate emotion word frequency per 1000 words
emotion_columns <- setdiff(colnames(df_emotion_df), c("doc_id", "Gender", "Total_Words"))

# Loop over each emotion column to normalize
for (emotion in emotion_columns) {
  df_emotion_df[[paste0(emotion, "_norm")]] <- df_emotion_df[[emotion]] / df_emotion_df$Total_Words * 1000
}

# Keep only Gender and normalized emotion frequency columns
emotion_norm_cols <- grep("_norm$", names(df_emotion_df), value = TRUE)

emotion_data_norm <- df_emotion_df %>%
  select(Gender, all_of(emotion_norm_cols))

# Group by Gender and calculate the mean for each emotion
summary_emotions <- emotion_data_norm %>%
  group_by(Gender) %>%
  summarise(across(everything(), mean))

# View the summary
print(summary_emotions)

#########################Visualization

library(tidyr)
library(ggplot2)

emotion_summary_long <- summary_emotions %>%
  pivot_longer(cols = -Gender, names_to = "Emotion", values_to = "Frequency")

emotion_summary_long$Emotion <- gsub("_norm", "", emotion_summary_long$Emotion)

ggplot(emotion_summary_long, aes(x = Emotion, y = Frequency, fill = Gender)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Average Emotion Word Frequency per 1000 Words by Gender",
       x = "Emotion", y = "Mean Frequency (per 1000 words)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

target_emotions <- c("anger", "disgust", "fear", "sadness")

t_test_results <- list()

for (emotion in target_emotions) {
  var_name <- paste0(emotion, "_norm")
  
  test_result <- t.test(
    formula = as.formula(paste(var_name, "~ Gender")),
    data = emotion_data_norm
  )
  
  t_test_results[[emotion]] <- test_result
}

for (emotion in target_emotions) {
  cat("\n===== T-Test for", emotion, "=====\n")
  print(t_test_results[[emotion]])
}


