# Cap Set Problem

The repo represents approaches to solve this task. 

## Descripion

## Data

## Scripts


The best performance was demonstrated by the following scripts:

```bash
# n = 3
time perl find-cap-sets-06.pl --cards data/cards-3n.txt --out data/cap-sets-3n-06.txt # 0m0.987s
time perl find-cap-sets-06-02.pl --cards data/cards-3n.txt --out data/cap-sets-3n-06-02.txt # 0m0.312s 
```

`find-cap-sets-06-02.pl` differs from `find-cap-sets-06.pl` by utilizing parallel computation based on MCE::Flow.


```bash
# Find cap sets for n = 3 
perl find-cap-sets-04.pl data/3card-comb-3n.txt data/cards-3n.txt data/cap-sets-3n-04.txt

# Get the distribution of lenght of cap sets
perl count-caps.pl data/cap-sets-3n-04.txt

```



