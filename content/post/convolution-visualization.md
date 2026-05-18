---
title: "A Visual Tour of a Convolution"
date: 2026-05-16T07:19:40+05:30
draft: false
tags:
- WebGL
- Neural Networks
- CNN
- Convolution
---


Please enable JavaScript to enjoy this demo.

{{< rawhtml "content/webapps/convolution-visualization/index.html" >}}

## Following Along

### The Source Image

The gray set of pixels is the image that undergoes convolution. This could be one or more channels of the image: red, green, or blue.
In our example, we have an image with random noise, with the opacity representing the intensity of each pixel.

We will represent the intensity of each pixel as a number between 0 and 1 including the two endpoints.

### The Kernel 

This is a smaller grid of pixels, here represented in blue. It slides (or strides) over the entire source image and results in a single
pixel that represents how similar the patch of the image right below is to the kernel.

We use the same numeric range to represent the pixel intensities.

### The Output Feature Map

This green grid of pixels results from sliding the kernel every step and performing the convolution operation.

### Dot Products

#### Element-Wise Multiplication

When the gray source pixels and the blue kernel pixels blend together into a teal pixel, it is the product of the two values.

A concrete example: suppose the source pixel value is 0.65 and the kernel pixel value at that point is 0.88, the resultant teal
pixel would have a value 0.65 times 0.88 = 0.572.

We repeat this process for all the pixels in the kernel and the respective patch of the source image underneath.

#### Summation

After all the element-wise products have been computed, the teal pixels get summed into a single green pixel in the output feature map layer.

Note that this value need not lie in the range of 0 through 1.

A concrete example: Suppose we have a teal grid 2x2 of element-wise products

$$
\begin{bmatrix}
0.53 & 0.11 \\
0.99 & 0.76
\end{bmatrix}
$$

Summing them up yields 2.4 which does not lie within the 0 through 1 range. Hence, this visualization shows the *relative intensities*
of the resulting feature map.


### In Full Swing

This dot product operation is repeated over and over as the kernel strides across the source image, generating the complete output feature map.

You can play around with the grid size, the kernel size and the stride, which is by how many pixels the kernel slides each iteration. The padding slider allows you to add 0 valued pixels surrounding the image.

