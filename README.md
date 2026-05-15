This repo holds the code for inferring cultural regions from Jodel social media data. 

It accompanies the paper "Delineating Cultural Regions in Germany Using Geostatistical Lexical Analysis of Social Media Data".

As sociolinguistic research has been incorporating a range of more advanced methods borrowed from other fields in recent years, e.g., geostatistical approaches in computational sociolinguistics, it is also the case that the methods, findings, and theories that are developed in sociolinguistics are increasingly becoming applicable in other fields of social and computational sciences. One example of this type of applied sociolinguistic research is cultural geography, where recent research has used methods developed in dialectology to identify cultural regions. Notably, this research can inform our understanding of regional dialect variation, given long-standing claims that dialect regions reflect cultural regions, and long-standing debates on whether dialect regions reflect historical cultural regions (i.e., those established through first settlement) or whether dialect regions change over time as cultural regions shift with further migration and social change.
A recent study by Louf et al. (2023) used corpus methods to find cultural regions in the US through mapping lexical variation based on geolocated social media data. Drawing on methods developed in dialectology (Grieve, 2016), they used principal component analysis to identify regions where similar topics tend to be discussed based on the relative frequencies of words across counties of the US in order to then map cultural regions. They find that the cultural regions, defined by differences in topics of discussion, show a North/South and East/West split, with non-contiguous divisions. Although they looked for cultural, not dialect, regions, they found that these cultural regions align with modern dialect regions (Grieve, 2016).
This paper extends Louf et al.’s methodology to Germany. We work with a corpus of 21 million geolocated social media posts from the platform Jodel (Hovy & Purschke, 2018; Purschke & Hovy, 2019), a social media app structurally similar to Twitter. Employing the same methodology, we work with the 2000 most frequent words in the corpus. We first calculate Getis-Ord’s z-scores (Ord & Getis, 1995) for all locations and words, which reduces noise and smooths the regional patterns, so that the underlying regional signal can be derived (Louf et al., 2023). We then infer the cultural regions by entering this matrix into a principal component analysis.
We find that the first dimension shows a North/South split within Germany, highlighting the cultural differences between North, Middle and South Germany. While the second dimension highlights a North-East/South-West divide, dimension three shows clear cultural distinctions for Bavaria, Baden-Wuerttemberg and the Ruhr region. In addition to mapping these cultural regions in Germany, we compare to traditional German dialect regions and find that modern cultural regions generally align with dialect regions as proposed, for example, by Lameli (2013).
This study therefore not only advances research on inferring cultural regions by applied sociolinguistic analysis, replicating research originally conducted for American English and proposing modern German cultural regions, but it helps us better understand the societal drivers and regional dialect variation. Ultimately, this study highlights the complex ways in which the structure of human language reflects the structure of human society.



References

Grieve, J. (2016). Regional Variation in Written American English. Cambridge University Press. https://doi.org/10.1017/CBO9781139506137

Hovy, D., & Purschke, C. (2018). Capturing Regional Variation with Distributed Place Representations and Geographic Retrofitting. Proceedings of the 2018 Conference on Empirical Methods in Natural Language Processing, 4383–4394. https://doi.org/10.18653/v1/D18-1469

Lameli, A. (2013). Strukturen im Sprachraum: Analysen zur arealtypologischen Komplexität der Dialekte in Deutschland. De Gruyter.

Louf, T., Gonçalves, B., Ramasco, J. J., Sánchez, D., & Grieve, J. (2023). American cultural regions mapped through the lexical analysis of social media. Humanities and Social Sciences Communications, 10(1), 133. https://doi.org/10.1057/s41599-023-01611-3

Ord, J. K., & Getis, A. (1995). Local Spatial Autocorrelation Statistics: Distributional Issues and an Application. Geographical Analysis, 27(4), 286–306. https://doi.org/10.1111/j.1538-4632.1995.tb00912.x

Purschke, C., & Hovy, D. (2019). Lörres, Möppes, and the Swiss. (Re)Discovering regional patterns in anonymous social media data. Journal of Linguistic Geography, 7(2), 113–134. https://doi.org/10.1017/jlg.2019.10
