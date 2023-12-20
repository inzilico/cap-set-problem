# Cap Set Problem

The repo represents approaches to find cap set for different  values of n. 

## Descripion

## Data

## Scripts


### Find largest cap

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

### Tradein

```bash

# One point
perl tradein-01.pl -i data/cap-sets-3n-06-02.txt -c data/cards-3n.txt -l 8 -o data/cap-sets-3n-tradein.txt

# Two points
perl tradein-02.pl -i data/cap-sets-3n-06-02.txt -l 8 -c data/cards-3n.txt -o data/cap-sets-3n-tradein-02.txt

```

