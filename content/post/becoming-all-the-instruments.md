---
title: "Becoming All the Instruments"
date: 2026-06-08T19:52:23+05:30
tags:
  - Python
  - Music
  - Instruments
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

Is human humming perfect? No. Is it going to get something wrong? 
Absolutely. Human humming can curve upwards or downwards while you are 
humming or whistling. For both humming and whistling, the note is slightly 
slanted.

The next thing I tried was quantizing these notes into 
blocks, single note chunks, like notes on a piano or a keyboard. To do 
that, I used the Constant Q Transform, or CQT. It also 
has a lesser-known sibling called VQT, but I tried it, and it was lacking.

So, I stuck with the CQT. I took the argmax, which 
is the maximum of each row in the audio spectrogram, to figure out the 
local maximum of each row. Then, I took the argmax of those in a single 
column to figure out which column was the most energetic.

Will this give us false positives? Yes. If the input chunk is very tiny, 
that's what I struggled to combat in the next few iterations. If you hum 
or whistle too fast, it gives up, and the noise takes over.

To make it work, I used the concept of musical intervals. I found the 
frequency of the note and then calculated the closest standard musical 
note.

## Decreasing the Search Space

I came to learn that musical octaves are structured such that when you go 
to the next octave, you multiply the frequencies of the current octave by 
two. For example, if you are on a C, the next C in the next octave would 
have twice the frequency. An octave has 12 keys, and these keys are in a 
geometric progression. If going from one C to the next C doubles the 
frequency, going from one C to the next key C-sharp must be 
$2^{1/12}$. Raising this number to the power of 12 gives you two, 
which is how much the frequency increases every octave.

Armed with this knowledge, you can find specific frequency bins where the 
user can land to sound musically accurate. This narrows the search space 
and reduces the probability of noise being introduced. If we have noise in 
some of the bands, it doesn't affect us because we are using discrete 
bands instead of something continuous like the entirety of the spectrum.

To implement this, we must first collect a baseline frequency from the 
user's humming or whistling. Once that's collected, we can multiply that 
frequency by the correct number to extrapolate into one or two octaves 
above, and perhaps half an octave below. I chose half an octave below 
because lower notes are more crowded, making them difficult to 
distinguish. Higher notes, on the other hand, while increasingly difficult 
to sing or whistle, are spaced out enough that they are very easy to 
distinguish.

## Semitone Snapping

Lastly, to further perfect the note, we take the resultant frequency, 
divide it by the baseline, and take the logarithm of that base two. 
Remember, going from one octave to another is multiplying by two. We then 
multiply that logarithm by twelve, which gives us a number between zero 
and twelve, a number that corresponds to a key on the piano within an 
octave. Since you cannot press a key that is 1.5, we round this to the 
nearest integer. Essentially, we take the resultant frequency and snap it 
to the nearest note in the octave. That is what my program does.

It is [open source](https://github.com/lavafroth/hum) on GitHub and is barely 200 lines of code. It was a fun 
side project. I wanted to make this because I want to make music, but I 
don't want to go through the pain of learning an instrument. Human humming 
or singing is the root of everything else; every other instrument is 
trying to mimic or extend what a human sings. It is natural to embrace 
this technology. The best takeaway is that this doesn't require any fancy 
neural networks, and it is very fast. It can run on a small computer, like 
a Raspberry Pi, in a headless server tucked into your cupboard or closet. 
It is highly efficient. For people who just want to get a melody out of 
their brain, to turn their thoughts into playable MIDI notes that they can 
share, this is a decent tool. That's about it.

