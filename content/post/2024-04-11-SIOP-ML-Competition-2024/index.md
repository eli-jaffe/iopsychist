---
title: SIOP ML Competition 2024 - LLMs
author: "IOPsychist"
slug: siop-ml-competition-2024
date: "2024-04-11"
categories:
  - Showcase
  - Code
  - Python
  - LLM
  
---

#  Generative AI in I/O Psychology: Insights from the SIOP 2024 Machine Learning Competition
### And How I chained LLMs for Modeling Using Just My Personal Laptop

I recently had the opportunity to participate in the SIOP 2024 Machine Learning Competition. This year’s competition was a playground for showcasing the synergy between Large Language Models (LLMs) and Industrial/Organizational (I/O) Psychology, aiming to explore the potentials and boundaries of AI in our field. It was a nice chance to play around with I/O data and expand my skillset in this space. My final model even placed on the leaderboard 😀 With the competition now over, I’d like to reflect on the experience and what I’ve learned.

#### The Challenge and My Journey
The competition posed four challenges, each designed to reflect common tasks in I/O Psychology:
1. **Predicting Empathy in Workplace Responses**
2. **Generating Interview Responses**
3. **Rating Item Clarity for Personality Tests**
4. **Identifying Fairness Perceptions in Organizational Policies**

Beyond the datasets provided, the main instruction was that the work had to substantially involve LLMs in the prediction process for each task. Ok straightforward enough to understand, but LLMs are exactly that - *large models* - and I only had my personal 2016 MacBook Pro.

To start with, I knew I could access somewhat more compute power than my laptop afforded me by using Google Colab. I could configure my notebook to use resources not available to me physically. Even still, these models are monstrously big and would either rip through the available compute power of the notebook or take a million years to run, or both. Working with these models on your own is not the same as what OpenAI can provide, but I wanted to take a try at creating something I could run for free and without exposing my data to a third party. Although not a requirement for the competition, I wanted to operate as if I was a real company and subject to real privacy concerns.

I found a solution by using a quantized version of the open source model Mistral (the quantized Mixtral model (a mixture of experts), to be exact). Quantization enabled me to run a more computationally light version of the model that still kept the benefits of the model but at a much faster and more affordable level.

#### Surpassing Expectations with LLMs

The journey was not just about solving problems but also about discovering the remarkable capabilities of LLMs in understanding and predicting human behavior and organizational phenomena. To my delight, the accuracy of my solutions surpassed expectations, underscoring the robustness and adaptability of LLMs in handling nuanced psychological data. I passed fairly straightforward instructions taken directly from the directions of the competition (*read:* minimal amount of human effort required), and still the model achieved quite a bit of accuracy. In a real-world setting, taking more times to tailor the prompts or running more iterations would likely be able to enhance the accuracy  substantially.

#### Why People Analytics and I/O Psychology Should Embrace Generative AI

My experiences during the competition solidified my belief that People Analytics professionals and I/O Psychologists are uniquely positioned to leverage Generative AI. As a field, I/Os have spent considerable effort to understand how to measure knowledge. Whether assessing candidates for a job or identifying top performers in our company, we’ve always been concerned with taking a person’s response to a prompt (interview questions, etc) and validating whether those are predictive of actual performance. How much does that differ from measuring the usability of an LLM’s output? Are we concerned with LLMs’ tendency to hallucinate or give erroneous answers? How about the methods we’ve developed to assess reliability. What are BARS if not prompt engineering for people? We know humans can be notoriously unreliable, and we’ve already developed best practices for using the data they generate. Why not apply the same to LLMs?

Related, people data analysts are used to taking messy data or inconsistent data collection processes and wrangling them into workable pipelines.If an LLM wants to respond to the same prompt with the number 1 once and “one” the second time, don’t we already have practice making it all conform? With a gentle combination of process (prompt) improvement on the front end and flexible data ingestion on the backend, I was relatively quickly able to coerce the Mixtral output into a consistent enough form to be usable in a data pipeline.

Our foundational skills in analyzing human behavior and organizational dynamics align well with the capabilities of LLMs, allowing us to extract meaningful insights and foster innovation in our practices and in ways that other fields may not inherently be familiar with.

#### Sharing the Knowledge
In the spirit of collaboration and knowledge-sharing, I have made my code available on GitHub. This repository not only contains the scripts used in the competition but also serves as a resource for those interested in integrating Generative AI into their I/O Psychology workflows.

[Check out my GitHub repository for the competition code](https://github.com/eli-jaffe/SIOP-ML-Competition-2024)

In conclusion, the SIOP 2024 Machine Learning Competition was not just a contest but a learning journey that highlighted the symbiotic relationship between I/O Psychology and Generative AI. As we move forward, embracing these advanced technologies will undoubtedly lead to more innovative, efficient, and effective outcomes in our field.

<font size="1">*This post written using AI - guess how much time it took to produce 😜 Thanks for reading and please reach out to me at eli.jaffe@nyu.edu with any questions.</font>
