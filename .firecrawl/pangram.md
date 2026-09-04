[![Pangram Logo](https://pangram-public.s3.us-east-1.amazonaws.com/web/brand/Logo%2BDark+Wordmark.svg)](https://www.pangram.com/)

- Products
- Solutions
- Company
- Resources

[Pricing](https://www.pangram.com/pricing) [Contact Sales](https://www.pangram.com/enterprise)

[Login](https://www.pangram.com/login) [Try It for Free](https://www.pangram.com/signup)

[![Pangram Logo](https://pangram-public.s3.us-east-1.amazonaws.com/web/brand/Logo%2BDark+Wordmark.svg)](https://www.pangram.com/)

[Try It for Free](https://www.pangram.com/signup)

1. [Blog](https://www.pangram.com/blog)
3. [AI Education](https://www.pangram.com/blog?category=education)
5. Why Perplexity and Burstiness Fail to Detect AI

AI Education

# Why Perplexity and Burstiness Fail to Detect AI

Perplexity and burstiness sound scientific, but they can't reliably detect AI writing at a low false positive rate — here's what they measure and why they fail.

![Bradley Emi](https://www.pangram.com/_next/image?url=https%3A%2F%2Fpangram-public.s3.us-east-1.amazonaws.com%2Fweb%2Fassets%2FBradley.png&w=64&q=75)

[Bradley Emi](https://www.pangram.com/authors/bradley-emi)

▪Mar 4, 2025

[Share on X](https://x.com/intent/tweet?url=https%3A%2F%2Fwww.pangram.com%2Fblog%2Fwhy-perplexity-and-burstiness-fail-to-detect-ai&text=Why%20Perplexity%20and%20Burstiness%20Fail%20to%20Detect%20AI "Share on X")[Share on LinkedIn](https://www.linkedin.com/sharing/share-offsite/?mini=true&url=https%3A%2F%2Fwww.pangram.com%2Fblog%2Fwhy-perplexity-and-burstiness-fail-to-detect-ai "Share on LinkedIn")[Share on Reddit](https://reddit.com/submit?url=https%3A%2F%2Fwww.pangram.com%2Fblog%2Fwhy-perplexity-and-burstiness-fail-to-detect-ai&title=Why%20Perplexity%20and%20Burstiness%20Fail%20to%20Detect%20AI "Share on Reddit")

Table of contents

* * *

1. [What are perplexity and burstiness?](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#what-are-perplexity-and-burstiness)
2. [How do perplexity and burstiness based detectors work?](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#how-do-perplexity-and-burstiness-based-detectors-work)
3. [Shortcoming #1: Text in the Training Set is Falsely Classified as AI](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#shortcoming-1-text-in-the-training-set-is-falsely-classified-as-ai)
4. [Shortcoming #2: Perplexity and Burstiness are Different for Different Language Models](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#shortcoming-2-perplexity-and-burstiness-are-different-for-different-language-models)
5. [Shortcoming #3: Commercial Models do not Always Expose Perplexity](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#shortcoming-3-commercial-models-do-not-always-expose-perplexity)
6. [Shortcoming #4: Nonnative English Text (ESL) is Falsely Classified as AI](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#shortcoming-4-nonnative-english-text-esl-is-falsely-classified-as-ai)
7. [Shortcoming #5: Perplexity-based Detectors Cannot Iteratively Self-Improve](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#shortcoming-5-perplexity-based-detectors-cannot-iteratively-self-improve)
8. [Resources and Further Reading](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#resources-and-further-reading)
9. [Conclusion](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#conclusion)

Outline

1. [What are perplexity and burstiness?](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#what-are-perplexity-and-burstiness)
2. [How do perplexity and burstiness based detectors work?](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#how-do-perplexity-and-burstiness-based-detectors-work)
3. [Shortcoming #1: Text in the Training Set is Falsely Classified as AI](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#shortcoming-1-text-in-the-training-set-is-falsely-classified-as-ai)
4. [Shortcoming #2: Perplexity and Burstiness are Different for Different Language Models](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#shortcoming-2-perplexity-and-burstiness-are-different-for-different-language-models)
5. [Shortcoming #3: Commercial Models do not Always Expose Perplexity](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#shortcoming-3-commercial-models-do-not-always-expose-perplexity)
6. [Shortcoming #4: Nonnative English Text (ESL) is Falsely Classified as AI](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#shortcoming-4-nonnative-english-text-esl-is-falsely-classified-as-ai)
7. [Shortcoming #5: Perplexity-based Detectors Cannot Iteratively Self-Improve](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#shortcoming-5-perplexity-based-detectors-cannot-iteratively-self-improve)
8. [Resources and Further Reading](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#resources-and-further-reading)
9. [Conclusion](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#conclusion)

When you search online for how AI detectors work, you'll typically see many sources citing the terms "perplexity" and "burstiness". What do these terms mean, and why do they ultimately not work for detecting AI-generated content? Today I want to unpack what perplexity and burstiness are, and explain why they are not suitable for detecting AI-generated writing. We'll also get into the understanding of why they don't work, and why perplexity and burstiness based detectors falsely cite the Declaration of Independence as AI-generated, and why these detectors are also biased against nonnative English speakers. Let's go!

## What are perplexity and burstiness?

We'll start with an imprecise nontechnical definition of perplexity, just to get a general sense of what perplexity is and what it's doing. For more background on perplexity, I found [this two minute explainer article](https://medium.com/nlplanet/two-minutes-nlp-perplexity-explained-with-simple-probabilities-6cdc46884584) to be very useful.

Perplexity is how unexpected, or surprising, each word in a piece of text is, when looked at from the perspective of a particular language model or LLM.

For example, here are two sentences. Let's focus on the last word of each sentence, for demonstration purposes. In the first example, the last word has low perplexity, while in the second example, the last word has high perplexity.

_Low perplexity_:

`For lunch today, I ate a bowl of *soup*.`

_High perplexity_:

`For lunch today, I ate a bowl of *spiders*.`

The reason that the second sentence is high perplexity is because very rarely would a language model see examples of people eating bowls of spiders in its training dataset, and so it is very surprising to the language model that the sentence ends with "spiders", as opposed to something like "soup" or "a sandwich" or "a salad".

Perplexity comes from the same root as the word "perplexed", which means "confused" or "puzzled". It is helpful to think of perplexity as the confusion of the language model: when it sees something that is unfamiliar or unexpected, in comparison to what it has read and ingested in its training procedure, then we can think of the language model as getting confused or befuddled by the completion.

Okay, great, so what about burstiness? Burstiness is the change in perplexity over the course of a document. If some surprising words and phrases are interspersed throughout the document, we would say that it is high in burstiness.

## How do perplexity and burstiness based detectors work?

Unfortunately, most commercial detectors (aside from Pangram) are not transparent about their methodology, but from what is understood by their descriptions, human text is considered to be higher perplexity and higher in burstiness than AI-generated text, and AI-generated text is lower probability and lower burstiness.

We can see a visualization of this below! I downloaded the [GPT-2 model](https://huggingface.co/openai-community/gpt2) off of Huggingface, and calculated the perplexity of all the text in two documents: one set of human restaurant reviews, and one set of AI-generated reviews. I then highlighted the low perplexity text in blue, and the high perplexity text in red.

![Perplexity visualization comparing AI and human text](https://www.pangram.com/_next/image?url=https%3A%2F%2Fpangram-public.s3.us-east-1.amazonaws.com%2Fweb%2Fblog%2F35%2Fai_vs_human_ppl.png&w=3840&q=75)Perplexity visualization comparing AI and human text

As you can see, the AI-generated text is a deep blue all around, suggesting uniform low perplexity values. And the human-generated text is mostly blue, but has spikes of red in it. That's what we would say is high burstiness.

It's this idea that inspires perplexity and burstiness detectors. Not only are some of the earliest commercial AI detectors based on this idea, but it has also inspired some academic literature such as DetectGPT and Binoculars.

To be completely fair, these perplexity and burstiness detectors do work some of the time! We just do not believe that they can work reliably in high stakes settings where inaccuracies must be avoided, such as in the classroom, where a false positive AI detection can potentially undermine trust between the teacher and the student, or even worse, create inaccurate evidence in a legal case.

## Shortcoming \#1: Text in the Training Set is Falsely Classified as AI

For those unfamiliar with how LLMs are created, before LLMs are available to be deployed and used as chatbots, they must first undergo a procedure called training. During training, the language model sees billions of texts and learns the underlying linguistic patterns of what is called its "training set".

The precise mechanical details of the training procedure are out of scope of this blog post, but the one critical detail is that in the optimization process, the LLM is directly incentivized to _minimize_ perplexity on its training set documents! In other words, the model learns over time that the pieces of text that it sees repeatedly in its training procedure should have as little perplexity as possible.

Why is that a problem?

Because the model is asked to make its training set documents low perplexity, perplexity and burstiness detectors classify common training set documents as AI, even when the training set documents are actually human written!

That is why perplexity-based AI detectors classify the Declaration of Independence as AI-generated: because the Declaration of Independence is a famous historical document that has been reproduced in countless textbooks and Internet articles across the web, it shows up in AI training sets... a lot. And because the text is exactly the same every time it is seen during training, the model can memorize what the Declaration of Independence is when it sees it, and then automatically assign all of the tokens a very low perplexity, which then also makes the burstiness really low too.

I ran the same visualization above on the Declaration of Independence-- and we see the same AI signature: a deep, consistent blue color throughout, indicating every word has low perplexity. From the perspective of a perplexity and burstiness based detector, the Declaration of Independence is completely indistinguishable from AI-generated content.

Interestingly, we notice that the first sentence of the Declaration of Independence, is even deeper blue and low perplexity than the rest. This happens because the first sentence is by far the most reproduced part of the passage, and shows up the most frequently in the GPT-2 training set.

![Perplexity visualization of the Declaration of Independence](https://www.pangram.com/_next/image?url=https%3A%2F%2Fpangram-public.s3.us-east-1.amazonaws.com%2Fweb%2Fblog%2F35%2Fdeclaration_ppl.png&w=3840&q=75)Perplexity visualization of the Declaration of Independence

Similarly, we find that other common sources of LLM training data also see elevated false positive rates with perplexity and burstiness detectors. Wikipedia is a very common training dataset due to its high quality and unrestrictive license: and therefore it is extremely commonly mispredicted as AI-generated because the language models are directly optimized to reduce perplexity on Wikipedia articles.

This is a worsening problem as AI continues to develop and becomem more advanced because the newest language models are extremely data hungry: OpenAI and Google and Anthropic's crawlers are all furiously scraping the Internet as you read this article, continuing to ingest data for language model training. Should publishers and website owners have to worry that allowing these scrapers to crawl their website for LLM training might mean that their content might get misclassified as AI-generated in the future? Should companies considering licensing their data to OpenAI have to weigh the risk of that data also coming back to be mispredicted as AI once the LLMs ingest it? We find this a completely unacceptable failure case, and one that is worsening over time.

## Shortcoming \#2: Perplexity and Burstiness are Different for Different Language Models

Another problem with using perplexity and burstiness as metrics for detection is that they are relative to a _particular_ language model. What may be expected for GPT for example may not be expected for Claude. And when new models come out, their perplexity is different as well.

So called "black box" perplexity based detectors need to choose a language model to measure the actual perplexity. But when that language model's perplexity differs from the generator's perplexity, you get wildly inaccurate results, and this problem only compounds with new model releases.

## Shortcoming \#3: Commercial Models do not Always Expose Perplexity

Closed source providers do not always serve the probabilities of each token, so you cannot even calculate perplexity for closed-source commerical models, such as ChatGPT, Gemini, and Claude. At best, you can use an open-source model to measure perplexity, but that runs into the same problems as Shortcoming 2.

## Shortcoming \#4: Nonnative English Text (ESL) is Falsely Classified as AI

A narrative has emerged that AI detection is biased against nonnative English speakers, supported by a [2023 Stanford study on 91 TOEFL essays](https://arxiv.org/abs/2304.02819). While Pangram extensively benchmarks nonnative English text and incorporates it into our training set so the model is able to recognize and detect it, perplexity based detectors do indeed have an elevated false positive rate on nonnative English text.

The reason for this is because text written by English language learners is lower perplexity and lower burstiness in general. We believe that this is not an accident: this arises because during the language learning process, the student's vocabulary is significantly more limited, and the student is also not able to form complex sentence structures that would be out of the ordinary, or high surprisingness, for a language model. We argue that learning to write in a high perplexity, bursty way that is still linguistically correct is an advanced language skill that comes from experience with the language.

Nonnative English speakers, and we believe by extension neurodiverse students or students with disabilities, are more vulnerable to being caught by perplexity-based AI detectors.

## Shortcoming \#5: Perplexity-based Detectors Cannot Iteratively Self-Improve

What we believe is the biggest shortcoming of perplexity based detectors, and why we at Pangram chose a deep learning based approach instead, is that these perplexity-based detectors cannot self-improve with data and compute scale.

What does this mean? As Pangram gets more experience with human text through our active learning algorithm, it gradually gets better. That is how we have gotten our false positive rate from 2%, to 1%, to 0.1%, and now down to 0.01%. Perplexity based detectors are not able to improve by seeing more data.

## Resources and Further Reading

- [DetectGPT: Zero-Shot Machine-Generated Text Detection using Probability Curvature](https://arxiv.org/abs/2301.11305) is a paper that looks at the local perplexity landscape to distinguish human and AI writing rather than absolute perplexity values.

- [Spotting LLMs with Binoculars: Zero-Shot Detection of Machine-Generated Text](https://arxiv.org/abs/2401.12070) uses a novel metric called "cross-perplexity" to improve upon basic perplexity detection.

- [Pangram's technical whitepaper](https://www.pangram.com/blog/technical-report-february-2024) goes deeper into our alternative solution for detecting AI-generated text based on deep active learning.


## Conclusion

There's a big difference between computing a statistic that _correlates_ with AI-generated writing and building a production grade system that can _reliably_ detect AI-generated writing. While perplexity based detectors capture an important facet of what makes human writing human and what makes AI writing AI, for the reasons described in this article, you cannot use a perplexity based detector to reliably detect AI-generated writing while maintaining a false positive rate low enough for production applications.

In environments like education where false positive avoidance is critical, we hope to see more research move towards deep learning based methods and away from perplexity and burstiness, or metric-based methods.

We hope this gives some insight into why Pangram has chosen not to use perplexity and burstiness to detect AI-generated text, and instead focus on reliable methods that scale.

Pangram uses deep learning instead of statistical heuristics. Try our [AI content detector](https://www.pangram.com/) for production-grade accuracy.

* * *

![Bradley Emi](https://www.pangram.com/_next/image?url=https%3A%2F%2Fpangram-public.s3.us-east-1.amazonaws.com%2Fweb%2Fassets%2FBradley.png&w=256&q=75)

[Bradley Emi](https://www.pangram.com/authors/bradley-emi) CTO, Co-founder

Bradley is an AI researcher and expert in building deep learning products in industry. He recently led the deep learning research group at Absci, a generative AI drug discovery company, and previously was a member of the core computer vision team at Tesla Autopilot.

[More from Bradley Emi→](https://www.pangram.com/authors/bradley-emi)

## Related reading

[![AI Checkers for Teachers: Why Schools Need AI Detection Tools](https://www.pangram.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2F6vunltag%2Fproduction%2Faeb3aa302776c2710f0da5925a494a33e369ff15-4845x3484.jpg&w=3840&q=75)\\
\\
AI Education **AI Checkers for Teachers: Why Schools Need AI Detection Tools** \\
\\
I meet a lot of teachers who have the same perspective regarding checking students' writing for AI. I often hear, “I know my students' writing, so I don't need AI detection software.\\
\\
Jason Nicholson▪Feb 4, 2025](https://www.pangram.com/blog/why-teachers-still-need-ai-detection-tools) [![How well does Pangram work on AI code?](https://www.pangram.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2F6vunltag%2Fproduction%2Fe0343fc365ff162830f858216c33ee083cf4cb33-3840x2160.jpg&w=3840&q=75)\\
\\
AI Education **How well does Pangram work on AI code?** \\
\\
Bradley Emi▪Oct 7, 2025](https://www.pangram.com/blog/can-ai-generated-code-be-detected) [![AI Cover Letter Checker - How HR Teams are Filtering Noise ](https://www.pangram.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2F6vunltag%2Fproduction%2Fa0cb9acde3cd54a9dbabf739706ee28094c1df83-1200x630.png&w=3840&q=75)\\
\\
AI Education **AI Cover Letter Checker - How HR Teams are Filtering Noise** \\
\\
HR teams are overwhelmed with hundreds of AI-generated cover letters, which they have to wade through to find sincere high-quality candidates they actually want to send to hiring manager. Pangram can help.\\
\\
Alex Roitman▪May 11, 2026](https://www.pangram.com/blog/ai-cover-letter-checker) [![Comprehensive Guide to Spotting AI Writing Patterns](https://www.pangram.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2F6vunltag%2Fproduction%2F2f9b7adc40aaa655be22838db0ad3272ac5c4be6-6289x4193.jpg&w=3840&q=75)\\
\\
AI Education **Comprehensive Guide to Spotting AI Writing Patterns** \\
\\
A comprehensive guide to spotting the linguistic patterns in AI-generated text.\\
\\
Bradley Emi▪Apr 2, 2025](https://www.pangram.com/blog/comprehensive-guide-to-spotting-ai-writing-patterns) [![Can AI detection catch Claude writing styles?](https://www.pangram.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2F6vunltag%2Fproduction%2Fd050b1ee89e5ba84723e241f75d17a89910aea47-1752x998.png&w=3840&q=75)\\
\\
AI Education **Can AI detection catch Claude writing styles?** \\
\\
In November, Anthropic released an update to Claude. ai allowing users to choose which tone of voice the assistant will respond with.\\
\\
Max Spero▪Dec 6, 2024](https://www.pangram.com/blog/claude-writing-styles) [![Mirror, Mirror On The Wall, Who’s The Realest Of Them All?](https://www.pangram.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2F6vunltag%2Fproduction%2F074451c2ab25e738faff77c68561ff77d7300052-5562x3614.jpg&w=3840&q=75)\\
\\
AI Education **Mirror, Mirror On The Wall, Who’s The Realest Of Them All?** \\
\\
Technology and progress have abounded, but the process of learning hasn’t changed. It is still very much what I like to call an “experience of a concept” activity. That said, while learning hasn’t changed, the obstacles around it have.\\
\\
Jason Nicholson▪Jul 25, 2025](https://www.pangram.com/blog/mirror-mirror-on-the-wall-who-s-the-realest-of-them-all)

[![Pangram Logo](https://pangram-public.s3.us-east-1.amazonaws.com/web/brand/Logo%2BDark+Wordmark.svg)](https://www.pangram.com/)

Products

[AI Detector](https://www.pangram.com/) [AI Image Detector](https://www.pangram.com/image-detector) [Browser Extension](https://www.pangram.com/solutions/chrome-extension) [API](https://www.pangram.com/solutions/api) [Integrations](https://www.pangram.com/solutions/integrations) [Plagiarism Checker](https://www.pangram.com/solutions/plagiarism) [Multilingual AI Detection](https://www.pangram.com/solutions/multilingual)

For Organizations

[For Teachers](https://www.pangram.com/use-cases/teachers) [For Publishing & Media](https://www.pangram.com/use-cases/publishing) [For Content Moderation](https://www.pangram.com/use-cases/trust-and-safety) [For Developers](https://www.pangram.com/use-cases/developers) [For Law Firms](https://www.pangram.com/use-cases/law-firms) [For Universities](https://www.pangram.com/use-cases/universities) [For Recruiters](https://www.pangram.com/use-cases/recruiters) [For ML Engineers](https://www.pangram.com/use-cases/ml-engineers) [For Compliance](https://www.pangram.com/use-cases/compliance)

Research

[How AI Detection Works](https://www.pangram.com/research/how-it-works) [Pangram Research Papers](https://www.pangram.com/research/papers) [Research Inquiries](https://www.pangram.com/contact-us/research) [Press](https://www.pangram.com/press) [Models](https://www.pangram.com/research/model-card) [Events](https://www.pangram.com/events) [Reviews](https://www.pangram.com/testimonials-reviews)

Resources

[Knowledge Hub](https://www.pangram.com/knowledge-hub) [AI education](https://www.pangram.com/blog?category=education) [Product updates](https://www.pangram.com/blog?category=productUpdates) [News](https://www.pangram.com/blog?category=news) [Case studies](https://www.pangram.com/blog?category=caseStudies) [Blog](https://www.pangram.com/blog) [Pricing](https://www.pangram.com/pricing) [Terms of Service](https://www.pangram.com/terms-of-service) [Privacy Policy](https://www.pangram.com/privacy-policy) [Data Privacy FAQ](https://www.pangram.com/data-privacy) [Status](https://status.pangram.com/)

Company

[About Us](https://www.pangram.com/about-us) [Contact Us](https://www.pangram.com/contact-us) [Careers](https://jobs.ashbyhq.com/pangramlabs) [Press](https://www.pangram.com/press)

![soc2](https://www.pangram.com/_next/image?url=https%3A%2F%2Fpangram-public.s3.us-east-1.amazonaws.com%2Fweb%2Fassets%2Flogos%2Fsoc2.png&w=256&q=75)

SOC2TYPE2

Verified by AssuranceLab

© 2026 Pangram. All rights reserved.

[info@pangram.com](mailto:info@pangram.com)

[Pangram Labs on Instagram](https://www.instagram.com/pangramlabs/ "Pangram Labs on Instagram")[Pangram Labs on X](https://x.com/pangram "Pangram Labs on X")[Pangram Labs on LinkedIn](https://www.linkedin.com/company/pangramlabs/ "Pangram Labs on LinkedIn")[Pangram Labs on TikTok](https://tiktok.com/@pangramlabs/ "Pangram Labs on TikTok")

[Join our Community](https://discord.gg/f7jDAPzWH3 "Join the Pangram Labs Discord channel")

© 2026 Pangram. All rights reserved.

[![](https://cdn.weglot.com/flags/rectangle_mat/us.svg)EN](https://www.pangram.com/blog/why-perplexity-and-burstiness-fail-to-detect-ai#)

- [![](https://cdn.weglot.com/flags/rectangle_mat/pt.svg)PT](https://www.pangram.com/pt/blog/why-perplexity-and-burstiness-fail-to-detect-ai)
- [![](https://cdn.weglot.com/flags/rectangle_mat/tr.svg)TR](https://www.pangram.com/tr/blog/why-perplexity-and-burstiness-fail-to-detect-ai)
- [![](https://cdn.weglot.com/flags/rectangle_mat/fr.svg)FR](https://www.pangram.com/fr/blog/why-perplexity-and-burstiness-fail-to-detect-ai)
- [![](https://cdn.weglot.com/flags/rectangle_mat/de.svg)DE](https://www.pangram.com/de/blog/why-perplexity-and-burstiness-fail-to-detect-ai)
- [![](https://cdn.weglot.com/flags/rectangle_mat/es.svg)ES](https://www.pangram.com/es/blog/why-perplexity-and-burstiness-fail-to-detect-ai)
- [![](https://cdn.weglot.com/flags/rectangle_mat/cn.svg)ZH](https://www.pangram.com/zh/blog/why-perplexity-and-burstiness-fail-to-detect-ai)
- [![](https://cdn.weglot.com/flags/rectangle_mat/jp.svg)JA](https://www.pangram.com/ja/blog/why-perplexity-and-burstiness-fail-to-detect-ai)
- [![](https://cdn.weglot.com/flags/rectangle_mat/sa.svg)AR](https://www.pangram.com/ar/blog/why-perplexity-and-burstiness-fail-to-detect-ai)
- [![](https://cdn.weglot.com/flags/rectangle_mat/it.svg)IT](https://www.pangram.com/it/blog/why-perplexity-and-burstiness-fail-to-detect-ai)