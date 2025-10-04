---
title: "for seshu baby mwa mwa"
date: 2025-10-03T16:04:18+05:30
draft: false
---

> Update: I have added the GA 2 sols as well. Please take them with a grain of salt obviously
I am also fallible to mistakes.

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

# GA 2

### 1. What is the time complexity of the function?

```python
def fun(n):
   total = 0
   for i in range(n):
      total += i

   k=0
   for i in range(n):
      for j in range(n):
         k += i * j
         for l in range(5):
            k=1

   for i in range(1000):
      total -= 1
   return total + k
```

The second block with nested loops is the bottleneck, it has two loops, implying \( O(n \times n) = O(n^2) \).
The other loops are linear \( O(n) \) and only this second block will dominate. The answer is the dominating term.

\( O(n^2) \)

---

### 2. What is the time complexity of the function?

```python
def func(n):
   s=0
   if n <= 0:
      return 0
   for i in range(n):
      j= 0
      while j * j <n:
         s += j
         j += 1
   return s
```

The outer loop goes `for` \(n\) times. The inner loop runs as long as the iterator satisfies
$$ j \times j \le n $$
which can be rewritten as
$$ j \le \sqrt n $$

Thus, the number of operations after nesting the two loops is
$$ O(n \sqrt n) $$

---

### 3. Let \(T_{best}(n),T_{avg}(n),T_{worst}(n)\) be the best-case, average-case, and worst-case running times of an algorithm, respectively, executed on an input of size \(n\). Select the correct statements.

Rule of thumb: \(T_{best}(n) \le T_{avg}(n) \le T_{worst}(n)\)

In plain words: When the algorithm gets lucky with an easy input, which is the best case \(T_{best}(n)\), the time it takes is obviously less than the average case \(T_{avg}(n)\).
Similarly, \(T_{avg}(n) \le T_{worst}(n)\).

Now let's see the correct options.

#### \(T_{best}(n) = O(T_{avg}(n))\)

Big O notation means the upper bound. The time taken for the best case is upper bounded by the time taken by the average case.

#### \(T_{worst}(n) = \Omega(T_{avg}(n))\)

\(\Omega\) notation means the lower bound. The time taken for the worst case is lower bounded by the time taken by the average case.

### If \(T_{best}(n) = \Theta(n^2)\) and \(T_{worst}(n) = \Theta(n^2)\), then \(T_{avg}(n) = \Theta(n^2)\)  

If the best and worst cases are tightly bound,
> Remember, \(\Theta\) notation is the sandwich between O and \(\Omega\) bounds

then the average case is also sandwiched in between by the same tight bound.

---

### 4. How many effective swaps are performed by selection sort on `[5, 2, 8, 2, 4]`?

Look, I did this with python because I was feeling lazy, you can do it in your head or on paper as well. Sorri baby, I was tired.

Answer is 3.

---

### 5. Select correct statements about the given insertion sort implementation.

 - The sort is stable and it sorts in-place
 - After m iterations of the for-loop, the first m elements in the list are in sorted order

---

### 6. You are implementing binary search on a sorted array that may contain duplicate values of the target element X . You need to find the index of the last occurrence of X. If an instance of X is found at L[mid], how should the search proceed to find the last possible occurence.

Store mid as a potential answer and continue searching in the right subarray by setting low = mid + 1 .

---

### 7. A school wants to maintain a database of its students. Each student has a unique id and it is stored along with other details. Adding a new student with a unique id, searching for a student using their id, and removal of students are the frequent operations performed on the database. From the options given below, choose the most efficient technique to store the data.

Maintain a sorted list with id. Whenever a new student is added, insert the student details into the respective position in the sorted list by id.

---

### 8. Find the time complexity of the function:

```python
def tsearch(L, x):
   global c
   c += 1
   n = len(L)

   if n==0:
      return False

   if L[n // 3] == x:
      return True

   if L[2 * n // 3] == x:
      return True

   if x < L[n // 3]:
      return tsearch(L[:n // 3], x)
   elif x > L[2 * n // 3]:
      return tsearch(L[2 * n // 3:], x)
   else:
      return tsearch(L[n // 3 : 2 * n// 3], x)
```

This is basically a spin on the binary search algorithm except that instead of dividing the search space into half every time, you are dividing it by 3.

All such divide-and-conquer algorithms take \(O(log\ n)\) time.

---

### 9. Arrange the following functions in increasing order of asymptotic complexity.

$$
\begin{aligned}
f_1(n) = 3n + log(n)\\
f_2(n) = log(n)^2\\
f_3(n) = log(log(n))\\
f_4(n) = 100log(n)\\
f_5(n) = 3n\ log(n)
\end{aligned}
$$

Here, \(f_3(n) = log(log(n))\) grows very very slowly.

between the next \(f_4(n) = 100log(n)\) and \(f_5(n) = 3n\ log(n)\)


$$ f_3(n) < f_4(n) < f_2(n) < f_1(n) < f_5(n) $$

---

### 10. Correct relationship of function growths

$$
f(n) = \Omega(g(n)),\ g(n) = O(h(n))
$$

---

### 11. Recursively check the midpoints for this one.

94, 150, 99

---

### 12. What will be the number of swaps that the following Insertion sort?

insertion sort considers the first chunck of the array to be sorted, finds the smallest element beyond this chunk
and inserts it (or bubbles it up as I like to think of it) into the pre sorted chunk.

