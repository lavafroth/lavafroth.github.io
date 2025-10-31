---
title: "note skta4v7n8h8"
date: 2025-10-31T20:24:35+05:30
draft: false
---

# GrPA 1

```python
def swap(arr, i, j):
    arr[i], arr[j] = arr[j], arr[i]


def max_heapify(arr, end, current):
    left = 2 * current + 1
    right = left + 1
    largest = current

    if left < end and arr[left] > arr[largest]:
        largest = left
    if right < end and arr[right] > arr[largest]:
        largest = right

    if largest != current:
        swap(arr, current, largest)
        max_heapify(arr, end, largest)


def mergeKLists(arr):
    arr = [value for subarray in arr for value in subarray]
    n = len(arr)
    for i in reversed(range(n // 2)):
        max_heapify(arr, n, i)

    for i in range(n-1,0,-1):
        swap(arr, 0, i)
        max_heapify(arr, i, 0)
    return arr
```

# GrPA 2


```python
def maxLessThan(root, x):
    floor = None
    while not root.isempty():
        if root.value > x:
            root = root.left
    
        elif root.value <= x:
            floor = root.value
            root = root.right
    return floor
```

# GrPA 3

Note that this `max_heapify` is a workhorse function which you should learn well
because you're gonna use it very frequently to implement a priority queue.

```python
def max_heapify(arr, end, current):
    left = 2 * current + 1
    right = left + 1
    largest = current

    if left < end and arr[left] > arr[largest]:
        largest = left
    if right < end and arr[right] > arr[largest]:
        largest = right

    if largest != current:
        swap(arr, current, largest)
        max_heapify(arr, end, largest)

def min_max(arr):
    n = len(arr)
    for i in reversed(range(n // 2)):
        max_heapify(arr, n, i)
```
