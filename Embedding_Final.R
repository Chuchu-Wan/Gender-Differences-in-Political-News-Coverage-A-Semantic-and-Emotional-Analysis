rm(list = ls())

# Load required library for Word2Vec (install if not already installed)
# install.packages("word2vec")  # uncomment this line to install the package if needed
library(word2vec)

# Set a seed for reproducibility (especially important for word2vec training randomness)
set.seed(123)

# Load the combined dataset from the .rds file
df <- readRDS("C:/Users/w2019/Desktop/Final Project/combined_dataset.rds")

# Ensure the text and gender columns have the expected types
df$Article <- as.character(df$Article)      # make sure text is character
df$Gender <- tolower(as.character(df$Gender))  # normalize gender labels to lowercase ("male"/"female")

# Basic text preprocessing on the 'Article' column:
# 1. Lowercase all text
df$Article <- tolower(df$Article)

# 2. Remove punctuation (replace with space to avoid concatenating words)
df$Article <- gsub("[[:punct:]]", " ", df$Article)

# 3. Replace multiple spaces or whitespace with a single space
df$Article <- gsub("\\s+", " ", df$Article)

# 4. Trim leading and trailing spaces
df$Article <- trimws(df$Article)

# Split the dataset into male and female subsets based on the 'Gender' column
male_data   <- df[df$Gender == "male", ]
female_data <- df[df$Gender == "female", ]

# Extract the text content for each subset as character vectors (corpora)
male_corpus   <- male_data$Article
female_corpus <- female_data$Article

# Quick checks (optional): number of documents in each corpus
length(male_corpus)    # number of texts about males
length(female_corpus)  # number of texts about females

# Train a Word2Vec model on the male corpus (CBOW model)
model_male <- word2vec(x = male_corpus, type = "cbow", dim = 100, window = 5, iter = 5, min_count = 1)
# Train a Word2Vec model on the female corpus (CBOW model)
model_female <- word2vec(x = female_corpus, type = "cbow", dim = 100, window = 5, iter = 5, min_count = 1)

# Convert the models to matrices of word vectors for easier analysis
emb_male   <- as.matrix(model_male)   # matrix of word embeddings from male corpus model
emb_female <- as.matrix(model_female) # matrix of word embeddings from female corpus model

# (Each matrix has words as row names and 100 columns for the embedding dimensions)


# Identify the set of common words in both vocabularies
common_words <- intersect(rownames(emb_male), rownames(emb_female))
length(common_words)  # number of common words

# Extract the vectors for the common words from each embedding matrix
vecs_male   <- emb_male[common_words, , drop = FALSE]
vecs_female <- emb_female[common_words, , drop = FALSE]

# Compute cosine similarity for each common word
# Calculate dot products for each word (row-wise)
dot_products <- rowSums(vecs_male * vecs_female)

# Calculate magnitudes (Euclidean norms) for each word vector in both sets
mag_male   <- sqrt(rowSums(vecs_male^2))
mag_female <- sqrt(rowSums(vecs_female^2))

# Calculate cosine similarity for each word
cosine_similarities <- dot_products / (mag_male * mag_female)

# Create a data frame of the results for clarity
cosine_df <- data.frame(word = common_words, cos_sim = cosine_similarities, stringsAsFactors = FALSE)
# Sort by cosine similarity (ascending order so lowest similarities are first)
cosine_df <- cosine_df[order(cosine_df$cos_sim), ]


# Select the words with the lowest cosine similarity (e.g., bottom 10 words)
top_n <- 10  # you can adjust this number to see more words
most_shifted_words <- head(cosine_df, top_n)

# Print the ranked list of words with lowest cosine similarity
print(most_shifted_words)
# The output will list the words and their cosine similarity values, sorted from lowest (most different) to higher.

# Optionally, plot these words to visualize the semantic shift
library(ggplot2)
# Prepare data for plotting (taking the same top_n most shifted words)
plot_data <- most_shifted_words
# Order factor by similarity for clear plotting (lowest similarity on one end)
plot_data$word <- factor(plot_data$word, levels = plot_data$word)

# Create a bar plot of cosine similarity for the most shifted words
ggplot(plot_data, aes(x = word, y = cos_sim)) +
  geom_col(fill = "steelblue") +
  coord_flip() +  # horizontal bars for readability
  labs(title = "Top Words with Lowest Cosine Similarity (Male vs Female Corpora)",
       x = "Word", y = "Cosine Similarity between Embeddings") +
  theme_minimal()


##into content

interesting_words <- c("period", "navy", "usa", "allowed", "woman", "tension", "age", "jurisprudence", "round", "track")

contexts_male <- list()
contexts_female <- list()

for (word in interesting_words) {
  contexts_male[[word]] <- extract_word_context(male_corpus, word)
  contexts_female[[word]] <- extract_word_context(female_corpus, word)
}

# ==========woman ==========
cat("\n===== 'woman' in Male Corpus =====\n")
print(contexts_male$woman)

cat("\n===== 'woman' in Female Corpus =====\n")
print(contexts_female$woman)


cat("\n===== 'period' in Male Corpus =====\n")
print(contexts_male$period)

cat("\n===== 'period' in Female Corpus =====\n")
print(contexts_female$period)


cat("\n===== 'navy' in Male Corpus =====\n")
print(contexts_male$navy)

cat("\n===== 'navy' in Female Corpus =====\n")
print(contexts_female$navy)

# 
install.packages("openxlsx")
library(openxlsx)

context_list <- list()

for (word in interesting_words) {

    if (length(contexts_male[[word]]) > 0) {
    context_list[[paste0(word, "_male")]] <- data.frame(
      word = word,
      gender = "Male",
      context = contexts_male[[word]],
      stringsAsFactors = FALSE
    )
  }

    if (length(contexts_female[[word]]) > 0) {
    context_list[[paste0(word, "_female")]] <- data.frame(
      word = word,
      gender = "Female",
      context = contexts_female[[word]],
      stringsAsFactors = FALSE
    )
  }
}

context_list_nonempty <- context_list[sapply(context_list, nrow) > 0]

write.xlsx(context_list_nonempty, file = "C:/Users/w2019/Desktop/Final Project/word_contexts.xlsx")

