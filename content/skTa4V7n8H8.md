---
title: "note skta4v7n8h8"
date: 2025-10-31T20:24:35+05:30
draft: false
---

# GrPA 1

```python
from typing import List

def constructWord(s: str, chunks: List[str]) -> List[List[str]]:
    memo = {}

    def solve(remaining_suffix: str) -> List[List[str]]:
        if not remaining_suffix:
            return [[]]
        
        if remaining_suffix in memo:
            return memo[remaining_suffix]

        possible_combos = []

        for chunk in chunks:
            if not remaining_suffix.startswith(chunk):
                continue

            leftover_results = solve(remaining_suffix[len(chunk):])
            if not leftover_results:
                continue

            for rest in leftover_results:
                possible_combos.append([chunk] + rest)

        memo[remaining_suffix] = possible_combos
        return possible_combos

    return solve(s)
```

# GrPA 2


```python
import numpy as np
def MaxCoinPath(M, x1, y1, x2, y2):
    M = np.array(M, dtype=int)[x1:x2+1, y1:y2+1]
    cost = np.zeros((M.shape[0]+1, M.shape[1]+1), dtype=int)
    
    for i in range(M.shape[0]-1, -1, -1):
        for j in range(M.shape[1]-1, -1, -1):
            cost[i, j] = max(M[i, j] + cost[i+1, j], M[i, j] + cost[i, j+1])
    return cost[0,0]
```

# GrPA 3

```python
def LDS(arr):
    n = len(arr)
    if n == 0:
        return []

    memo = [1] * n
    parent = [-1] * n
    max_len = 0
    end_index = -1

    for i in range(n):
        for j in range(i):
            if arr[i] < arr[j] and memo[i] < memo[j] + 1:
                memo[i] = memo[j] + 1
                parent[i] = j

        if memo[i] > max_len:
            max_len = memo[i]
            end_index = i

    subsequence = []
    current_index = end_index
    while current_index != -1:
        subsequence.append(arr[current_index])
        current_index = parent[current_index]
    return subsequence[::-1]
```
