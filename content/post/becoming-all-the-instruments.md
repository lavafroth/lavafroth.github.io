---
title: "Becoming All the Instruments"
date: 2026-06-08T19:52:23+05:30
tags:
  - Python
  - Music
  - Instruments
  - librosa
  - MIDI
draft: false
---

I've been working on a tool using very simple math
to convert humming or human whistles into musical MIDI notes.

Here's how the idea morphed into its current form.

First, I tried using Fourier transform over chunks of the audio, which is known
as the STFT. I wanted to get close to straight lines for each humming pattern
or whistle. To isolate these lines, we could chunk the audio by note boundaries.
I wanted to something simple that the user can supply, preferably without using
any neural networks or fancy math.

## Finding Note Boundaries

Human humming and music in general is very rhythmic. Whenever you are going
from one note to another, you can tap or snap your fingers. When I record videos
for YouTube, if there is an outtake, I snap my fingers which shows a large
spike in the spectrogram, telling me where to cut the audio.

I tried snapping my fingers every time I switched a note, but the snapping
would often interfere with the frequencies of the notes I was whistling. The
next idea was to tap a key on the keyboard while I was humming each note: way
more natural because the brain is excellent at these rhythmic patterns. You can
easily sync pressing a key and humming without extra processing.

I recorded the timesteps and chunked up the audio into pieces where there 
would hopefully be just one single straight line representing a note.

## Making It Sound like Notes

Is human humming perfect? No. Human humming can curve near the edges making the note slightly 
slanted. This phenomenon is a little less prominent in whistles.

I tried was quantizing these notes into blocks: single note chunks, like notes
on a piano. For this, I used the Constant Q Transform, or CQT and a lesser-known
sibling called VQT. VQT was lacking so, I stuck with the CQT.

The spectrogram has time as the horizontal axis or each columns and
frequencies as the vertical axis or each rows. Each element represents the
amplitude or energy.

I took the argmax, which 
is the maximum of each row in the audio spectrogram.
This gives us a single column comprising local maximum of each row.

We took the argmax of the column to figure out which frequency was the most energetic.

If the input chunk is very tiny, it might yield false positives.
That's what I struggled to combat in the next few iterations. If you hum 
or whistle too fast, it gives up, and the noise takes over.

To make it work, I used the concept of musical intervals. I found the 
frequency of a baseline note and then calculated the closest standard musical 
note.

## Decreasing the Search Space

I came to learn that musical octaves are structured such that when you go 
to the next octave, you multiply the frequencies of the current octave by 
two. For example, if you are on a C, the next C in the next octave would 
have twice the frequency.

An octave has 12 semitones with frequencies in a 
geometric progression. If going from one C to the next C doubles the 
frequency, going from one C to the next key C-sharp we must break the doubling into 12
steps,

$$
x^{12} = 2
\implies x = 2^{1/12}
$$

We need to go to $2^{1/12}$ times the frequency.

Now we can find specific frequency bins where the 
user can possibly land to sound musically accurate.

This narrows the search space and reduces the probability of noise being introduced.
To implement this, we must first collect a baseline frequency from the 
user's humming or whistling. Once collected, we can multiply that 
frequency by the number we found earlier to extrapolate into one or two octaves 
above, and perhaps half an octave below.

I chose half an octave below 
because lower notes are more crowded, making them difficult to 
distinguish. Higher notes, while increasingly difficult 
to hum or whistle, are spaced out enough that they are very easy to 
distinguish.

## Semitone Snapping

To further perfect the note, we take the resultant frequency $f$, 
divide it by the baseline $b$, and take the logarithm of that base two. 

$$
v = log_2 \left(\frac{f}{b}\right)
$$

Whenever $v$ is a whole number
- The frequency $f$ is some power of 2 times the baseline $b$
- The frequency lies $v$ octaves above the baseline $b$

When $v$ has a fractional part, it represents the semitone numbers 0 through 12 in the squashed range of 0 through 1.

To reconstruct the semitone numbers we multiply the fraction by 12.

Since you cannot press a key that is 1.5 semitones, we round this to the 
nearest integer.

$$
w = \lfloor 12 v \rceil
$$

We essentially snap the resultant frequency to the nearest semitone $w$.

## Where You Can Find It

This was a fun side project and I have made it [open source](https://github.com/lavafroth/hum) on GitHub having barely 200 lines of code.

I made this tool because I want to make music without having to go through the
pain of learning an instrument (I still am, but that's beside the point). Since every instrument is trying to mimic or
extend what a human sings, it felt natural to embrace this technology.

The best takeaway is that this doesn't require any fancy neural networks, and
it is very fast. It can run on a small computer, like a Raspberry Pi, in a
headless server tucked into your closet.

For people who just want to get a melody out of their brain into playable MIDI
notes that they can share, this is a decent tool. That's about it.

