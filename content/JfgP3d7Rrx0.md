---
title: "secret note jfgp3d7rrx0"
date: 2025-10-28T16:09:00+05:30
draft: false
---

There will be an explanation for non-trivial questions.

# Activity 1

## 1

Dijkstra's algorithm guarantees finding the shortest path from a single source to all other vertices under which of the following conditions?

**Answer:** All edge weights must be non-negative.

## 2


Consider an undirected graph with 5 vertices $(V_0, V_1, V_2, V_3, V_4)$. At a certain point 
in Dijkstra's algorithm (starting from $V_0$), the current tentative distances are: 
$dist = \{V_0:0, V_1:5, V_2:3, V_3:8, V_4:10\}$. And the processed set is: $\{V_0:True, 
V_1:False, V_2:False, V_3:False, V_4:False\}$. Assuming the next step is to select an unvisited 
vertex to mark as processed, which vertex will be chosen?

**Answer:** $V_2$

Explanation: Dijkstra will choose the next unprocessed vertex with the least weight.

## 3

Which of the following components is/are essential for a standard implementation of Dijkstra's algorithm?

**Answers:**

- A way to store the tentative shortest distance to each vertex.
- A set to keep track of vertices whose shortest paths have been finalized.
- A mechanism to select the unvisited vertex with the smallest current distance.

## 4

Consider an undirected graph with vertices S, A, B, C, D and edges with weights: S-A (4), S-B (2), A-C (5), B-A (1), B-D (8), C-D (3). If Dijkstra's algorithm starts from vertex 'S', what is the value of dist[D] immediately after vertex 'A' has been marked as processed?

**Answer:** 10

## 5

When Dijkstra's algorithm is examining an edge (u, v) from a newly processed vertex u , and it finds that the path source -> ... -> u -> v offers a shorter route to v than its currently recorded shortest distance ( dist[v] ), what is the direct consequence for dist[v] and v 's status? 

**Answer:**
dist[v] is updated, and v's status remains un-processed, awaiting its turn in a future selection step

## 6

Given a weighted graph where weights of all edges are unique, there is always a unique shortest path from a source to destination in such a graph.

**Answer:** False

Explanation: There can be multiple sequence of edges from vertex $A$ to $B$ representing the shortest path. The only necessary property is that the sum of the weights on these edges is the least.

# Activity 2

## 1

What is a fundamental capability of the Bellman-Ford algorithm that distinguishes it from Dijkstra's algorithm for finding shortest paths?

**Answer:** It is able to correctly find shortest paths in graphs containing negative edge weights.

## 2

For a graph with 7 vertices and 10 edges, if it contains no negative cycles, what is the minimum number of passes over all edges that the Bellman-Ford algorithm needs to perform to guarantee that all shortest path distances are finalized?

**Answer:** 6

## 3

Consider the following directed graph. If the Bellman-Ford algorithm starts from vertex 'S', what are the shortest distances to vertices 'A', 'B', and 'C' (in that order: dist[A] , dist[B] , dist[C] ) after exactly 2 passes over all edges?

**Answer:** 6

Explanation: It takes $n-1$ iterations for a graph with $n$ edges to stabilize via Bellman Ford if there are no negative edges.

If the graph stabilizes further from the $n$ iteration onwards, it contains negative cycles.

## 4

When Bellman-Ford performs a pass over all edges, does the order in which edges are relaxed within that single pass affect the final shortest path distances after all V−1 passes (assuming no negative cycles are present)?

**Answer:** No, the order of edge relaxation within a pass does not affect the final distances after all V−1 passes.

## 5

Which of the following statements accurately describe properties or uses of the Bellman-Ford algorithm?

**Answers:**
- If a negative cycle is detected, the algorithm reports its presence and may not produce valid shortest paths for affected vertices.
- The algorithm is suitable for distributed shortest path computation.

## 6

Given a graph where all edges have positive weights, the shortest path produced by Dijkstra's and Bellman Ford algorithm may be different but path weight would be same.

