---
title: "Grug-rephrase to Comprehend"
date: 2026-08-18T07:17:18+05:30
draft: false
tags:
- Workflow
- Study
---

One of the core problems of memory and recall is making ideas stick in the long run.
I have been a huge proponent of Anki flashcards for pure memorization. However, some
ideas are better suited for on-the-fly derivation from a few axioms. These ideas may
originate from research papers or blog posts that we read.

Research papers have notoriously been a source of slop, way before the advent of LLMs.
After looking up unfamiliar terms and performing a more or less linear scan
of the document, I find taking cliff notes in grug speak incredibly helpful.

Here's an example with the abstract of [Wang et al. Under the Shadow of Babel: How Language Shapes Reasoning in LLMs](https://aclanthology.org/2025.findings-emnlp.1321.pdf) in grug speak:

---

Language communicate, dictate reasoning. Maybe LLMs also internalize logic structure.
Paper introduce BICAUSE: structured bilingual dataset for causal reasoning.
Has semantically aligned samples. Chinese, English. Causal forms: Forward, reversed.
Findings on LLMs:
  - Language specific attention patterns.
  - Chinese: focus on causes and sentence-initial connectives.
  - English: balanced distribution.
  - Chinese: word order preference learned. Apply to atypical inputs. Bad performance.
  - When reasoning success, both language representations semantically aligned.
  - Internalize language reasoning beyond mimicry.

Model internals structural analysis. Empirical verify.

---

It's not perfect grug speak but cuts a lot of the fluff from the original paper.
I often save these as text files next to the papers themselves.

When revisiting a paper, I read the grug speak text first and only reference the
original paper for equations and further details.

I hypothesize that the constraint to compress the text without semantic loss
forces deep comprehension.
