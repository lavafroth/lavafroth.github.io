---
title: "Do you really need a copilot?"
date: 2025-04-03T15:56:04+05:30
draft: false
tags:
- LLM
- AI
- Rant
- Copilot
---

## Idiots set trends in motion

Over the past few months, a sizable fraction of my developer peers have taken to
AI tools in their programming workflows. When I was beckoned from under a rock
by the light of day, I was taken aback by this rising wave of *vibe coding*.

Some of my peers claim AI tools to be phenomenal for frontend technologies like
React and NextJS. The selling point? Context aware autocompletes and agent mode.

Context aware autocompletes happen when the model watches your code so it can
suggest autocompletes while you code.

Agent mode involves an *"autonomous agent"* based on a prompt that can
manipulate files, run commands and essentially carve out a project.

This unfortunately has become the hot new thing that is vibe coding.

## The contradicting self

Surprisingly, when I ask my friends about how LLMs improve their code, it is
often simple errors that one would have known had they read the documentation
for once. This is what LLMs really provide us, an artificial sense of
competence.

Here's what my friend @noobscience had to say:

> The place where it helps me the most is simple errors.
Like, let's say I forgot to await a promise, it pretty much finds that out.

A good first question is "what is the scope of a Copilot?"

Is the purpose simply to write boilerplate code and provide fixes for stupid
mistakes?

Most reasonable developers would not want to surrender the steering wheel
completely to the LLM because of the unpredictable nature of LLMs. Good luck
trying to fix bugs with little to no clue about how your own code works.

## A cheap knock-off

A deeper question concerns the tooling used during development.

When most people admit that they use LLMs to catch small mistakes and fix them
predictably, what they actually mean is that these models serve as cheap, less
predictable knock-offs of more robust, deterministic and less resource hungry
language tooling.

Developers needing LLMs assistance is a symptom of the compiler or language
tooling being subpar. That they are not good enough to catch low hanging errors.

In fact, quite a few languages provide fantastic tooling and make programming
feel incredibly pleasant. Some good examples include `gopls` for the Go
programming language and `rust-analyzer` for Rust.

To conclude, I think what developers really want are crude, simple yet battle
tested language tooling written by humans. We don't want big blobs that take
three nukes' worth of energy to train and yet require GPUs to run locally.