**Answer:** True

# Activity 3

## 1

What type of shortest path problem is the Floyd-Warshall algorithm designed to solve?

**Answer:** All-pairs shortest paths in graphs with negative edge weights or positive edge weights (but no negative cycles).

## 2

The core update rule in Floyd-Warshall is $$dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])$$

What does the variable k fundamentally represent in this context?

**Answer:** An intermediate vertex that might lie on a shortest path from i to j

## 3

What is the time complexity of the Floyd-Warshall algorithm for a graph with N vertices?

**Answer:** $O(N^3)$

## 4

How does the Floyd-Warshall algorithm detect the presence of a negative weight cycle in the graph?

**Answer:** By observing if any dist[i][i] (distance from a vertex to itself) becomes negative after all iterations

## 5

Consider a graph with 3 vertices {1, 2, 3}. The initial distance matrix dist is given as: dist[1][1] = 0, dist[1][2] = 2, dist[1][3] = 7 dist[2][1] = inf, dist[2][2] = 0, dist[2][3] = 3 dist[3][1] = inf, dist[3][2] = inf, dist[3][3] = 0

What is the value of dist[1][3] after the iteration where k = 2 is considered as the intermediate vertex?

**Answer:** 5

## 6

Consider a graph with 3 vertices {1, 2, 3}. The initial distance matrix dist is set up. dist[1][1]=0, dist[1] [2]=5, dist[1][3]=inf dist[2][1]=inf, dist[2][2]=0, dist[2][3]=2 dist[3][1]=inf, dist[3] [2]=inf, dist[3][3]=0

After all iterations of the Floyd-Warshall algorithm, what will be the value of $dist[3][1]$? 

**Answer:** inf

Explanation: The distance of 3 to 1 is never updated.


# Activity 4


## 1

Prim's algorithm builds the Minimum Spanning Tree (MST) by iteratively adding edges. At each step, which type of edge does it always select?

**Answer:** The edge with the smallest weight that connects a vertex already in the MST to a vertex not yet in the MST

## 2

Consider the following undirected graph. If Prim's algorithm starts from vertex 'A', what is the total weight of the Minimum Spanning Tree (MST) it finds?

Graph: A-B (4), A-C (2), B-C (5), B-D (10), C-D (3), C-E (7), D-E (1)

**Answer:** 10

## 3

A connected, undirected graph has 6 vertices and 7 edges. If Prim's algorithm is used to find its Minimum Spanning Tree, how many edges will be included in the final MST?

**Answer:** 5

## 4

When is the Minimum Spanning Tree (MST) of a connected, weighted graph guaranteed to be unique?

**Answer:** If all edge weights in the graph are distinct.

## 5

Suppose Prim's algorithm has constructed an MST for a graph. If the weight of an edge not currently in the MST is decreased, will the existing MST always change?

**Answer:** Not necessarily; the MST will change only if the decreased edge becomes the new minimum edge across some cut that was previously crossed by a different (heavier) MST edge.

## 6

If Prim's algorithm has generated a Minimum Spanning Tree (MST) for a connected graph, the unique path between any two vertices within that MST is always the shortest path between those two vertices in the original graph

**Answer:** False

# Activity 5

## 1

Which of the following statements about how Kruskal's algorithm constructs the MST are true?

**Answer:** (Yes there is only one I think is correct)
- It adds an edge only if it connects two vertices that belong to different existing components.

## 2

A graph has 5 vertices {V1, V2, V3, V4, V5}. Kruskal's algorithm is applied. Initially, each vertex is in its own set: {V1}, {V2}, {V3}, {V4}, {V5}. Consider the following sequence of edges processed by Kruskal's algorithm:

(V1, V2) - weight 2 
(V3, V4) - weight 3 
(V1, V3) - weight 4 
(V2, V4) - weight 5 
(V5, V2) - weight 6 

How many distinct connected components are there after these 5 edges have been processed and decisions made? 

**Answer:** 1

