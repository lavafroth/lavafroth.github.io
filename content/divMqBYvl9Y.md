---
title: "w8"
date: 2025-10-03T16:04:18+05:30
draft: false
---

## GRPA 1

```python
def findOccOf(arr, x):
    lo = 0
    hi = len(arr) - 1

    loval = None
    while lo <= hi:
        mid = (lo + hi) // 2
        c = arr[mid]
        if x < c:
            hi = mid - 1
        elif x > c:
            lo = mid + 1
        elif x == c:
            loval = loval or mid
            loval = min(loval, mid)
            hi = mid - 1

    lo = 0
    hi = len(arr) - 1
    hival = None
    while lo <= hi:
        mid = (lo + hi) // 2
        c = arr[mid]
        if x < c:
            hi = mid - 1
        elif x > c:
            lo = mid + 1
        elif x == c:
            hival = hival or mid
            hival = max(hival, mid)
            lo = mid + 1


    return loval, hival
```

## GRPA 2

```python
def merge_inversion(left, right):
    merged = []
    count = 0

    i, j = 0, 0

    m = len(left)
    n = len(right)
    while i + j < m + n:
        if j == n or (i != m and left[i] < right[j]):
            merged.append(left[i])
            i += 1
            continue

        merged.append(right[j])
        j += 1
        count += m - i

    return merged, count


def sort_and_count(arr):
    n = len(arr)
    if n == 1:
        return arr, 0
    left = arr[: n // 2]
    right = arr[n // 2 :]

    left, count_left = sort_and_count(left)
    right, count_right = sort_and_count(right)
    merged, count_both = merge_inversion(left, right)

    return (merged, count_left + count_right + count_both)

def countIntersection(a, b):
    tuples = sorted(zip(a, b))
    b = [t[1] for t in tuples]
    return sort_and_count(b)[1]
```

## GRPA 3

```python
dist = lambda a, b: ((a[0]-b[0])**2 + (a[1]-b[1])**2)**.5

def closest_pair(Px, Py):
    n = len(Px)
    if n <= 3:
        min_d = float('inf')
        for i in range(n):
            for j in range(i + 1, n):
                min_d = min(min_d, dist(Px[i], Px[j]))
        return min_d

    mid = n // 2
    Qx = Px[:mid]
    Rx = Px[mid:]
    mid_point = Qx[-1][0]

    Qy = []
    Ry = []
    for p in Py:
        if p[0] <= mid_point:
            Qy.append(p)
        else:
            Ry.append(p)

    min_d = min(closest_pair(Qx, Qy), closest_pair(Rx, Ry))

    Sy = [p for p in Py if mid_point - min_d <= p[0] <= mid_point + min_d]
    for i in range(len(Sy)):
        for j in range(i + 1, len(Sy)):
            if Sy[j][1] - Sy[i][1] >= min_d:
                break
            min_d = min(min_d, dist(Sy[i], Sy[j]))

    return min_d


def minDistance(points):
    Px = sorted(points, key=lambda p: p[0])
    Py = sorted(points, key=lambda p: p[1])
    return round(closest_pair(Px, Py), 2)
```

## GRPA 4

```python
def mid(a):
    if len(a) <= 7:
        return sorted(a)[len(a)//2]
        
    m = []
    for i in range(0,len(a), 7):
        m.append(mid(a[i:i+7]))
    
    return mid(m)

def MoM7Pos(arr):
    m = mid(arr)
    pos = 0
    for x in arr:
        if x < m:
            pos += 1
    return pos
```
