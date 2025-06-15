---
title: "Need a hand?"
date: 2025-04-03T15:56:04+05:30
draft: false
tags:
- LLM
- AI
- Rant
- Copilot
---

## The tides

Over the past few months, a sizable fraction of my developer peers have taken to
AI tools. Beckoned from under a rock by the light of day, I was taken aback by this rising wave of *vibe coding*.

They claim AI tools to be phenomenal for frontend technologies like
React and NextJS. The selling point? Context aware autocompletes and agent mode.

Context aware autocompletes happen when the model watches your code so it can
suggest autocompletes while you code.

Agent mode involves an *"autonomous agent"* based on a prompt that can
manipulate files, run commands and essentially carve out a project.

## Impressionable

When I ask my friends about how LLMs improve their code, it is
often simple, easy to spot errors that would have been obvious by reading the documentation.
Thus, the LLMs really provide us an artificial sense of competence.

Here's what my friend @noobscience had to say:

> The place where it helps me the most is simple errors.
Like, let's say I forgot to await a promise, it pretty much finds that out.

A good first question is "what is the scope of a Copilot?"

Is the purpose simply to write boilerplate code and small fixes?

Most reasonable developers would not want to surrender the steering wheel
completely to the LLM because of their unpredictability. Good luck
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
tested tooling instead of big blobs that take three nukes' worth of energy to
train and 4 GPUs to run.

---

Update: 2025-06-15

## Thicc macros

After pondering on the status quo for a couple days, I have come to consider
AI code as thick, probabilistic macros. Their drawbacks surface when they eventually
output poor quality code.

I do like the idea of having comments that describe the steps to a problem and having
code generated for it, by a human or otherwise. I tried to distill the idea of such code
retrieval and after putting a lot of thought into its architecture, I'm happy to announce Silos.

## Silos

Silos is a simple server that runs a small embedding model to embed queries, find the top \(k\) matches and respond with the output in JSON. You can give it a try [here](https://github.com/lavafroth/silos).

Here's how it differs from LLMs
- Snippets are the building blocks: Silos ingests and stores snippets, each with an associated description and language.
- Absence of context: You are on your own, snippet queried must be small and as self-contained as possible.  While it allows placeholders for variables, it does not hyperspecialize the code for your codebase.
- Runs on ancient hardware: Silos v1 uses all-MiniLM for embedding queries, it's a fairly small model with a memory footprint of 50MiB.
- Local first: One can easily setup Silos on local machines for offline work. I do plan to host a central repository and API for community snippets.
- Code, your way: Don't like the code style of the existing snippets? Feel free to add your own! You can add custom snippets using the REST API ephemerally or add them to the snippets directory for persistent use.

### Fun fact

Before public development, the project was named SnippetHub. Considering all the other [*hubs*](@ "By that I mean DockerHub, FlakeHub, etc. Get your mind out of the gutter.") around, I switched it up to be Silos because the snippets are in self-contained silos.