## 3

If Kruskal's algorithm considers an edge e and decides not to include it in the MST, what is the precise reason for this exclusion?

**Answer:** Adding edge e would connect two vertices that are already in the same connected component within the set of edges already chosen for the MST.

## 4

A graph has 7 vertices and consists of 3 distinct connected components. Kruskal's algorithm is executed on this graph. Assuming all components are non-empty and connected internally, how many edges will Kruskal's algorithm include in the resulting Minimum Spanning Forest (MSF)?

**Answer:** 4

## 5

If Kruskal's algorithm rejects an edge e (meaning e is not included in the MST), it implies that e is the heaviest edge in any cycle that e forms with edges already selected for the MST.

**Answer:** True

## 6

In a connected undirected graph with more than three vertices and all distinct edge weights, the two edges with the smallest weights will always be part of its Minimum Spanning Tree (MST).

**Answer:** True


# GrPAs

## 1

We are implementing Kruskal's algorithm because it's just a tad bit easier than Prim's algorithm.

```python
def FiberLink(wl):
    sum, edges, component = 0, [], {}
    for u, u_edges in wl.items():
        component[u] = u
        for v, d in u_edges:
            edges.append((d, u, v))
    edges.sort()

    for d, u, v in edges:
        if component[v] == component[u]:
            continue
        sum += d
        c = component[u]
        for ckey, cval in component.items():
            if cval == c:
                component[ckey] = component[v]

    return sum
```

## 2

The shorted walk from `src` to `dst` while bouncing off the `bounce` node. We are using Bellman-Ford because simple is good.

We can find the shortest path from `bounce` to each of `src` and `dst` and then add up those two paths (both the path sequence and the weight).

```python
def min_cost_walk(wl, src, dest, bounce):
    dist, parent = {}, {}
    for u in wl.keys():
        dist[u] = 1e6 # close to infinity
    dist[bounce] = 0

    for _ in range(len(wl)):
        for u, edges in wl.items():
            for v, weight in edges:
                if dist[u] + weight < dist[v]:
                    dist[v] = dist[u] + weight
                    parent[v] = u

    path = []
    revpath = []
    distance = dist[src] + dist[dest]
    while src != bounce:
        path.append(src)
        src = parent[src]

    path.append(bounce)
    while dest != bounce:
        revpath.append(dest)
        dest = parent[dest]

    return distance, path + revpath[::-1]
```

## 3

Here again, we are using Bellman-Ford. Remember from the activity question answers that if there are any relaxations in the $n_{th}$ iteration,
there exists a negative cycle in the graph.


```python
def IsNegativeWeightCyclePresent(wl):
    n = len(wl)
    dist = {}
    parent = {}
    for u in wl:
        dist[u] = 1e6
    dist[u] = 0 # the node to start with

    for i in range(n):
        for u, edges in wl.items():
            for v, weight in edges:
                if dist[u] + weight < dist[v]:
                    if i == n - 1:
                        return True
                    dist[v] = dist[u] + weight
                    parent[v] = u

    return False
```

# GA

## 1
At each step of Dijkstra's algorithm, after a vertex has been processed, how does the algorithm determine which unvisited vertex to process next? 

Answer: It picks the unvisited vertex that has the smallest current shortest distance from the source.

## 2

Which of the following statements correctly describes how the Bellman-Ford algorithm detects the presence of a negative cycle reachable from the source? Consider that V is the number of vertices in the graph. 

Answer: If, during a Vth pass over all edges, any distance value can still be improved (i.e., an edge relaxation occurs).

## 3

A graph has 4 vertices (V1, V2, V3, V4) and the following edges:

- V1 → V2 (weight = 2) 
- V2 → V3 (weight = -3) 
- V3 → V1 (weight = 0) 
- V1 → V4 (weight = 5) 

If Bellman-Ford starts from V1, after running the algorithm for all necessary passes, how many vertices will have their shortest distance updated in the final (4-th) pass used for negative cycle detection?

