# Gender Differences in Political News Coverage: A Text Analysis Approach

**Author:** Chuchu Wan
**Date:** May 2025

## Overview

This project investigates gender-based differences in political news coverage using advanced text analysis methods. The research explores three key dimensions:

1. **Topic modeling** — thematic focuses and whether they differ by politician gender.
2. **Emotion analysis** — comparing emotional tone using the NRC Emotion Lexicon.
3. **Word embedding semantic shift analysis** — detecting subtle differences in word meaning or contextual use.

The study uses a corpus of 2,100+ news articles mentioning 14 prominent U.S. politicians, balanced between male and female figures.

---

## Politicians Analyzed

**Female politicians:**  
Kamala Harris, Nancy Pelosi, Amy Klobuchar, Nikki Haley, Elizabeth Warren, Gretchen Whitmer, Elise Stefanik

**Male politicians:**  
Joe Biden, Donald Trump, Bernie Sanders, Barack Obama, Ron DeSantis, Kevin McCarthy, JD Vance

*Note:* News articles were not necessarily solely about the politician but contained substantial mentions relevant to each figure.

---

## Files

| File | Description |
|------|-------------|
| `Dataset Creat.R` | R script to build the corpus, clean text, and create the document-feature matrix (DFM). |
| `First Draft.R` | Runs Structural Topic Model (STM), performs NRC emotion analysis, and summarizes gender-based differences. |
| `Embedding_Final.R` | Trains Word2Vec models separately for male/female corpora, computes cosine similarities, and extracts example contexts. |
| `word_contexts.xlsx` | Extracted contexts for selected keywords in both male and female corpora. |
| `Semantic_Shift_Context_Comparison_Table.csv` | Semantic shift summary with example sentences. |
| `Final Proposal.docx` | Complete research proposal, including methods, results, discussion, and references. |
| `Presentation Slides (PDF)` | Summary presentation used to showcase findings. |
| Figures (`*.png`) | Key visualizations (emotion comparison, STM topics, topic differences, semantic shifts, word clouds). |

---

## Methods Summary

### Preprocessing
- Lowercasing, punctuation removal, stopword removal.
- Politician names removed to avoid skewing results.
- Tokenization and document-feature matrix (DFM) creation.

### Topic Modeling
- STM with K = 10 topics.
- Gender as a covariate to assess topic prevalence differences.

### Emotion Analysis
- NRC Emotion Lexicon applied.
- Emotion word frequency normalized per 1,000 words.
- Welch’s t-tests for group differences.

### Semantic Shift
- Word2Vec models trained separately by gender.
- Cosine similarity computed for shared vocabulary.
- Low-similarity words identified for potential gendered semantic shifts.
- Contextual sentence examples extracted.

---

## Key Findings

- **Topics:**  
  - Female-associated articles emphasized *domestic policy* and *personal life*.  
  - Male-associated articles emphasized *international policy* and *economic/leadership* themes.

- **Emotion:**  
  - Male-focused articles had higher frequencies of negative emotions (anger, disgust, fear, sadness).  
  - Positive emotions were similar across groups.

- **Semantic Shift:**  
  - Words such as *navy*, *period*, *woman* showed different contextual meanings by gender.

---

## Limitations

- Articles include content mentioning politicians but are not always exclusively about them.
- Semantic differences do not always imply intentional bias; they may reflect broader discourse patterns.
- Word2Vec embeddings can vary slightly between training runs even with controlled seeds.

---

## References

- Van der Pas, D., & Aaldering, L. (2020). Gender differences in political media coverage: A meta-analysis. *Journal of Communication*, 70(1), 114–143.
- Roberts, M. E., Stewart, B. M., & Tingley, D. (2019). *stm: An R package for structural topic models*. Journal of Statistical Software.
- Mohammad, S., & Turney, P. (2013). Crowdsourcing a word–emotion association lexicon. *Computational Intelligence*, 29(3), 436–465.
- Study finds significant differences in how male and female politicians are covered in the news. *University of Michigan News*. (2019).

---

## How to Reproduce

1. Run `Dataset Creat.R` to prepare the corpus and clean the text.
2. Run `First Draft.R` to execute topic modeling and emotion analysis.
3. Run `Embedding_Final.R` for Word2Vec semantic shift analysis.
4. Review results in Excel/CSV outputs and visualizations.
5. See the proposal document and presentation slides for interpretations and conclusions.

---