Initially, this chunk is of size 1 because 1 element is sorted by definition.

Original: `[38, 28, 43, 22, 112, 33, 39]`

Original | Swaps | Element that bubbled up
---|---|---
[28, 38, 43, 22, 112, 33, 39] | 1 | 38
[22, 28, 38, 43, 112, 33, 39] | 3 | 22
[22, 28, 33, 38, 43, 112, 39] | 3 | 33
[22, 28, 33, 38, 39, 43, 112] | 2 | 39

Total swaps: 9

### 13. Stable sort `[(8, 1), (7, 5), (6, 1), (2, 5), (5, 2), (9, 0)]`  according to the y value of (x, y) pairs.

Stable sort means the order of equally valued objects is not perturbed. If both of us have equal grades in a subject,
and in the score list your name is before mine, it should stay that way after sorting.

`[(9, 0), (8, 1), (6, 1), (5, 2), (7, 5), (2, 5)]`

### 14. Perform two way merge, how many comparisons?
all of the elements of L1 come before L2. This means there will be \(min(len(L1), len(L2))\) comparisons.
$$ min(len(L1), len(L2)) = 3 $$

L3 and L4 have interleaving elements. This is the worst case where the number of comparisons is

$$
\begin{aligned}
m + n - 1\\
= 3 + 3 - 1 = 5
\end{aligned}
$$

For the two new lists, all elements of

`[1,2,3,4,5,6]`

come before elements of

`[7,8,9,10,11,12]`

$$ min(len(L1), len(L2)) = 6 $$

Total = 6 + 5 + 3 = 14

# GRPAs

### 1. String sorting question
This has two parts:
 - Sort with respect to starting letters.
 - Sort with respect to starting letters, then for each block of common letters, sort the trailing numbers in descending order.

Here's the trick to solve the second part, you always sort fields in the reverse order of what they ask for.
So first sort by numbers in descending order, then sort by the starting letters.

Sorri this solution is bit big. You could also use the built in `sorted` function in python without implementing
merge sort like I did here.

```python
def combinationSort(strList):
    by_first_letter = lambda v: ord(v[0])
    by_last_digits = lambda v: int(v[1:])
    sorted_0 = mergesort(strList, by_first_letter)

    sorted_1 = mergesort(strList, by_last_digits, ascending=False)
    sorted_1 = mergesort(sorted_1, by_first_letter)
    return sorted_0, sorted_1


def merge(a, b, by, ascending=True):
    i, j = 0, 0
    m, n = len(a), len(b)
    c = []
    while i + j != m + n:
        if i == m:
            return c + b[j:]
        if j == n:
            return c + a[i:]

        a_ = a[i]
        b_ = b[j]
        # this XOR will flip the comparison
        if ascending ^ (by(a_) > by(b_)):
            i += 1
            c.append(a_)
        else:
            j += 1
            c.append(b_)
    return c


def mergesort(v, by, ascending=True):
    n = len(v)
    if n == 1:
        return v

    l = mergesort(v[: n // 2], by, ascending)
    r = mergesort(v[n // 2 :], by, ascending)
    return merge(l, r, by, ascending)
```

### 2. Given an ascending list is rotated, find the biggest element.

{{< collapsable-explanation >}}

We will do a binary search. to calculate the midpoint, we need to know the start and the end indices.
I call them head and tail respectively.

```python
def findLargest(array):
    head, tail = 0, len(array) - 1
```

If we want the largest element, it will be found in a slice of the array that is sorted in ascending order.
We check that as the loop condition.

```python
    while array[head] > array[tail]:
```

Calculate the midpoint every iteration.

```python
        mid = (head + tail) // 2
```

If the middle element is greater than the last element, it might look like this:

```python
        if array[mid] > array[tail]:
            head = mid
```

![](/midpoint.svg)

Observe that the left half of the midpoint is useless in this case. Therefore, we set the new head to the midpoint.

```python
        else:
            tail = mid - 1
```

The opposite case might look like this:

![](/midpoint-1.svg)

In such a case, the midpoint along with anything to its right is useless. We throw that part away by reassigning tail to mid - 1.

Finally we  return the last (standing) array element.

```python
    return array[tail]
```

```python
def findLargest(array):
    head, tail = 0, len(array) - 1
    while array[head] > array[tail]:
        mid = (head + tail) // 2
        if array[mid] > array[tail]:
            head = mid
        else:
            tail = mid - 1
    return array[tail]
```

{{</ collapsable-explanation >}}

### 3. Perform merge on two lists via swaps only

The swap function works as `list_a.swap(index_a, list_b, index_b)` which is part of their custom implementation.

```python
# treat A and B as a contiguous array basically
# returns which array the current contiguous indexer
# indexes into and at what offset
def index(A, B, x):
    if x < len(A):
        return A, x
    return B, x - len(A)

def swap(A, B, x, y):
    source, source_index = index(A, B, x)
    target, target_index = index(A, B, y)
    source.swap(source_index, target, target_index)

def mergeInPlace(A, B):
    # again, value_at treats A + B as contiguous
    value_at = lambda x: A[x] if x < len(A) else B[x - len(A)]
    
    size = len(A) + len(B)
    for i in range(size-1):
        smallest = value_at(i)
        smol_index = i
        for j in range(i, size):
            if value_at(j) < smallest:
                smol_index = j
                smallest = value_at(j)
        # swap i and smol_index
        swap(A, B, i, smol_index)
```
