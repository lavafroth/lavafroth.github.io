---
title: "for seshu baby mwa mwa"
date: 2025-10-03T16:04:18+05:30
draft: false
---

# AQ2.1
1. \( O(n^2) \)
2. \( O(n\ log\ n) \)
3. \( O(n^3) \)
4. \( O(n + log\ m) \)
5. \( O(log\ n) \)
6. \( O(n^2\ log\ n) \)

# AQ2.2

1. \( O(log\ n) \)
2. 5
3. 3
4. 3
5. 2
6. Multiple options:
   - It works only on sorted arrays.
   - It has a best-case time complexity of O(1).

# AQ2.3

> Selection sort always makes n(n-1)/2 comparisons which is of order \( O(n^2) \)

1. 3
2. 15
3. 45
4. Multiple options:
   - [4, 4, 3, 5, 6]
   - [7, 2, 8, 7, 3]
   - [9, 1, 4, 9, 5]
5. Multiple options:
   - It is an in-place algorithm.
   - It performs \( O(n^2) \) comparisons in the worst case.
6. \( \lceil{n/2}\rceil \) In this case, you narrow the window of comparison on both sides by 1

# AQ2.4

1. 7

Original | Shift
---------|-------
[8, 5, 2, 9, 1] | 4 shifts
[1, 8, 5, 2, 9] | 2 shifts
[1, 2, 8, 5, 9] | 1 shift
[1, 2, 5, 8, 9]

Total 7

2. 6

Original | Shift
---------|-------
[4, 3, 2, 1] | 3 shifts
[1, 4, 3, 2] | 2 shifts
[1, 2, 4, 3] | 1 shift
[1, 2, 3, 4]

Total 6

3. 0
4. 10
5. 10
6. `array[j] > key → array[j] < key`
7. \( O(n) \)

# AQ2.5

> Merging two sorted lists of size \(m\) and \(n\) takes worst case \(m + n - 1\) comparisons

1. 14
2. To combine two sorted sublists into a single sorted list.
3. Multiple options:
   - It is a divide-and-conquer algorithm
   - It requires additional space proportional to the size of the input list.
   - It is stable.
4. 4
5. \(T(n) = 2T(n/2) + n\)
6. 6
7. Merge Sort has the same time complexity \( O(n\ log\ n) \) for best, worst, and average cases.
8. 133
9. 89
10. 275
