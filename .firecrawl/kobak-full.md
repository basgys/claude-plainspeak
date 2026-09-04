##### Report GitHub Issue

×

Title:

Content selection saved. Describe the issue below:

Description:

Submit without GitHubSubmit in GitHub

![](https://arxiv.org/static/base/1.0.1/images/icons/smileybones-small.svg)arXiv is now an independent nonprofit! [Learn more](https://info.arxiv.org/about) ×

[![arXiv logo](https://arxiv.org/static/base/1.0.1/images/arxiv-logo-primary-light.svg)Back to arXiv](https://arxiv.org/)

[Why HTML?](https://info.arxiv.org/about/accessible_HTML.html) [Report Issue](https://arxiv.org/html/2406.07016v3# "Report an Issue") [Back to Abstract](https://arxiv.org/abs/2406.07016v3 "Back to abstract page") [Download PDF](https://arxiv.org/pdf/2406.07016v3 "Download PDF")

1. [Abstract](https://arxiv.org/html/2406.07016v3#abstract1 "In Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
2. [1 Introduction](https://arxiv.org/html/2406.07016v3#S1 "In Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
3. [2 Results](https://arxiv.org/html/2406.07016v3#S2 "In Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   1. [2.1 Excess words indicate widespread LLM usage](https://arxiv.org/html/2406.07016v3#S2.SS1 "In 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   2. [2.2 Combining excess words puts a lower bound on LLM usage](https://arxiv.org/html/2406.07016v3#S2.SS2 "In 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   3. [2.3 Lower bounds differed between subcorpora](https://arxiv.org/html/2406.07016v3#S2.SS3 "In 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
4. [3 Discussion](https://arxiv.org/html/2406.07016v3#S3 "In Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   1. [Summary](https://arxiv.org/html/2406.07016v3#S3.SS0.SSS0.Px1 "In 3 Discussion ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   2. [Interpretation and limitations](https://arxiv.org/html/2406.07016v3#S3.SS0.SSS0.Px2 "In 3 Discussion ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   3. [Related work](https://arxiv.org/html/2406.07016v3#S3.SS0.SSS0.Px3 "In 3 Discussion ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   4. [Implications and policies](https://arxiv.org/html/2406.07016v3#S3.SS0.SSS0.Px4 "In 3 Discussion ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
5. [4 Materials and Methods](https://arxiv.org/html/2406.07016v3#S4 "In Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   1. [4.1 Dataset](https://arxiv.org/html/2406.07016v3#S4.SS1 "In 4 Materials and Methods ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   2. [4.2 Pre-processing](https://arxiv.org/html/2406.07016v3#S4.SS2 "In 4 Materials and Methods ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   3. [4.3 Statistical analysis](https://arxiv.org/html/2406.07016v3#S4.SS3 "In 4 Materials and Methods ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   4. [4.4 Word annotations and lemmatisation](https://arxiv.org/html/2406.07016v3#S4.SS4 "In 4 Materials and Methods ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   5. [4.5 Subgroup analysis](https://arxiv.org/html/2406.07016v3#S4.SS5 "In 4 Materials and Methods ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   6. [4.6 LLM usage](https://arxiv.org/html/2406.07016v3#S4.SS6 "In 4 Materials and Methods ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
   7. [4.7 Data and code availability](https://arxiv.org/html/2406.07016v3#S4.SS7 "In 4 Materials and Methods ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")
6. [References](https://arxiv.org/html/2406.07016v3#bib "In Delving into LLM-assisted writing in biomedical publications through excess vocabulary")

[License: CC BY-SA 4.0](https://info.arxiv.org/help/license/index.html#licenses-available)

arXiv:2406.07016v3 \[cs.CL\] 14 Feb 2025

# Delving into LLM-assisted writing in biomedical publications through excess vocabulary

Dmitry Kobak [ORCID 0000-0002-5639-7209](https://orcid.org/0000-0002-5639-7209 "ORCID 0000-0002-5639-7209")Affiliation: Hertie Institute for AI in Brain Health, University of Tübingen, Germany
Rita González-Márquez [ORCID 0009-0005-6840-7979](https://orcid.org/0009-0005-6840-7979 "ORCID 0009-0005-6840-7979")Affiliation: Hertie Institute for AI in Brain Health, University of Tübingen, Germany
Emőke-Ágnes Horvát [ORCID 0000-0001-7709-1172](https://orcid.org/0000-0001-7709-1172 "ORCID 0000-0001-7709-1172")Affiliation: Northwestern University, Evanston, Illinois, USA
Jan Lause [ORCID 0000-0003-0946-412X](https://orcid.org/0000-0003-0946-412X "ORCID 0000-0003-0946-412X")Affiliation: ✉  dmitry.kobak@uni-tuebingen.deAffiliation: Hertie Institute for AI in Brain Health, University of Tübingen, Germany
Affiliation: Alphabetic order

###### Abstract

Large language models (LLMs) like ChatGPT can generate and revise text with human-level performance. These models come with clear limitations: they can produce inaccurate information, reinforce existing biases, and be easily misused. Yet, many scientists use them for their scholarly writing. But how wide-spread is such LLM usage in the academic literature? To answer this question for the field of biomedical research, we present an unbiased, large-scale approach: we study vocabulary changes in over 15 million biomedical abstracts from 2010–2024 indexed by PubMed, and show how the appearance of LLMs led to an abrupt increase in the frequency of certain style words. This excess word analysis suggests that at least 13.5% of 2024 abstracts were processed with LLMs. This lower bound differed across disciplines, countries, and journals, reaching 40% for some subcorpora. We show that LLMs have had an unprecedented impact on scientific writing in biomedical research, surpassing the effect of major world events such as the Covid pandemic.

## 1 Introduction

When the world changes, human-written text changes. Major events like wars and revolutions affect word frequency distributions in text corpora ( [Bochkarev et al., 2014](https://arxiv.org/html/2406.07016v3#bib.bib11 "")). The rise and fall of scientific disciplines is traceable in scholarly writing ( [Hall et al., 2008](https://arxiv.org/html/2406.07016v3#bib.bib23 ""); [Bizzoni et al., 2020](https://arxiv.org/html/2406.07016v3#bib.bib9 "")). Do technological advances leave a similar footprint on our writing?

With the release of ChatGPT in November 2022, human writing underwent an unprecedented change: For the first time, a large language model (LLM) was widely available that could generate and revise texts with human-like performance in several domains — including academia ( [Ahmed et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib1 "")), where many have hoped that LLMs might lead to more equity ( [Berdejo-Espinola and Amano, 2023](https://arxiv.org/html/2406.07016v3#bib.bib7 "")). Many researchers have since integrated LLMs in their daily writing tasks ( [Van Noorden and Perkel, 2023](https://arxiv.org/html/2406.07016v3#bib.bib52 "")) and even co-authored papers with LLMs ( [Stokel-Walker, 2023](https://arxiv.org/html/2406.07016v3#bib.bib47 "")). This has led to worries about research integrity, factual mistakes in LLM-generated content ( [Mittelstadt et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib39 ""); [Lindsay, 2023](https://arxiv.org/html/2406.07016v3#bib.bib35 ""); [Walters and Wilder, 2023](https://arxiv.org/html/2406.07016v3#bib.bib54 ""); [Ji et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib26 ""); [Zhang et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib57 "")), and misuse of LLMs by so-called paper mills that produce fake publications ( [Kendall and Teixeira da Silva, 2024](https://arxiv.org/html/2406.07016v3#bib.bib29 "")). These worries sparked attempts to track the footprint of LLM-assisted writing in scientific texts.

Figure 1: Frequencies of PubMed abstracts containing several example words. Black lines show counterfactual extrapolations from 2021–2022 to 2023–2024. We manually selected words to illustrate the diversity of frequency time courses. The first six words are affected by LLMs; the last three relate to major events that influenced scientific writing and are shown for comparison.![Refer to caption](https://arxiv.org/html/2406.07016v3/words2024.png)Figure 2: Words showing increased frequency in 2024. (a) Frequencies in 2024 and frequency ratios (rr). Both axes are on log-scale. Only a subset of points are labeled for visual clarity. The dashed line shows the threshold defining excess words (see text). Words with r>90r>90 are shown at r=90r=90. Excess words were manually annotated into content words (blue) and style words (orange). (b) The same but with frequency gap (OPENδ)\\delta) as the vertical axis. Words with δ>0.05\\delta>0.05 are shown at δ=0.05\\delta=0.05.

Recent approaches attempting to quantify the increasing use of LLMs in scientific papers all build on the idea that LLM-written text differs from human-written text ( [Lazebnik and Rosenfeld, 2024](https://arxiv.org/html/2406.07016v3#bib.bib31 ""); [Desaire et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib17 "")) and fall in three groups. One group of studies employed LLM detectors ( [Tang et al., 2024b](https://arxiv.org/html/2406.07016v3#bib.bib49 "")), which are blackbox models trained to detect LLM writing based on ground-truth human and LLM texts ( [Akram, 2024](https://arxiv.org/html/2406.07016v3#bib.bib2 ""); [Cheng et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib15 ""); [Liu and Bu, 2024](https://arxiv.org/html/2406.07016v3#bib.bib36 ""); [Picazo-Sanchez and Ortiz-Martin, 2024](https://arxiv.org/html/2406.07016v3#bib.bib45 "")). Another group of works explicitly modeled word frequency distribution in scientific corpora as a mixture distribution of texts produced by humans and by LLMs, again estimated using ground-truth human and LLM texts ( [Liang et al., 2024b](https://arxiv.org/html/2406.07016v3#bib.bib34 ""); [Liang et al., 2024a](https://arxiv.org/html/2406.07016v3#bib.bib33 ""); [Geng and Trotta, 2024](https://arxiv.org/html/2406.07016v3#bib.bib19 ""); [Astarita et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib4 "")). The third group of studies relied on lists of marker words, known to be over-used by LLMs, which are typically stylistic words unrelated to the text content ( [Gray, 2024](https://arxiv.org/html/2406.07016v3#bib.bib21 ""); [Liu and Bu, 2024](https://arxiv.org/html/2406.07016v3#bib.bib36 ""); [Matsui, 2024](https://arxiv.org/html/2406.07016v3#bib.bib37 "")).

All of these approaches share one common limitation: they require a ground-truth training set of LLM- and human-written texts. Usually, human-written texts are obtained from pre-LLM years, while LLM-written texts are generated by a set of prompts. This setup can introduce biases ( [Tang et al., 2024b](https://arxiv.org/html/2406.07016v3#bib.bib49 "")), as it requires assumptions on which models scientists use for their LLM-assisted writing, and how exactly they prompt them. Furthermore, work based on LLM detector models suffers from their blackbox nature, as it does not allow further interrogation of the results on the word level, which can make their interpretation difficult. Most importantly, all existing work focuses on detecting LLM texts, and none has attempted to systematically compare or relate LLM-induced changes in scientific writing to previous shifts in scholarly texts. This begs the question if the nature and magnitude of the observed changes are comparable to changes that regularly occur due to changing fashions, rising research topics, and global events such as the Covid-19 pandemic — or if LLMs impact scientific writing in an unprecedented way.

Here, we suggest a novel, data-driven approach to track LLM usage without requiring a labeled corpus of human-written versus model-generated texts. We were inspired by studies of excess mortality ( [Islam et al., 2021](https://arxiv.org/html/2406.07016v3#bib.bib25 ""); [Karlinsky and Kobak, 2021](https://arxiv.org/html/2406.07016v3#bib.bib28 ""); [Msemburi et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib40 "")) that looked at the excess of fatalities during the Covid pandemic compared to pre-Covid mortality. We adapt this idea to LLM-induced changes in word usage and track the excess use of words after the release of ChatGPT-like LLMs compared to pre-LLM years.
Applying this analysis to the corpus of over 15 million 2010–2024 biomedical abstracts from the PubMed library allowed us to track changes in scientific writing over the last decade in the large field of biomedical research. We found that the LLM-induced changes were unprecedented in both quality and quantity.

## 2 Results

### 2.1 Excess words indicate widespread LLM usage

We downloaded all PubMed abstracts until the end of 2024 and used all 15.1 M English-language abstracts from 2010 onwards (after cleaning them from contaminating strings, see Methods). We then computed the matrix of word occurrences that shows which abstracts contain which words, resulting in a 15.1 M ×\\times 273 K sparse binary matrix. For each word and each year, we found the number of abstracts in that year that the word appeared in, and obtained its occurrence frequency pp by normalizing with the total number of papers published in that year. Our main analysis focused on 26.7 K words with p>10−4p>10^{-4} in both 2023 and 2024. With over 1 million abstracts per year, this corresponds to >100{>}100 usages per year.

Some words strongly increased their occurrence frequency in 2023–2024 (Figure [1](https://arxiv.org/html/2406.07016v3#S1.F1 "Figure 1 ‣ 1 Introduction ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")). To quantify this increase, we calculated counterfactual expected frequency in 2024 based on the linear extrapolation of word frequencies in 2021 and 2022 (see Methods). Note that we did not use 2023 frequencies for calculating the expected frequency, because they could already have been affected by LLM usage. Comparing the empirical 2024 frequency pp with the expected 2024 frequency qq, we obtained the excess frequency gap δ=p−q\\delta=p-q and the excess frequency ratio r=p/qr=p/q as two measures of excess usage. These two measures are complementary. The frequency gap is well-suited to highlight excess usage of frequent words, while the frequency ratio points to the excess usage of infrequent words. For example, frequency increases from 0.001 to 0.01 and from 0.5 to 0.6 are both noteworthy. Yet, the former frequency increase is captured by a high rr value whereas the latter has a high δ\\delta value.

Across all 26.7 K words, we found many with strong excess usage in 2024 (Figure [2](https://arxiv.org/html/2406.07016v3#S1.F2 "Figure 2 ‣ 1 Introduction ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")). Less common words with strong excess usage included delves (r=28.0r=28.0), underscores (r=13.8r=13.8), and showcasing (r=10.7r=10.7), together with their grammatical inflections (Figure [2](https://arxiv.org/html/2406.07016v3#S1.F2 "Figure 2 ‣ 1 Introduction ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") a). More common words with strong excess usage included potential (δ=0.052\\delta=0.052), findings (δ=0.041\\delta=0.041), and crucial (δ=0.037\\delta=0.037) (Figure [2](https://arxiv.org/html/2406.07016v3#S1.F2 "Figure 2 ‣ 1 Introduction ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") b).

Is this unusual, or do similar frequency changes happen every year? For comparison, we did the same analysis for all years from 2013 to 2023 (Figures [S1](https://arxiv.org/html/2406.07016v3#Sx3.F1 "Figure S1 ‣ Supplementary Figures ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")– [S4](https://arxiv.org/html/2406.07016v3#Sx3.F4 "Figure S4 ‣ Supplementary Figures ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")). We found words like ebola with r=9.9r=9.9 in 2015 and zika with r=40.4r=40.4 in 2017, but from 2013 until 2019, no single word has ever shown excess frequency gap δ>0.01\\delta>0.01. This changed during the Covid pandemic: in 2020–2022 words like coronavirus, covid, lockdown, and pandemic showed very large excess usages (up to r>1000r>1000 and δ=0.06\\delta=0.06), in agreement with the observation that the Covid pandemic had an unprecedented effect on biomedical publishing ( [González-Márquez et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib20 "")).

Figure 3: (a) Number of excess words per year, decomposed into the excess content words and excess style words. In each year, we show, as an example, the word with the highest frequency ratio rr among excess words with p>0.0015p>0.0015 and r>3r>3 (in blue). (b) Number of excess words per year, decomposed into nouns, verbs, and adjectives.

To compare the size of excess vocabulary between years, we defined as excess words all words with δ>0.01\\delta>0.01 or
log10⁡r>log10⁡24​log10​p\\log\_{10}r>\\frac{\\log\_{10}2}{4}\\log\_{10}p where pp is frequency in 2024 (see dashed lines in Figure [2](https://arxiv.org/html/2406.07016v3#S1.F2 "Figure 2 ‣ 1 Introduction ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")); these thresholds were chosen such that most words in pre-Covid years were well below (Figures [S1](https://arxiv.org/html/2406.07016v3#Sx3.F1 "Figure S1 ‣ Supplementary Figures ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")– [S4](https://arxiv.org/html/2406.07016v3#Sx3.F4 "Figure S4 ‣ Supplementary Figures ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")). The number of excess words showed a marked rise during the Covid pandemic (up to 190 words in 2021) followed by an even larger rise (to 454) in 2024 (Figure [3](https://arxiv.org/html/2406.07016v3#S2.F3 "Figure 3 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")), roughly one year after ChatGPT was released. Note that this counts grammatical inflections (such as delve, delves, delving, and delved; or mask and masks) multiple times. Counting only unique word lemmas still put 2024 on a clear first place: 343 unique lemmas in 2024 vs. 180 in 2021 (Figure [S5](https://arxiv.org/html/2406.07016v3#Sx3.F5 "Figure S5 ‣ Supplementary Figures ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")).

We manually annotated all 900 unique excess words from 2013–2024 into content words (51.3%), like masks or convolutional, and style words (45.2%), like intricate or notably (and a small number of ambiguous words, see Methods). The excess vocabulary during the Covid pandemic consisted almost entirely of content words (such as respiratory, remdesivir, etc.), whereas the excess vocabulary in 2024 consisted almost entirely of style words (Figure [3](https://arxiv.org/html/2406.07016v3#S2.F3 "Figure 3 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") a). We also manually assigned part of speech to each excess word. Content words were predominantly nouns (79.2%), and hence most excess words prior to 2024 were nouns. In contrast, out of all 379 excess style words in 2024, 66% were verbs and 14% were adjectives (Figure [3](https://arxiv.org/html/2406.07016v3#S2.F3 "Figure 3 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") b).

Figure 4: (a) Observed frequency (PP) and counterfactual expected frequency (QQ) in 2024 of abstracts containing at least one of the excess style words from 2024 with frequency pp below a given threshold. (b) The frequency gap Δ=P−Q\\Delta=P-Q as a function of the threshold.Figure 5: (a) Frequency of abstracts containing at least one word from a given word group. (b) Frequency gap estimates for various fields identified based on journal names ( [González-Márquez et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib20 "")). (c) Frequency gap estimates for various countries. (d) Frequency gap estimates for various journals. Gray circles show multiple journals grouped together. (e) Frequencies as in (a) for various PubMed subsets; Δ=(Δcommon+Δrare)/2\\Delta=(\\Delta\_{\\mathrm{common}}+\\Delta\_{\\mathrm{rare}})/2 values are shown.

### 2.2 Combining excess words puts a lower bound on LLM usage

The unprecedented increase in excess style words in 2024 allows to use them as markers of LLM usage. Each frequency gap δ\\delta for a single marker word gives a lower bound on the fraction of abstracts that went through LLMs in 2024. For example, δ=0.052\\delta=0.052 for the LLM style marker word potential means that in 2024 there were 5.2 percentage points more abstracts containing that word than expected based on the 2021–2022 data, suggesting that at least 5.2% of all abstracts in 2024 went through an LLM. We reasoned that combining multiple marker words together can increase the lower bound.

For a given set of marker words GG, we computed its frequency gap ΔG=PG−QG\\Delta\_{G}=P\_{G}-Q\_{G} where PGP\_{G} and QGQ\_{G} are the observed and the expected fraction of abstracts containing at least one of the words from GG. As above, we interpret ΔG\\Delta\_{G} as a lower bound on the LLM usage. Note that this does not assume independence between words in GG. To avoid a computationally expensive combinatorial search for a set of words with the highest ΔG\\Delta\_{G}, we used two independent heuristics to form two separate sets, focusing on either rare or common style excess words.

To create the rare set, we grouped all 2024 excess style words with frequency p<Tp<T and computed the frequency gap Δrare\\Delta\_{\\mathrm{rare}} as a function of threshold TT (Figure [4](https://arxiv.org/html/2406.07016v3#S2.F4 "Figure 4 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")). We obtained the highest Δrare\\Delta\_{\\mathrm{rare}} value with T=0.02T=0.02, resulting in a set of 291 words (Figure [S6](https://arxiv.org/html/2406.07016v3#Sx3.F6 "Figure S6 ‣ Supplementary Figures ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")). The frequency gap was Δrare=0.136\\Delta\_{\\mathrm{rare}}=0.136, putting the lower bound on the LLM usage in 2024 at 13.6% (Figure [5](https://arxiv.org/html/2406.07016v3#S2.F5 "Figure 5 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") a). Importantly, this is only a lower bound because some of the abstracts that did go through an LLM may fail to contain any of the style words we selected here (see Discussion).

To create the common set, we grouped together excess style words with high individual δ\\delta values, manually adjusting the selection to maximize the frequency gap Δcommon\\Delta\_{\\mathrm{common}}. This led to the following set of 10 words: across, additionally, comprehensive, crucial, enhancing, exhibited, insights, notably, particularly, within. This set yielded a very similar frequency gap as the rare words: Δcommon=0.134\\Delta\_{\\mathrm{common}}=0.134 (Figure [5](https://arxiv.org/html/2406.07016v3#S2.F5 "Figure 5 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") a).

As the rare and the common sets were non-overlapping, both serve as an independent estimate of the lower bound. Averaging the two estimates, we obtained Δ=(Δcommon+Δrare)/2=0.135\\Delta=(\\Delta\_{\\mathrm{common}}+\\Delta\_{\\mathrm{rare}})/2=0.135 as our final estimate of the lower bound of LLM usage (13.5%).

For comparison, using the set of four excess content words from 2021, covid, pandemic, coronavirus, and sars, yielded frequency gap Δ=0.069\\Delta=0.069. This shows that the LLM usage in 2024 was at least two times higher than the size of Covid-related literature in 2021.

### 2.3 Lower bounds differed between subcorpora

We performed the same analysis as above by various subgroups of PubMed papers. We computed frequency gaps Δcommon\\Delta\_{\\mathrm{common}} and Δrare\\Delta\_{\\mathrm{rare}} for different biomedical fields, affiliation countries, journals, and men and women among the first and the last authors, inferred from their first names (see Methods). Note that we based all our Δ\\Delta estimates on the same two sets of excess style words as before. While there may be additional subcorpus-specific excess words, using the same sets of marker words ensures a fair and consistent comparison between the subcorpora.

We found pronounced heterogeneity among most of these categories. Computational fields like computation and bioinformatics showed Δ≈0.20\\Delta\\approx 0.20 (Figure [5](https://arxiv.org/html/2406.07016v3#S2.F5 "Figure 5 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") b). Among countries, some English-speaking countries like United Kingdom and Australia showed Δ≈0.05\\Delta\\approx 0.05, while countries like China, South Korea, and Taiwan showed Δ≈0.20\\Delta\\approx 0.20 (Figure [5](https://arxiv.org/html/2406.07016v3#S2.F5 "Figure 5 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") b). The difference between inferred genders was minor (0.09 for male and 0.07–0.08 for female, both for the first and the last authors).

Among individual journals, we found very high Δ\\Delta values, e.g. 0.25 for Sensors (an open access journal published by MDPI) and 0.20 for Cureus (an open access journal with simplified review process, published by Springer Nature). We analyzed several groups of journals pooled together and found high Δ\\Delta for MDPI (0.21) and Frontiers (0.20) journals. For very selective high-prestige journals like Nature, Science, and Cell, and for Nature family journals, Δ\\Delta was much lower (0.07 and 0.10 respectively), suggesting that easily-detectable LLM usage was negatively correlated with perceived prestige.

To find subgroups with the strongest effect, we looked at intersections of different groups and found Δ=0.34\\Delta=0.34 for papers from South Korea published in Sensors and Δ=0.41\\Delta=0.41 for computation papers from China. An even more fine-grained analysis based on the tt-SNE embedding ( [Van der Maaten and Hinton, 2008](https://arxiv.org/html/2406.07016v3#bib.bib51 "")) of 2022–2024 papers showed some areas with local Δ≈0.50\\Delta\\approx 0.50 (Figure [S7](https://arxiv.org/html/2406.07016v3#Sx3.F7 "Figure S7 ‣ Supplementary Figures ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")), such as, for example, a cluster of papers on deep-learning-based object detection, with predominantly Chinese affiliations and with the majority published in MDPI’s Sensors.

## 3 Discussion

#### Summary

In this paper, we leveraged excess word usage to show how LLMs have affected scientific writing in biomedical research. We found that the effect was unprecedented in quality and quantity: hundreds of words have abruptly increased their frequency after ChatGPT-like LLMs became available. In contrast to previous shifts in word popularity, the 2023–2024 excess words were not content-related nouns, but rather style-affecting verbs and adjectives that LLMs prefer.

Our analysis is performed on the corpus level and cannot identify individual abstracts that may have been processed by an LLM. Still, the following examples from three real 2023 abstracts illustrate the LLM-style flowery language:

- •


By meticulouslydelving into the intricate web connecting \[…\] and \[…\], this comprehensive chapter takes a deep dive into their involvement as significant risk factors for \[…\].

- •


A comprehensive grasp of the intricateinterplay between \[…\] and \[…\] is pivotal for effective therapeutic strategies.

- •


Initially, we delve into the intricacies of \[…\], accentuating its indispensability in cellular physiology, the enzymatic labyrinth governing its flux, and the pivotal \[…\] mechanisms.


Our analysis of the excess frequency of such LLM-preferred style words suggests that at least 13.5% of 2024 PubMed abstracts were processed with LLMs. With ∼1.5{\\sim}1.5 million papers being currently indexed in PubMed per year, this means that LLMs assist in writing at least 200 000 papers per year. This estimate is based on LLM marker words that showed large excess usage in 2024, which strongly suggests these words are preferred by LLMs like ChatGPT that became popular by that time. Importantly, this is only a lower bound: abstracts not using any of the LLM marker words are not contributing to our estimates, so the true fraction of LLM-processed abstracts is likely higher.

#### Interpretation and limitations

Our estimated lower bound on LLM usage ranged from below 5% to over 40% across different PubMed-indexed research fields, affiliation countries, and journals. This heterogeneity could correspond to actual differences in LLM adoption. For example, the high lower bound on LLM usage in computational fields (20%) could be due to computer science researchers being more familiar with and willing to adopt LLM technology. In non-English speaking countries, LLMs can help authors with editing English texts, which could justify their extensive use. Finally, authors publishing in journals with expedited and/or simplified review processes might be grabbing for LLMs to write low-effort articles.

However, the heterogeneity in lower bounds could also point to other factors beyond actual differences in LLM adoption. First, it could highlight non-trivial discrepancies in how authors of different linguistic backgrounds censor suggestions from writing assistants, thereby making the use of LLMs non-detectable for word-based approaches like the one we developed here. It is possible that native and non-native English speakers actually use LLMs equally often, but native speakers may be better at noticing and actively removing unnatural style words from LLM outputs. Our method would not be able to pick up the increased frequency of such more advanced LLM usage. Second, publication timelines in computational fields are often shorter than in many biomedical or clinical areas, meaning that any potential increase in LLM usage can be detected earlier in computational journals. Third, the same is true for journals and publishers with faster turnaround times than thoroughly reviewed, high-prestige journals. Our method can easily be used to reevaluate these results after a couple of publication cycles in all fields and journals. We expect the lower bounds documented here to increase with these longer observation windows.

Given these potential explanations for the heterogeneity in the lower bound of LLM use for scientific editing, our results indicate widespread usage in most PubMed-indexed fields, countries, and journals, including the most prestigious ones. We argue that the true LLM usage in biomedical publishing may be closer to the highest lower bounds we observed, as those may be corpora where LLM usage is the most naïve and the easiest to detect. These estimates are above 30%, which is in line with recent surveys on researchers’ use of LLMs for manuscript writing ( [Van Noorden and Perkel, 2023](https://arxiv.org/html/2406.07016v3#bib.bib52 "")). Our results show how those self-reported behaviors translate into real-world LLM usage in final publications.

Finally, while our approach can detect unexpected lexical changes, it cannot separate different causes behind those changes, like multiple emerging topics or multiple emerging writing style changes. For example, our approach cannot distinguish word frequency increase due to direct LLM usage from word frequency increase due to people adopting LLM-preferred words and borrowing them for their own writing. For spoken language, there is emerging evidence for such influence of LLMs on human language usage ( [Yakura et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib55 "")). However, we hypothesize that this effect is much smaller and much slower. Similarly, we cannot distinguish the influence of different LLMs.

#### Related work

Our results go beyond other studies on detecting LLM fingerprints in academic writing. [Gray (2024)](https://arxiv.org/html/2406.07016v3#bib.bib21 "") described a 22-fold increase in frequency for the words intricate and meticulously in 2023, while [Liang et al. (2024b)](https://arxiv.org/html/2406.07016v3#bib.bib34 "") identified pivotal, intricate, showcasing, and realm as the top LLM-preferred words based on a corpus of LLM-generated text. Our study is the first to perform a systematic search for LLM marker words based on excess usage in published scientific texts. We found 379 style words with highly elevated frequencies in 2024,
and indeed all the above examples appear in our list.

Some studies have reported differences in estimated LLM usage between English- and non-English-speaking countries ( [Cheng et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib15 ""); [Liu and Bu, 2024](https://arxiv.org/html/2406.07016v3#bib.bib36 ""); [Picazo-Sanchez and Ortiz-Martin, 2024](https://arxiv.org/html/2406.07016v3#bib.bib45 "")), academic fields ( [Akram, 2024](https://arxiv.org/html/2406.07016v3#bib.bib2 "")), and publishing venues. For example, [Liang et al. (2024b)](https://arxiv.org/html/2406.07016v3#bib.bib34 "") estimated the fraction of LLM-assisted papers in early 2024 to vary between 7% for Nature Portfolio papers and 17% for computer science preprints. Importantly, our analysis is based on 5–200 times more papers per year than these prior works, which allowed us to study LLM adoption with greater statistical power and across a much larger diversity of countries, fields, and journals.

Importantly, our approach has two conceptual advantages over previous work: First, all prior studies relied on ground-truth LLM-generated and human-written scientific texts. Such datasets can easily be biased ( [Tang et al., 2024b](https://arxiv.org/html/2406.07016v3#bib.bib49 "")), with no guarantee that the corpus of LLM-generated texts is representative of all LLM use cases occurring in actual scholarly practice. In contrast, our analysis avoids this limitation by detecting emerging LLM fingerprints directly from published abstracts. Second, our approach is not restricted to LLM usage and can be applied to abstracts from previous years. This allowed us to put the LLM-induced changes in scientific writing into a historic context (e.g., comparing the influence of LLMs to the influence of the Covid-19 pandemic), and to conclude that these changes are without precedent.

#### Implications and policies

What are the implications of this ongoing revolution in scientific writing? Scientists use LLM-assisted writing because LLMs can improve grammar, rhetoric, and overall readability of their texts, help translate to English, and quickly generate summaries ( [Van Veen et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib53 ""); [Zhang et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib56 "")). However, LLMs are infamous for making up references ( [Walters and Wilder, 2023](https://arxiv.org/html/2406.07016v3#bib.bib54 "")), providing inaccurate summaries ( [Tang et al., 2024a](https://arxiv.org/html/2406.07016v3#bib.bib48 ""); [Kim et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib30 "")), and making false claims that sound authoritative and convincing ( [Mittelstadt et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib39 ""); [Ji et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib26 ""); [Zhang et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib57 ""); [Zheng and Zhan, 2023](https://arxiv.org/html/2406.07016v3#bib.bib58 "")). While researchers may notice and correct factual mistakes in LLM-assisted summaries of their own work, it may be harder to spot errors in LLM-generated literature reviews or discussion sections.

Furthermore, LLMs can mimic biases and other deficiencies from their training data ( [Bender et al., 2021](https://arxiv.org/html/2406.07016v3#bib.bib6 ""); [Navigli et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib42 ""); [Bai et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib5 ""); [Choudhury, 2023](https://arxiv.org/html/2406.07016v3#bib.bib16 "")), or even outright plagiarise ( [McCoy et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib38 "")). This makes LLM outputs less diverse and novel than human-written text ( [Padmakumar and He, 2023](https://arxiv.org/html/2406.07016v3#bib.bib43 ""); [Alvero et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib3 "")). Such homogenisation can degrade the quality of scientific writing. For instance, all LLM-generated introductions on a certain topic might sound the same and would contain the same set of ideas and references, thereby missing out on innovations ( [Nakadai et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib41 "")) and exacerbating citation injustice ( [Dworkin et al., 2020](https://arxiv.org/html/2406.07016v3#bib.bib18 "")).
Even worse, it is likely that malign actors such as paper mills will employ LLMs to produce fake publications ( [Kendall and Teixeira da Silva, 2024](https://arxiv.org/html/2406.07016v3#bib.bib29 "")).

Our work shows that LLM usage for scientific writing is on the rise despite these substantial limitations. How should the academic community deal with this development? Some have suggested to use retrieval-augmented LLMs that provide verifiable facts from trusted sources ( [Lewis et al., 2020](https://arxiv.org/html/2406.07016v3#bib.bib32 ""); [Borgeaud et al., 2022](https://arxiv.org/html/2406.07016v3#bib.bib12 ""); [Ahmed et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib1 "")) or let the user provide all relevant facts to the LLM in order to protect scientific literature from accumulating subtle inaccuracies ( [Mittelstadt et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib39 "")). Others think that for certain tasks like peer reviewing, LLMs are ill-suited and should not be used at all ( [Lindsay, 2023](https://arxiv.org/html/2406.07016v3#bib.bib35 "")). As a result, publishers and funding agencies have put out various policies, banning LLMs in peer review ( [Kaiser, 2023](https://arxiv.org/html/2406.07016v3#bib.bib27 ""); [Brainard, 2023](https://arxiv.org/html/2406.07016v3#bib.bib13 "")), as co-authors ( [Thorp, 2023](https://arxiv.org/html/2406.07016v3#bib.bib50 "")), or undisclosed resource of any kind ( [Brainard, 2023](https://arxiv.org/html/2406.07016v3#bib.bib13 "")). Data-driven and unbiased analyses like ours can be helpful to monitor whether such policies are ignored or adhered to in practice.

In conclusion, our work showed that the effect of LLM usage on scientific writing is truly unprecedented and outshines even the drastic changes in vocabulary induced by the Covid-19 pandemic. This effect will likely become even more pronounced in the future, as one can analyze more publication cycles and LLMs are likely to increase in adoption. At the same time, LLM usage can be well-disguised and hard to detect, so the true extent of their adoption is likely already higher than what we measured. This trend calls for a reassessment of current policies and regulations around the use of LLMs for science. Our analysis can inform the necessary debate around LLM policies by providing a measurement method for LLM usage that is urgently needed ( [Brinkmann et al., 2023](https://arxiv.org/html/2406.07016v3#bib.bib14 ""); [Heersmink, 2024](https://arxiv.org/html/2406.07016v3#bib.bib24 "")). Our excess word approach could help to track future LLM usage, including scientific (grant applications and peer review) and non-scientific (news articles, social media, prose) use cases.
We hope that future work will meticulously delve into tracking LLM usage more accurately and assess which policy changes are crucial to tackle the intricate challenges posed by the rise of LLMs in scientific publishing.

## 4 Materials and Methods

### 4.1 Dataset

We used the annual PubMed snapshot released in the beginning of 2025 ( [https://ftp.ncbi.nlm.nih.gov/pubmed/baseline/](https://ftp.ncbi.nlm.nih.gov/pubmed/baseline/ "")), containing files from pubmed25n0001.xml.gz to pubmed25n1274.xml.gz. We parsed the XML files as described in our prior work ( [González-Márquez et al., 2024](https://arxiv.org/html/2406.07016v3#bib.bib20 "")), applying the same filtering criteria, to extract the abstract texts and some metadata, keeping only complete English-language abstracts with length 250–4000 characters. This resulted in 24 814 136 abstracts.
We then only analyzed papers with publication years from 2010 to 2024, giving us 15 103 888 abstracts for analysis.

For each paper, we defined the affiliation country as the country of the first affiliation of the first author. We assigned papers to the 39 fields taken from [González-Márquez et al. (2024)](https://arxiv.org/html/2406.07016v3#bib.bib20 "") based on the journal names: for example, all papers from all journals containing the word neuroscience (such as The Journal of Neuroscience or Nature Neuroscience) were assigned to the ‘neuroscience’ field. We used the first names of the first and the last authors to infer their genders via the gender package ( [Blevins and Mullen, 2015](https://arxiv.org/html/2406.07016v3#bib.bib10 "")). Our gender inference aims to capture perceived gender based on first name and is only approximate. The inference model has clear shortcomings, including limited US-based training data. Moreover, some first names are inherently gender-ambiguous. We were able to infer genders only for 55% of the authors. See [González-Márquez et al. (2024)](https://arxiv.org/html/2406.07016v3#bib.bib20 "") for further details.

### 4.2 Pre-processing

Many abstracts in PubMed data contain strings, usually either in the beginning or in the end, that are not technically part of the abstract text. This can be, for example, “Communicated by:” followed by the name of the editor; or “Copyright ©” followed by the name of the publisher; or “How to cite this article:” followed by the citation string. Such strings often appear in abstracts from a particular journal starting from a particular year, and in this case are picked up by our analysis of excess words.

We spent substantial effort to clean the abstracts from all such contaminating strings, using over 100 regular expressions to find and eliminate them. Overall, 286 744 abstracts were affected by our cleaning procedure. We have also entirely erased 3 514 abstracts of errata, corrigenda, correction, or retraction notices (identified based on titles).

We then computed a binary word occurrence matrix using CountVectorizer(binary=True, min\_df=1e-6) from Scikit-learn ( [Pedregosa et al., 2011](https://arxiv.org/html/2406.07016v3#bib.bib44 "")), obtaining a 15 103 888×362 44115\\,103\\,888\\times 362\\,441 sparse matrix. We focused the subsequent analysis on 273 112273\\,112 words consisting of at least four letters and composed only out of the 26 letters of English alphabet. Note that different strings (e.g. mask and masks) were treated as two distinct words.

### 4.3 Statistical analysis

To avoid possible divisions by zero, all frequencies were always computed as p=(a+1)/(b+1)p=(a+1)/(b+1), where aa is the number of abstracts in a given year containing a given word, and bb is the total number of abstracts in that year.

When computing excess words in year YY, we only looked at words with frequencies above 10−410^{-4} both in year YY and Y−1Y-1. To do the linear extrapolation, we took the frequencies p−3p\_{-3} in year Y−3Y-3 and p−2p\_{-2} in year Y−2Y-2 and computed the counterfactual projection q=p−2+2⋅max⁡{p−2−p−3,0}q=p\_{-2}+2\\cdot\\max\\{p\_{-2}-p\_{-3},0\\}. This way, qq was always at least as large as p−2p\_{-2} (see Figure [1](https://arxiv.org/html/2406.07016v3#S1.F1 "Figure 1 ‣ 1 Introduction ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary")), resulting in conservative estimates of r=p/qr=p/q and δ=p−q\\delta=p-q.

### 4.4 Word annotations and lemmatisation

We identified 900 unique excess words (surpassing our thresholds on rr or δ\\delta) from 2013 to 2024. Some of these words showed excess usage in multiple years. We sorted the list alphabetically and annotated them as content and style words while being blinded to the year in which they were selected as excess words. We assigned parts of speech (nouns, adjectives, verbs, etc.) in the same way. In case of doubt, the words were discussed between the authors. When we were not certain whether a word was content or style because of ambiguous usage, we did not label this word as either content or style.

To lemmatise the words for Figure [S5](https://arxiv.org/html/2406.07016v3#Sx3.F5 "Figure S5 ‣ Supplementary Figures ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary"), we used WordNetLemmatizer() from the Python NLTK library ( [Bird et al., 2009](https://arxiv.org/html/2406.07016v3#bib.bib8 "")), and manually added several lemmas such as chatbots→\\tochatbot and circrnas→\\tocircrna. We also converted British spelling to the US spelling using a dictionary from [https://github.com/hyperreality/American-British-English-Translator](https://github.com/hyperreality/American-British-English-Translator "").

### 4.5 Subgroup analysis

For the analysis presented in Figure [5](https://arxiv.org/html/2406.07016v3#S2.F5 "Figure 5 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") we separately analysed the following subgroups: 50 affiliation countries with the most papers in our dataset; 100 journals with the most papers in our dataset in 2024; all 39 fields taken from [González-Márquez et al. (2024)](https://arxiv.org/html/2406.07016v3#bib.bib20 ""); male and female inferred genders of the first and of the last authors.

We also analyzed several groups of journals pooled together: (1) Nature, Science, and Cell; (2) 31 specialized Nature family journals established in 2018 or earlier (from Nature Aging to Nature Sustainability); (3) all Frontiers journals called Frontiers \*; (4) all journals published by MDPI, selected based on their PubMed names \\* (Basel, Switzerland).

Subgroups were assigned Δ\\Delta values only if they contained at least 300 papers in each year from 2018 to 2023.

### 4.6 LLM usage

We did not use any LLMs for writing or editing the manuscript.

### 4.7 Data and code availability

Our analysis code in Python is available at [https://github.com/berenslab/llm-excess-vocab](https://github.com/berenslab/llm-excess-vocab ""). The 362 442×15362\\,442\\times 15 matrix of yearly word occurrences (for each word and year, the number of abstracts in that year containing that word; the additional last row contains the total number of abstracts in that year) is available in our Github repository as a csv.gz file. Our content/style annotations are also available there as a csv file. The original PubMed data are openly available for bulk download here: [https://pubmed.ncbi.nlm.nih.gov/download](https://pubmed.ncbi.nlm.nih.gov/download "").

## Author contributions

Conceived and designed the experiments: all authors. Performed the experiments: DK. Analyzed the data: DK. Contributed materials/analysis tools: DK, RGM. Wrote the paper: all authors.

## Acknowledgements

This work was conceived at the Dagstuhl seminar 24122 supported by the Leibniz Center for Informatics. This work was funded by the Deutsche Forschungsgemeinschaft (KO6282/2-1) and the Gemeinnützige Hertie-Stiftung. The authors thank the International Max Planck Research School for Intelligent Systems (IMPRS-IS) for supporting RGM. DK is a member of the Germany’s Excellence cluster 2064 “Machine Learning — New Perspectives for Science” (EXC 390727645).
EÁH’s work is supported by NSF CAREER Grant No IIS-1943506. We thank The Economist coverage for inspiring us to use stacked bars in Figure [3](https://arxiv.org/html/2406.07016v3#S2.F3 "Figure 3 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary").

## References

- Ahmed et al. (2023)
Abubakari Ahmed, Aceil Al-Khatib, Yap Boum, Humberto Debat, Alonso Gurmendi Dunkelberg, Lisa Janicke Hinchliffe, Frith Jarrad, Adam Mastroianni, Patrick Mineault, Charlotte R Pennington, et al.

The future of academic publishing.

_Nature Human Behaviour_, 7(7):1021–1026, 2023.

- Akram (2024)
Arslan Akram.

Quantitative analysis of AI-generated texts in academic research: A study of AI presence in arxiv submissions using AI detection tool.

_arXiv preprint arXiv:2403.13812_, 2024.

- Alvero et al. (2024)
AJ Alvero, Jinsook Lee, Alejandra Regla-Vargas, Rene Kizilec, Thorsten Joachims, and Anthony Lising Antonio.

Large language models, social demography, and hegemony: Comparing authorship in human and synthetic text.

_OSF.io_, 2024.

- Astarita et al. (2024)
Simone Astarita, Sandor Kruk, Jan Reerink, and Pablo Gómez.

Delving into the utilisation of ChatGPT in scientific publications in astronomy.

_arXiv preprint arXiv:2406.17324_, 2024.

- Bai et al. (2024)
Xuechunzi Bai, Angelina Wang, Ilia Sucholutsky, and Thomas L Griffiths.

Measuring implicit bias in explicitly unbiased large language models.

_arXiv preprint arXiv:2402.04105_, 2024.

- Bender et al. (2021)
Emily M Bender, Timnit Gebru, Angelina McMillan-Major, and Shmargaret Shmitchell.

On the dangers of stochastic parrots: Can language models be too big?

In _Proceedings of the 2021 ACM Conference on Fairness, Accountability, and Transparency_, pages 610–623, 2021.

- Berdejo-Espinola and Amano (2023)
Violeta Berdejo-Espinola and Tatsuya Amano.

AI tools can improve equity in science.

_Science_, 379(6636):991–991, 2023.

- Bird et al. (2009)
Steven Bird, Ewan Klein, and Edward Loper.

_Natural language processing with Python: analyzing text with the natural language toolkit_.

O’Reilly Media, Inc., 2009.

- Bizzoni et al. (2020)
Yuri Bizzoni, Stefania Degaetano-Ortlieb, Peter Fankhauser, and Elke Teich.

Linguistic variation and change in 250 years of English scientific writing: A data-driven approach.

_Frontiers in Artificial Intelligence_, 3:73, 2020.

- Blevins and Mullen (2015)
Cameron Blevins and Lincoln Mullen.

Jane, John… Leslie? A historical method for algorithmic gender prediction.

_DHQ: Digital Humanities Quarterly_, 9(3):000223, 2015.

- Bochkarev et al. (2014)
Vladimir Bochkarev, Valery Solovyev, and Søren Wichmann.

Universals versus historical contingencies in lexical evolution.

_Journal of The Royal Society Interface_, 11(101):20140841, 2014.

- Borgeaud et al. (2022)
Sebastian Borgeaud, Arthur Mensch, Jordan Hoffmann, Trevor Cai, Eliza Rutherford, Katie Millican, George Bm Van Den Driessche, Jean-Baptiste Lespiau, Bogdan Damoc, Aidan Clark, et al.

Improving language models by retrieving from trillions of tokens.

In _International conference on machine learning_, pages 2206–2240. PMLR, 2022.

- Brainard (2023)
Jeffrey Brainard.

As scientists explore AI-written text, journals hammer out policies.

_Science_, 379(6634):740–741, 2023.

- Brinkmann et al. (2023)
Levin Brinkmann, Fabian Baumann, Jean-François Bonnefon, Maxime Derex, Thomas F Müller, Anne-Marie Nussberger, Agnieszka Czaplicka, Alberto Acerbi, Thomas L Griffiths, Joseph Henrich, et al.

Machine culture.

_Nature Human Behaviour_, 7(11):1855–1868, 2023.

- Cheng et al. (2024)
Huzi Cheng, Bin Sheng, Aaron Lee, Varun Chaudhary, Atanas G Atanasov, Nan Liu, Yue Qiu, Tien Yin Wong, Yih-Chung Tham, and Ying-Feng Zheng.

Have AI-generated texts from LLM infiltrated the realm of scientific writing? A large-scale analysis of preprint platforms.

_bioRxiv_, pages 2024–03, 2024.

- Choudhury (2023)
Monojit Choudhury.

Generative AI has a language problem.

_Nature Human Behaviour_, 7(11):1802–1803, 2023.

- Desaire et al. (2023)
Heather Desaire, Aleesa E Chua, Madeline Isom, Romana Jarosova, and David Hua.

Distinguishing academic science writing from humans or chatgpt with over 99% accuracy using off-the-shelf machine learning tools.

_Cell Reports Physical Science_, 4(6), 2023.

- Dworkin et al. (2020)
Jordan Dworkin, Perry Zurn, and Danielle S Bassett.

(in) citing action to realize an equitable future.

_Neuron_, 106(6):890–894, 2020.

- Geng and Trotta (2024)
Mingmeng Geng and Roberto Trotta.

Is ChatGPT transforming academics’ writing style?

_Next Generation of AI Safety Workshop at ICML 2024_, 2024.

- González-Márquez et al. (2024)
Rita González-Márquez, Luca Schmidt, Benjamin M Schmidt, Philipp Berens, and Dmitry Kobak.

The landscape of biomedical research.

_Patterns_, 2024.

- Gray (2024)
Andrew Gray.

ChatGPT “contamination”: estimating the prevalence of LLMs in the scholarly literature.

_arXiv preprint arXiv:2403.16887_, 2024.

- Gu et al. (2021)
Yu Gu, Robert Tinn, Hao Cheng, Michael Lucas, Naoto Usuyama, Xiaodong Liu, Tristan Naumann, Jianfeng Gao, and Hoifung Poon.

Domain-specific language model pretraining for biomedical natural language processing.

_ACM Transactions on Computing for Healthcare (HEALTH)_, 3(1):1–23, 2021.

- Hall et al. (2008)
David Hall, Dan Jurafsky, and Christopher D Manning.

Studying the history of ideas using topic models.

In _Proceedings of the 2008 Conference on Empirical Methods in Natural Language Processing_, pages 363–371, 2008.

- Heersmink (2024)
Richard Heersmink.

Use of large language models might affect our cognitive skills.

_Nature Human Behaviour_, pages 1–2, 2024.

- Islam et al. (2021)
Nazrul Islam, Vladimir M Shkolnikov, Rolando J Acosta, Ilya Klimkin, Ichiro Kawachi, Rafael A Irizarry, Gianfranco Alicandro, Kamlesh Khunti, Tom Yates, Dmitri A Jdanov, et al.

Excess deaths associated with COVID-19 pandemic in 2020: age and sex disaggregated time series analysis in 29 high income countries.

_bmj_, 373, 2021.

- Ji et al. (2023)
Ziwei Ji, Nayeon Lee, Rita Frieske, Tiezheng Yu, Dan Su, Yan Xu, Etsuko Ishii, Ye Jin Bang, Andrea Madotto, and Pascale Fung.

Survey of hallucination in natural language generation.

_ACM Computing Surveys_, 55(12):1–38, 2023.

- Kaiser (2023)
Jocelyn Kaiser.

Funding agencies say no to AI peer review.

_Science_, 381(6655):261, 2023.

- Karlinsky and Kobak (2021)
Ariel Karlinsky and Dmitry Kobak.

Tracking excess mortality across countries during the COVID-19 pandemic with the World Mortality Dataset.

_eLife_, 10:e69336, 2021.

- Kendall and Teixeira da Silva (2024)
Graham Kendall and Jaime A Teixeira da Silva.

Risks of abuse of large language models, like ChatGPT, in scientific publishing: Authorship, predatory publishing, and paper mills.

_Learned Publishing_, 37(1):55–62, 2024.

- Kim et al. (2024)
Yekyung Kim, Yapei Chang, Marzena Karpinska, Aparna Garimella, Varun Manjunatha, Kyle Lo, Tanya Goyal, and Mohit Iyyer.

FABLES: Evaluating faithfulness and content selection in book-length summarization.

_arXiv preprint arXiv:2404.01261_, 2024.

- Lazebnik and Rosenfeld (2024)
Teddy Lazebnik and Ariel Rosenfeld.

Detecting LLM-assisted writing in scientific communication: Are we there yet?

_arXiv preprint arXiv:2401.16807_, 2024.

- Lewis et al. (2020)
Patrick Lewis, Ethan Perez, Aleksandra Piktus, Fabio Petroni, Vladimir Karpukhin, Naman Goyal, Heinrich Küttler, Mike Lewis, Wen-tau Yih, Tim Rocktäschel, et al.

Retrieval-augmented generation for knowledge-intensive NLP tasks.

_Advances in Neural Information Processing Systems_, 33:9459–9474, 2020.

- Liang et al. (2024a)
Weixin Liang, Zachary Izzo, Yaohui Zhang, Haley Lepp, Hancheng Cao, Xuandong Zhao, Lingjiao Chen, Haotian Ye, Sheng Liu, Zhi Huang, et al.

Monitoring AI-modified content at scale: A case study on the impact of ChatGPT on AI conference peer reviews.

_Forty-first International Conference on Machine Learning_, 2024a.

- Liang et al. (2024b)
Weixin Liang, Yaohui Zhang, Zhengxuan Wu, Haley Lepp, Wenlong Ji, Xuandong Zhao, Hancheng Cao, Sheng Liu, Siyu He, Zhi Huang, et al.

Mapping the increasing use of LLMs in scientific papers.

_arXiv preprint arXiv:2404.01268_, 2024b.

- Lindsay (2023)
Grace W Lindsay.

LLMs are not ready for editorial work.

_Nature Human Behaviour_, 7(11):1814–1815, 2023.

- Liu and Bu (2024)
Jialin Liu and Yi Bu.

Towards the relationship between AIGC in manuscript writing and author profiles: evidence from preprints in LLMs.

_arXiv preprint arXiv:2404.15799_, 2024.

- Matsui (2024)
Kentaro Matsui.

Delving into PubMed records: Some terms in medical writing have drastically changed after the arrival of ChatGPT.

_medRxiv_, pages 2024–05, 2024.

- McCoy et al. (2023)
R Thomas McCoy, Paul Smolensky, Tal Linzen, Jianfeng Gao, and Asli Celikyilmaz.

How much do language models copy from their training data? Evaluating linguistic novelty in text generation using RAVEN.

_Transactions of the Association for Computational Linguistics_, 11:652–670, 2023.

- Mittelstadt et al. (2023)
Brent Mittelstadt, Sandra Wachter, and Chris Russell.

To protect science, we must use LLMs as zero-shot translators.

_Nature Human Behaviour_, 7(11):1830–1832, 2023.

- Msemburi et al. (2023)
William Msemburi, Ariel Karlinsky, Victoria Knutson, Serge Aleshin-Guendel, Somnath Chatterji, and Jon Wakefield.

The WHO estimates of excess mortality associated with the COVID-19 pandemic.

_Nature_, 613(7942):130–137, 2023.

- Nakadai et al. (2023)
Ryosuke Nakadai, Yo Nakawake, and Shota Shibasaki.

AI language tools risk scientific diversity and innovation.

_Nature Human Behaviour_, 7(11):1804–1805, 2023.

- Navigli et al. (2023)
Roberto Navigli, Simone Conia, and Björn Ross.

Biases in large language models: origins, inventory, and discussion.

_ACM Journal of Data and Information Quality_, 15(2):1–21, 2023.

- Padmakumar and He (2023)
Vishakh Padmakumar and He He.

Does writing with language models reduce content diversity?

_arXiv preprint arXiv:2309.05196_, 2023.

- Pedregosa et al. (2011)
Fabian Pedregosa, Gaël Varoquaux, Alexandre Gramfort, Vincent Michel, Bertrand Thirion, Olivier Grisel, Mathieu Blondel, Peter Prettenhofer, Ron Weiss, Vincent Dubourg, et al.

Scikit-learn: Machine learning in Python.

_The Journal of Machine Learning Research_, 12:2825–2830, 2011.

- Picazo-Sanchez and Ortiz-Martin (2024)
Pablo Picazo-Sanchez and Lara Ortiz-Martin.

Analysing the impact of ChatGPT in research.

_Applied Intelligence_, pages 1–17, 2024.

- Retraction Watch (2023)
Retraction Watch.

Hindawi shuttering four journals overrun by paper mills, 2023.

URL [https://web.archive.org/web/20230513163806/https://retractionwatch.com/2023/05/02/hindawi-shuttering-four-journals-overrun-by-paper-mills/](https://web.archive.org/web/20230513163806/https://retractionwatch.com/2023/05/02/hindawi-shuttering-four-journals-overrun-by-paper-mills/ "").

- Stokel-Walker (2023)
Chris Stokel-Walker.

ChatGPT listed as author on research papers: many scientists disapprove.

_Nature_, 613:620–621, 2023.

- Tang et al. (2024a)
Liyan Tang, Igor Shalyminov, Amy Wing-mei Wong, Jon Burnsky, Jake W Vincent, Yu’an Yang, Siffi Singh, Song Feng, Hwanjun Song, Hang Su, et al.

TofuEval: Evaluating hallucinations of llms on topic-focused dialogue summarization.

_arXiv preprint arXiv:2402.13249_, 2024a.

- Tang et al. (2024b)
Ruixiang Tang, Yu-Neng Chuang, and Xia Hu.

The science of detecting LLM-generated text.

_Communications of the ACM_, 67(4):50–59, 2024b.

- Thorp (2023)
H Holden Thorp.

ChatGPT is fun, but not an author, 2023.

- Van der Maaten and Hinton (2008)
Laurens Van der Maaten and Geoffrey Hinton.

Visualizing data using t-SNE.

_Journal of Machine Learning Research_, 9(11), 2008.

- Van Noorden and Perkel (2023)
Richard Van Noorden and Jeffrey M Perkel.

AI and science: what 1,600 researchers think.

_Nature_, 621(7980):672–675, 2023.

- Van Veen et al. (2024)
Dave Van Veen, Cara Van Uden, Louis Blankemeier, Jean-Benoit Delbrouck, Asad Aali, Christian Bluethgen, Anuj Pareek, Malgorzata Polacin, Eduardo Pontes Reis, Anna Seehofnerová, et al.

Adapted large language models can outperform medical experts in clinical text summarization.

_Nature Medicine_, pages 1–9, 2024.

- Walters and Wilder (2023)
William H Walters and Esther Isabelle Wilder.

Fabrication and errors in the bibliographic citations generated by ChatGPT.

_Scientific Reports_, 13(1):14045, 2023.

- Yakura et al. (2024)
Hiromu Yakura, Ezequiel Lopez-Lopez, Levin Brinkmann, Ignacio Serna, Prateek Gupta, and Iyad Rahwan.

Empirical evidence of Large Language Model’s influence on human spoken communication.

_arXiv preprint arXiv:2409.01754_, 2024.

- Zhang et al. (2024)
Tianyi Zhang, Faisal Ladhak, Esin Durmus, Percy Liang, Kathleen McKeown, and Tatsunori B Hashimoto.

Benchmarking large language models for news summarization.

_Transactions of the Association for Computational Linguistics_, 12:39–57, 2024.

- Zhang et al. (2023)
Yue Zhang, Yafu Li, Leyang Cui, Deng Cai, Lemao Liu, Tingchen Fu, Xinting Huang, Enbo Zhao, Yu Zhang, Yulong Chen, et al.

Siren’s song in the AI ocean: a survey on hallucination in large language models.

_arXiv preprint arXiv:2309.01219_, 2023.

- Zheng and Zhan (2023)
Haoyi Zheng and Huichun Zhan.

ChatGPT in scientific writing: a cautionary tale.

_The American Journal of Medicine_, 136(8):725–726, 2023.


## Supplementary Figures

![Refer to caption](https://arxiv.org/html/2406.07016v3/words2013.png)

![Refer to caption](https://arxiv.org/html/2406.07016v3/words2014.png)

Figure S1: Excess words in 2013 and 2014. See Figure [2](https://arxiv.org/html/2406.07016v3#S1.F2 "Figure 2 ‣ 1 Introduction ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") for explanations.

![Refer to caption](https://arxiv.org/html/2406.07016v3/words2015.png)

![Refer to caption](https://arxiv.org/html/2406.07016v3/words2016.png)

![Refer to caption](https://arxiv.org/html/2406.07016v3/words2017.png)

Figure S2: Excess words in 2015–2017. See Figure [2](https://arxiv.org/html/2406.07016v3#S1.F2 "Figure 2 ‣ 1 Introduction ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") for explanations. Note that the excess word mitogenome (2016) is not shown in Figure [3](https://arxiv.org/html/2406.07016v3#S2.F3 "Figure 3 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") a because it was mostly used in a single journal (Mitochondrial DNA) and so we considered it not representative of the entire biomedical literature.

![Refer to caption](https://arxiv.org/html/2406.07016v3/words2018.png)

![Refer to caption](https://arxiv.org/html/2406.07016v3/words2019.png)

![Refer to caption](https://arxiv.org/html/2406.07016v3/words2020.png)

Figure S3: Excess words in 2018–2020. See Figure [2](https://arxiv.org/html/2406.07016v3#S1.F2 "Figure 2 ‣ 1 Introduction ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") for explanations.

![Refer to caption](https://arxiv.org/html/2406.07016v3/words2021.png)

![Refer to caption](https://arxiv.org/html/2406.07016v3/words2022.png)

![Refer to caption](https://arxiv.org/html/2406.07016v3/words2023.png)

Figure S4: Excess words in 2021–2023. See Figure [2](https://arxiv.org/html/2406.07016v3#S1.F2 "Figure 2 ‣ 1 Introduction ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") for explanations.Figure S5: The same as Figure [3](https://arxiv.org/html/2406.07016v3#S2.F3 "Figure 3 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary") but showing the number of unique lemmas of excess words, instead of the number of excess words. This counts delve, delves, delving, and delved (or mask and masks) only once.

accentuates, acknowledges, acknowledging, addresses, adept, adhered, adhering, advancement, advancements, advancing, advocates, advocating, affirming, afflicted, aiding, akin, align, aligning, aligns, alongside, amidst, assessments, attains, attributed, augmenting, avenue, avenues, bolster, bolstered, bolstering, broader, burgeoning, capabilities, capitalizing, categorized, categorizes, categorizing, combating, commendable, compelling, complicates, complicating, comprehending, comprising, consequently, consolidates, contributing, conversely, correlating, crafted, crafting, culminating, customizing, delineates, delve, delved, delves, delving, demonstrating, dependability, dependable, detailing, detrimentally, diminishes, diminishing, discern, discerned, discernible, discerning, displaying, disrupts, distinctions, distinctive, elevate, elevates, elevating, elucidate, elucidates, elucidating, embracing, emerges, emphasises, emphasising, emphasize, emphasizes, emphasizing, employing, employs, empowers, emulating, emulation, enabling, encapsulates, encompass, encompassed, encompasses, encompassing, endeavors, endeavours, enduring, enhancements, enhances, ensuring, equipping, escalating, evaluates, evolving, exacerbating, examines, exceeding, excels, exceptional, exceptionally, exerting, exhibiting, exhibits, expedite, expediting, exploration, explores, facilitated, facilitates, facilitating, featuring, formidable, fostering, fosters, foundational, furnish, garnered, garnering, gauged, grappling, groundbreaking, groundwork, harness, harnesses, harnessing, heighten, heightened, hinder, hinges, hinting, hold, holds, illuminates, illuminating, imbalances, impacting, impede, impeding, imperative, impressive, inadequately, incorporates, incorporating, influencing, inherent, initially, innovative, inquiries, integrates, integrating, integration, interconnectedness, interplay, intricacies, intricate, intricately, introduces, invaluable, investigates, involves, juxtaposed, leverages, leveraging, maintaining, merges, methodologies, meticulous, meticulously, multifaceted, necessitate, necessitates, necessitating, necessity, notable, noteworthy, nuanced, nuances, offering, optimizing, orchestrating, outlines, overlook, overlooking, paving, persist, pinpoint, pinpointed, pinpointing, pioneering, pioneers, pivotal, poised, pose, posed, poses, posing, predominantly, preserving, pressing, promise, pronounced, propelling, realm, realms, recognizing, refine, refines, refining, remarkable, renowned, revealing, reveals, revolutionize, revolutionizing, revolves, scrutinize, scrutinized, scrutinizing, seamless, seamlessly, seeks, serves, serving, shaping, shedding, showcased, showcases, showcasing, signifying, solidify, spanned, spanning, spurred, stands, stemming, strategically, streamline, streamlined, streamlines, streamlining, struggle, substantiated, substantiates, surged, surmount, surpass, surpassed, surpasses, surpassing, swift, swiftly, thorough, transformative, typically, ultimately, uncharted, uncovering, underexplored, underscore, underscored, underscores, underscoring, unexplored, unlocking, unparalleled, unraveling, unveil, unveiled, unveiling, unveils, uphold, upholding, urging, utilizes, varying, versatility, warranting, yielding

Figure S6: All 291 excess style words in 2024 with frequency below 0.02, see Figure [4](https://arxiv.org/html/2406.07016v3#S2.F4 "Figure 4 ‣ 2.1 Excess words indicate widespread LLM usage ‣ 2 Results ‣ Delving into LLM-assisted writing in biomedical publications through excess vocabulary").![Refer to caption](https://arxiv.org/html/2406.07016v3/tsne.png)Figure S7: A 2D visualisation of all 4 109 080 abstracts from 2022 to 2024. Following [González-Márquez et al. (2024)](https://arxiv.org/html/2406.07016v3#bib.bib20 ""), we used the \[SEP\] token of the pre-trained PubMedBERT model ( [Gu et al., 2021](https://arxiv.org/html/2406.07016v3#bib.bib22 "")) to obtain 768-dimensional vector representation of each abstract, and then used tt-SNE ( [Van der Maaten and Hinton, 2008](https://arxiv.org/html/2406.07016v3#bib.bib51 "")) to visualize the results in 2D. Top left: colored by field. Labels are positioned at the peak density of each field. Top right: colored by the affiliation country. Bottom left: colored by publication year. Bottom right: colored by local LLM usage. The local LLM usage was defined for each paper based on its nearest neighbors in 2D. Within this local neighborhood, we computed Δrare\\Delta\_{\\text{rare}} and Δcommon\\Delta\_{\\text{common}} (see main text for details): For the 100 neighboring 2022 abstracts (and for the 100 neighboring 2024 abstracts), we found the fraction of abstracts containing at least one of the rare (and at least one of the common) excess words. Taking the difference between years yielded Δrare\\Delta\_{\\text{rare}} and Δcommon\\Delta\_{\\text{common}}, which we averaged to obtain the final Δ\\Delta value. This was done separately for each of the embedded abstracts. Note that the regions with high Δ\\Delta do not consist of only 2024 papers (third panel), but rather of a mix of 2022–2024 papers. This means that our embedding model does not group abstracts based on LLM-associated keywords, but rather by topic. Black circle in all panels highlights one example area with Δ≈0.50\\Delta\\approx 0.50; it consists of ∼\\sim400 papers on deep-learning-based object detection, with predominantly Chinese affiliations (83.4%) and with the majority published in Sensors (56.3%). Note: a cluster of papers from 2022 (dark blue in the lower-left panel) to the lower-right of the circle contains papers with predominantly Chinese affiliations (79.9%), with many (48.7%) coming from the four journals from the Hindawi publisher that were all shut down in 2023 as “heavily compromised by paper mills” ( [Retraction Watch, 2023](https://arxiv.org/html/2406.07016v3#bib.bib46 "")); 28.8% of the papers in this island have been retracted.

Experimental support, please
[view the build logs](https://arxiv.org/html/2406.07016v3/__stdout.txt)
for errors. Generated by
[L\\
A\\
T\\
Exml![[LOGO]](<Base64-Image-Removed>)](https://math.nist.gov/~BMiller/LaTeXML/).


## Instructions for reporting errors

We are continuing to improve HTML versions of papers, and your feedback helps enhance accessibility and mobile
support. To report errors in the HTML that will help us improve conversion and rendering, choose any of the
methods listed below:

- Click the "Report Issue" () button, located in the page header.

**Tip:** You can select the relevant text first, to include it in your report.

Our team has already identified [the following issues](https://github.com/arXiv/html_feedback/issues). We appreciate your time reviewing and reporting rendering errors we
may not have found yet. Your efforts will help us improve the HTML versions for all readers, because disability
should not be a barrier to accessing research. Thank you for your continued support in championing open access for
all.

Have a free development cycle? Help support accessibility at arXiv! Our collaborators at LaTeXML maintain a [list of packages that need conversion](https://github.com/brucemiller/LaTeXML/wiki/Porting-LaTeX-packages-for-LaTeXML), and welcome [developer contributions](https://github.com/brucemiller/LaTeXML/issues).

We gratefully acknowledge support from
our **major funders**,
[**member institutions**](https://info.arxiv.org/about/ourmembers.html), ,
and all contributors.


[About](https://info.arxiv.org/about)· [Help](https://info.arxiv.org/help)· [Contact](https://info.arxiv.org/help/contact.html)· [Subscribe](https://info.arxiv.org/help/subscribe)· [Copyright](https://info.arxiv.org/help/license/index.html)· [Privacy](https://info.arxiv.org/help/policies/privacy_policy.html)· [Accessibility](https://info.arxiv.org/help/web_accessibility.html)· [Operational Status (opens in new tab)](https://status.arxiv.org/)

Major funding support from

[![Simons Foundation](https://arxiv.org/static/base/1.0.1/images/funders/simons-foundation.png)](https://www.simonsfoundation.org/)[![Simons Foundation International](https://arxiv.org/static/base/1.0.1/images/funders/simons-foundation-international.png)](https://www.sfi.org.bm/)[![Schmidt Sciences](https://arxiv.org/static/base/1.0.1/images/funders/schmidt-sciences.png)](https://www.schmidtsciences.org/)