Answer: 3

## 4

Consider any connected graph with 4 vertices and 6 edges, where all edge weights are distinct. In such a graph, the three edges with the smallest weights will always be part of its Minimum Spanning Tree (MST).

Answer: False

## 5

A graph can have a unique Minimum Spanning Tree (MST) only if all its edge weights are distinct

Answer: True

## 6

Suppose we run Prim's algorithm and Kruskal's algorithm on a graph G and these two algorithms 
produce minimum-cost spanning trees $T_P$ and $T_K$, respectively.

(I) $T_P$ may be different from $T_K$ if some pair of edges in G have the same weight.

(II) $T_P$ is always the same as $T_K$ if all edges in G have distinct weights.

Answer: Both (I) and (II) are correct.

## 7

Which one of the following can be the sequence of edges added, in that order, to create a minimum spanning tree using Kruskal’s algorithm?

Answers:

1. (a,b) (d,f) (b,f) (d,c) (d,e)
2. (a,b) (d,f) (d,c) (b,f) (d,e)
3. (d,f) (a,b) (d,c) (b,f) (d,e)
5) (d,f) (a,b) (b,f) (d,c) (d,e)

## 8

Consider the given weighted adjacency matrix $w$ for a complete undirected graph with vertex 
set $\{0, 1, 2, 3, 4\}$. Where $w[i][j]$, $i \neq j$ in the matrix is the weight of the edge 
$(i,j)$.

$$w = \begin{pmatrix}
0 & 1 & 8 & 1 & 4 \\
1 & 0 & 12 & 4 & 9 \\
8 & 12 & 0 & 7 & 3 \\
1 & 4 & 7 & 0 & 2 \\
4 & 9 & 3 & 2 & 0
\end{pmatrix}$$

What is the weight of the minimum spanning tree for the given graph?

Answer: 7

## 9

Which of the following statement(s) is/are true about the spanning tree of a connected graph?

Answers:

- A spanning tree is a connected acyclic graph.
- A spanning tree for an n vertex graph has exactly n-1 edges.
- Adding an edge to a spanning tree must create a cycle.
- In a spanning tree, every pair of nodes is connected by a unique path

## 10

Consider the following weighted adjacency list WList for a directed and connected graph. What will be the path weight of the shortest path from 1 to 3?

```python
WList = {
  #source: [(destination, weight),...]
  1: [(2, 10), (8, 8)],
  2: [(6, 2)],
  3: [(2, 1), (4, 1)],
  4: [(5, 3)],
  5: [(6, -1)],
  6: [(3, -2)],
  7: [(2, -4), (6, -1)],
  8: [(7, 1)]
}
```

Answer: 5

## 11

Consider a complete undirected graph with vertex set {0, 1, 2, 3, 4}. Every entry W[i][j] where i≠j in the matrix W below is the weight of the edge from vertex i to vertex j.

$$w = \begin{pmatrix}
0 & 1 & 8 & 1 & 4 \\
1 & 0 & 12 & 4 & 9 \\
8 & 12 & 0 & 7 & 3 \\
1 & 4 & 7 & 0 & 2 \\
4 & 9 & 3 & 2 & 0
\end{pmatrix}$$

Answer: 4


## 12

In the given graph, if we try to find the shortest path from node a to all other nodes using Dijkstra's algorithm, in what order do the nodes get included in the visited set?

Answer: a e d c b g f h

## 13

Consider the given graph. Which of the following is the correct sequence of edges added to the minimum spanning tree when Prim's algorithm is applied on this graph with 5 as the source vertex?

Answer: [(5,1),(1,2),(2,3),(3,4)]


## 14

In the context of the Floyd-Warshall algorithm, what does it mean if the distance matrix has a negative value in its diagonal?

Answer: The graph has a negative-weight cycle.

## 15

Consider the graph G given. Let 
α denote the number of minimum spanning trees of G and 
β denote the weight of such a minimum spanning tree. The value of 
α+β is 

Answer: 14
