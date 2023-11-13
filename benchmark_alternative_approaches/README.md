# Benchmark alternative approaches

## Goals

Benchmark current celltype classification approaches and try different ideas. 

&nbsp;  
------------------- Meeting Notes ---------------------
&nbsp;


### 11/13/2023

Ao, Leon - conduct benchmark to combination of input types, models and data.

[Data available]

1. T & Monocytes mixture from MMoCHi paper Figure 2 (cells were sorted with ground truth labels)
2. COVID-Flu and Acute-covid, manually annotated cell labels as ground truth

[Model structure]

1. Hierarchical classifier as in MMoCHi
2. RF classifier FLAT

[INPUT type]

1. CITE-seq normalized expr values (DSB etc.)
2. CITE-seq ranked expr values 
3. Label transfer "confidence.score" 
4. Coupled "confidence.score" & expr values as concatenate input (??positional encoding in NN)
5. Cluster of cells as input (distribution of expr values) 
	+ cluster stability
	+ which resolution

