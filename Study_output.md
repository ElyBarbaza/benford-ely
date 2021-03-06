-   [Introduction](#introduction)
-   [Littérature](#littérature)
-   [Statistique descriptive](#statistique-descriptive)
-   [Méthodes](#méthodes)
-   [Tests & Résultats](#tests-résultats)
-   [Discussions et Conclusion](#discussions-et-conclusion)
-   [Annexe](#annexe)

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──

    ## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
    ## ✓ tibble  3.1.3     ✓ dplyr   1.0.7
    ## ✓ tidyr   1.1.3     ✓ stringr 1.4.0
    ## ✓ readr   1.4.0     ✓ forcats 0.5.1

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    ## 
    ## Attaching package: 'data.table'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     between, first, last

    ## The following object is masked from 'package:purrr':
    ## 
    ##     transpose

Introduction
============

Pour de nombreuses séries de nombres de la vie réelle, les fréquences d'apparition des chiffres significatifs (CS) de celle-ci suivent une loi particulière, la loi de Benford (LB). Celle-ci a été découverte par ce dernier au cours du siècle dernier et son intérêt aujourd'hui ne fait que croitre.

Voici sa formule pour le premier CS : $\\ P(D=d)= \\log(1+ \\frac{1}{d})$ (d allant de 1 à 9)

Les chiffres d'élections ne dérogent pas à cette règle et de nombreuses études corroborent cela. (e.g \[1\]) En effet, une non-adéquation à la loi de Benford des résultats de votes peuvent suggérer une fraude ou manipulation potentielle de celle-ci.

La dernière élection américaine aux présidentielles fut secouée par les accusations de fraudes de Donald Trump, un candidat en lice.

Ces accusations concernaient plusieurs allégations :

-   une montée soudaine et sans explications des voix de l'opposition (Biden)
-   un retournement de vote de Trump en faveur de Biden
-   plus de votes enregistrés que d'électeurs inscrits
-   les machines à voter sont la propriété des Démocrates (Biden) et ces derniers en auraient profité
-   des milliers de personnes mortes ont votés

D'après ces accusations, les données auraient donc été manipulées en faveur de Biden et/ou en défaveur de Trump. Si cela se confirme, un pattern suspicieux devrait se retrouver sur les votes de Biden et/ou Trump.

L'objectif de cette étude sera de vérifier (en parallèle) la conformité à la loi de Benford des données d'élections des deux principaux candidats. Une première description des données sera effectuée pour obtenir une vue d'ensemble. Ensuite, les statistiques les plus courantes seront réalisées concernant les votes des deux candidats.

Avec deux hypothèses principales : Est-ce que le jeu de données est conforme à la loi de Benford? À quelle distance se trouve le jeu de données comparé à loi de Benford?

Après avoir analysé les résultats, une discussion et une conclusion concernant la validité des méthodes utilisées seront effectuées.

Le jeu de données sur lequel se basera l'étude vient du site internet ["MIT Election Data Science Lab"](https://electionlab.mit.edu/data). Ce fichier contient les données d'élections présidentielles des États-unis de 1976 à 2020 par comté.

Voici l'en tête du jeu de données complet (72,617 observations et 12 variables) :

    ## # A tibble: 72,617 × 12
    ##     year state   state_po county_name county_fips office    candidate    party  
    ##    <int> <chr>   <chr>    <chr>             <int> <chr>     <chr>        <chr>  
    ##  1  2000 ALABAMA AL       AUTAUGA            1001 PRESIDENT AL GORE      DEMOCR…
    ##  2  2000 ALABAMA AL       AUTAUGA            1001 PRESIDENT GEORGE W. B… REPUBL…
    ##  3  2000 ALABAMA AL       AUTAUGA            1001 PRESIDENT RALPH NADER  GREEN  
    ##  4  2000 ALABAMA AL       AUTAUGA            1001 PRESIDENT OTHER        OTHER  
    ##  5  2000 ALABAMA AL       BALDWIN            1003 PRESIDENT AL GORE      DEMOCR…
    ##  6  2000 ALABAMA AL       BALDWIN            1003 PRESIDENT GEORGE W. B… REPUBL…
    ##  7  2000 ALABAMA AL       BALDWIN            1003 PRESIDENT RALPH NADER  GREEN  
    ##  8  2000 ALABAMA AL       BALDWIN            1003 PRESIDENT OTHER        OTHER  
    ##  9  2000 ALABAMA AL       BARBOUR            1005 PRESIDENT AL GORE      DEMOCR…
    ## 10  2000 ALABAMA AL       BARBOUR            1005 PRESIDENT GEORGE W. B… REPUBL…
    ## # … with 72,607 more rows, and 4 more variables: candidatevotes <int>,
    ## #   totalvotes <int>, version <int>, mode <chr>

Littérature
===========

La première étape de ce type d'étude est de vérifier si le type de donnée (ici d'élections), suit en général la loi de Benford. Cela s’il n'y a pas d'irrégularités bien entendu.

Les critères principaux permettant à un jeu de données d'avoir un comportement benfordien sont :

-   L'hétérogénéité de la génération des nombres.
-   L'étendue de l'ordre de grandeur des nombres.
-   L'asymétrie des données de l'histogramme penchant majoritairement vers la gauche avec une queue proéminente tombant vers la droite (figure 1).

![](Study_output_files/figure-markdown_github/unnamed-chunk-3-1.png)

La combinaison de ces facteurs n'est pas une garantie de comportement benfordien, mais c'est une forte indication que cela puisse être le cas.

Hill \[2\] stipule cela : "La loi de Benford tient asymptotiquement si les nombres sont générés comme des mélanges non biaisés de différentes populations et que plus le mélange est important, meilleure est la population." Pericchi & Torres \[3\], ajoutent ceci : "Les modèles de populations de vote réalistes ne devraient pas être homogènes sur chaque unité électorale mais devraient être des mélanges de différentes populations.”

L'hétérogénéité du nombre et des types d'habitants des comtés américains remplit ce critère.

Un autre caractère associé est que plus il y a différents ordres de grandeur entre les nombres, plus la donnée analysée se conforme à la LB. Les données d'élections suivent ce modèle en général s’il n'y a pas de limite de votes par urne. Cela est le cas de la procédure d'élections aux États-Unis.

C'est ainsi que le jeu de données choisi pour l'analyse contient les votes des candidats par comté et non par Etat, cela afin d'avoir un plus grand ordre de grandeur et dans le même temps obtenir un plus grand nombre d'observations.

Pour plus de simplicité (notamment pour l'analyse du premier-deuxième chiffre significatif), les nombres inférieurs à 10 ont été supprimés. Il est assez évident que cela ne remet nullement en cause la pertinence de l'analyse étant donnée la provenance des nombres (données d'élections états-uniennes).

Voici l'en-tête des deux jeux de données qui seront étudiés (Trump et Biden respectivement), n étant le nombre de votes :

Voici les comtés non inclus dans l'analyse :

    ## # A tibble: 2 × 3
    ##   county_name county_fips     n
    ##   <chr>             <int> <int>
    ## 1 KING              48269   151
    ## 2 LOVING            48301    60

Il y a donc 3153 nombre d'observations totales. Les votes de Trump s'étendent sur l'intervalle \[59;1145530\]. Les votes de Biden s'étendent sur l'intervalle \[16;3028885\].

Les votes des deux candidats s'étendent sur 4 et 5 ordres de grandeurs respectivement. (Formule OG: log10(max/min)). Les votes des deux candidats s'étendent sur 2.7 et 3.7 ordres de grandeurs robuste respectivement. (Formule OGR : log10(percentile99/percentile1)).

La valeur d'ordre de grandeur robuste (OGR) recommandée pour atteindre la conformité à la LB est d'environ 3. Ce qui est atteint par l'étendue de votes de Biden et quasiment atteint par celui de Trump (&gt; 2.5). Nous considérons ici que ce critère est atteint.

Voici ci-dessous l'histogramme des votes de Trump et Biden. Pour une meilleure inteprétation visuelle, seules les données comprises dans l'intervalle des percentiles \[5% , 95%\] sont prises en compte.

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](Study_output_files/figure-markdown_github/unnamed-chunk-6-1.png)

On remarque que les deux histogrammes ont une asymétrie avec un penchant extrême vers la gauche. Cette asymétrie est plus forte que la loi de Benford. Cela est dû à la présence de comtés ayant une population bien supérieure à la moyenne nationale.

Statistique descriptive
=======================

Voici l'histogramme des votes du premier chiffre significatif de Trump et Biden. La figure est accompagnée d'une ligne représentant un jeu de données ayant le même nombre d'observations mais avec les fréquences exactes de la loi de Benford.

![](Study_output_files/figure-markdown_github/unnamed-chunk-7-1.png)

A première vue les deux graphiques semblent globalement suivre le pattern de la loi de Benford. On aperçoit cependant de légers écarts. Sur le graphique de Trump, les chiffres 2 et 9 sont un peu en dessous des valeurs attendues. Les chiffres 5,6 et 8 quant à eux sont très légérement au dessus.

Sur le graphique de Biden, les écarts sont plus forts que ceux de Trump mais ceux-ci restent assez légers. Notamment avec le chiffre 4 qui est au-dessus de la variable attendue. Les chiffres 5,7 et 9 eux sont faiblement en dessous. L'analyse visuelle du premier chiffre significatif ici ne montre pas une non-conformité à la LB. Cependant, cette analyse ne démontre en rien la conformité à la LB.

Nous passons maintenant à la visualisation du premier-deuxième chiffre significatif. Il est d'ailleurs suffisant d'uniquement analyser le premier-deuxième chiffre significative, celui-ci contenant l'information des deux premiers chiffres significatifs :

![](Study_output_files/figure-markdown_github/unnamed-chunk-8-1.png)

Ici encore, globalement on retrouve le pattern d'asymétrie à gauche de la loi de Benford. Cependant on remarque la présence de nombreux chiffres qui sont au-dessus ou en dessous de leur valeur attendue.

Sur le graphique de Trump, une dizaine de chiffres dépasse la ligne. Les plus significatifs sont le 56,74,80,83,87, ces chiffres ont environ un tiers de trop.

Une dizaine de chiffres se trouve également en dessous de cette ligne. Les plus significatifs sont le 52,89 dont le nombre est quasiment diminué de moitié. On notera également les chiffres 33,63,78 qui se trouvent diminués d'environ un tiers.

Sur le graphique de Biden, une dizaine de chiffres dépasse la ligne. Les plus marquants sont le 43,59,82,89, dont on retrouve un tiers en trop.

Et comme son homologue républicain, on retrouve encore une dizaine de chiffres en deçà de la ligne. Cependant ici, un chiffre se démarque, le chiffre 94 qui n'est qu'à un tiers de son compte attendu. Les chiffres 52,55,77,86,88 ont eux moitié moins.

Méthodes
========

Afin de répondre à nos problématiques de l'introduction, nous procéderons comme suit pour les données des deux candidats :

-Application des tests statistiques afin de vérifier si elles sont en désaccord avec la loi de Benford. -Application des tests statistiques permettant de mesurer leur distance comparé à la loi de Benford.

Cette dichotomie entre ces deux objectifs est suggérée par Kossovsky \[4\]. En effet, selon lui, ces deux notions sont différentes et ont donc besoin d'être conceptuellement différenciées :

Le terme de conformité répond de manière binaire (oui ou non) au fait de savoir si la donnée est Benford. C'est le test le plus courant effectué par les différents analystes dans la littérature. Nous choisirons ici d'utiliser parmi tous les tests de conformité disponibles, le test du chi-carré de par son objectif qui est aligné au nôtre, mais aussi de par son abondance dans les études benfordiennes similaires.

Voici la formule du chi2 : $\\ Chi-Square= N\*\\sum \\frac{(Observed - Theory)^2}{Theory}$

La principale difficulté de celle-ci est de satisfaire les hypothèses sous-jacentes à son utilisation dans le contexte de la conformité.

Le terme de comparaison lui intervient car toutes les données de la vie réelle (non manipulées) ne se conforment pas à la loi de Benford. Ce terme se réfère à "un ensemble de données particulier avec sa propre configuration particulière". L'objectif est de déterminer à quel point la donnée est loin/proche de Benford.

Nous choisirons ici d'utiliser la SSD (somme des écarts au carré) en faveur de la MAD (Moyenne des écarts absolus). Cela pour les deux raisons évoquées par Kossovsky \[4\] qui sont : une plus grande simplicité d'interprétation visuelle et une base mathématique plus simple.

La principale difficulté des tests de distances est de placer les seuils de tolérance. Cerqueti et Maggi \[5\] dans un récent article nous en proposent pour les chiffres significatifs qui nous intéressent (tableau 1). Ces derniers ont été trouvés grâce à des recherches sur des données de la vie réelle et mathématiques abstraites.

Voici comment est calculée le SSD : $ SSD = ((100) \* Observed - (100) \* Theory)^2 $

**Tableau 1 - Seuil de tolérance SSD**

|   **DIGIT**  | **Quasi Benford Parfait** | **Benford Acceptable** | **Limite Benford** | **Non Benford** |
|:------------:|:-------------------------:|:----------------------:|:------------------:|:---------------:|
|    **1ER**   |           &lt; 2          |         2 - 25         |      25 - 100      |     &gt; 100    |
|   **2ÈME**   |           &lt; 2          |         2 - 10         |       10 - 50      |     &gt; 50     |
| **1ER-2ÈME** |           &lt; 2          |         2 - 10         |       10 - 50      |     &gt; 50     |

Enfin, le z-statistic test sera utilisé en complément du chi-carré. En effet, à l'opposé de ce dernier qui prend en compte tous les chiffres en même temps, le test z mesure chaque chiffre un à un. Son objectif est de tester si la fréquence d'un chiffre en particulier diffère significativement de ce qui est attendu sous la LDB.

Sa formule est la suivante : $ zstat = $

Suivant la littérature (Nigrini \[6\], Grammatikos & Papanikolaou \[7\]) , ces seuils de tolérance sont appliqués afin de rejeter l'hypothèse nulle : Une statistique z de : 2,57 indique une p-valeur de 0,01 ; 1,96 indique une p-valeur de 0,05 ; et 1,64 suggère une p-valeur de 0,10.

Tests & Résultats
=================

Voici l'application de ces tests aux premier, deuxième et premier-deuxième chiffres significatifs :

Le tableau résumant les proportions empiriques et théoriques du premier chiffre significatif des deux candidats est ainsi obtenu ci-dessous. Les intervalles de confiance des valeurs théoriques sont dans le tableau en lieu et place des simples proportions théoriques. Ces intervalles de confiance ont été calculées grâce aux travaux de Nigrni & Mitteraier \[8\] avec un alpha égal à 0.05.

**Tableau 2 - Valeurs théoriques et observés du premier CS pour Trump et Biden**

| **DIGIT** | **OBSERVÉ TRUMP** |  **THÉORIQUE IC** | **OBSERVÉ BIDEN** |
|:---------:|:-----------------:|:-----------------:|:-----------------:|
|   **1**   |       0.295       | \[0.285 ; 0.317\] |       0.295       |
|   **2**   |       0.164       | \[0.163 ; 0.189\] |       0.181       |
|   **3**   |       0.120       | \[0.113 ; 0.137\] |       0.128       |
|   **4**   |       0.098       | \[0.087 ; 0.107\] |       0.115       |
|   **5**   |       0.085       | \[0.070 ; 0.089\] |       0.065       |
|   **6**   |       0.072       | \[0.058 ; 0.076\] |       0.065       |
|   **7**   |       0.060       | \[0.050 ; 0.066\] |       0.054       |
|   **8**   |       0.055       | \[0.044 ; 0.059\] |       0.052       |
|   **9**   |       0.051       | \[0.039 ; 0.053\] |       0.044       |

Les résultats du tableau 2 montrent que toutes les valeurs de Trump sont bien comprises dans les valeurs théoriques attendues. Ce n'est pas le cas pour Biden, en effet les chiffres 4 et 5 se trouvent en dehors de leurs intervalles respectives.

On procède alors à la réalisation du test de chi-carré et de la mesure de la SSD. On obtient les résultats suivants pour Trump :

**Tableau 3 - Résultats du test statistique chi2 et de SSD de Trump**

|   **DIGIT**  | **CHI2 (p-valeur)** | **CHI2 (DL)** | **SSD** |
|:------------:|:-------------------:|:-------------:|:-------:|
|    **1ER**   |    9.564 (0.297)    |       8       |  3.249  |
|   **2ÈME**   |    4.934 (0.840)    |       9       |  1.577  |
| **1ER-2ÈME** |   101.968 (0.164)   |       89      |  3.502  |

Le second chiffre significatif a la p-valeur la plus haute (0.84) suivi du premier chiffre (0.29) et du premier-deuxième (0.164). On constate que l'hypothèse alternative du CHI2 pour les trois chiffres significatifs est assez largement rejetée. Les p-valeurs sont bien au-dessus du seuil de 5%. Selon ce test, les données de Trump ne sont pas en désaccord avec la loi de Benford.

Les valeurs de la SSD des trois chiffres sont très petites. Le second est même inférieur à 2 (1.58) et selon la classification du tableau 3, il est considéré comme étant presque parfaitement Benford. Le premier et le premier-deuxième sont eux autour de 3 (respectivement 3.25 et 3.5), ils sont considérés comme assez proches et acceptables de Benford.

Les résultats du chi-carré montrent que les données de Trump ne sont pas en désaccord avec Benford. Mais que justement, et grâce à la SSD, ceux-ci sont plutôt très proches de la loi. Cela suggère que les résultats d'élections de votes de Trump n'ont subi aucune manipulation/fraude détectable par la loi de Benford.

Les résultats de Biden sont les suivants :

**Tableau 4 - Résultats du test statistique chi2 et de SSD de Biden**

|   **DIGIT**  |  **CHI2 (p-valeur)** | **CHI2 (DL)** | **SSD** |
|:------------:|:--------------------:|:-------------:|:-------:|
|    **1ER**   | 20.943 (0.007\*\*\*) |       8       |  6.224  |
|   **2ÈME**   |     6.853 (0.652)    |       9       |  2.031  |
| **1ER-2ÈME** |    102.544 (0.154)   |       89      |   3.04  |

Ici, on constate que l'hypothèse alternative du CHI2 pour le deuxième et premier-deuxième chiffres significatifs est assez largement rejetée. Les p-valeurs sont bien au-dessus du seuil de 5%. Cependant, le premier chiffre est rejeté par le test du chi-carré. En effet sa p-valeur est largement en dessous du seuil de 5%, et même du seuil de 1% (0.007). Selon ce test, les données de Biden pour le premier CS sont en désaccord avec la loi de Benford.

Afin de tenter de déceler plus précisément quels chiffres seraient problématiques sur le premier CS, l'usage du z-statistique est effectué.

Voici les résultats du z-statistic obtenus sur le premier CS de Biden :

**Tableau 5 - Résultats du test statistique z de Biden**

| **DIGIT** | **Z-VALUE** |
|:---------:|:-----------:|
|   **1**   |    0.724    |
|   **2**   |    0.715    |
|   **3**   |    0.569    |
|   **4**   | 3.428\*\*\* |
|   **5**   | 2.846\*\*\* |
|   **6**   |    0.469    |
|   **7**   |    0.864    |
|   **8**   |    0.260    |
|   **9**   |    0.492    |

Selon les seuils précédemment décrits dans la partie Méthode, les chiffres 4 et 5 (respectivement 3.43 & 2.85) sont rejetés au seuil d'acceptance de 1%. Ce sont les chiffres qui ont été visuellement remarqués sur la figure 3 et qui étaient en dehors des intervalles de confiance pour les valeurs théoriques du tableau 2 . Le 4 a environ 1.8% de plus que la proportion attendue et le 5 a 1.4% de moins que la proportion attendue. Rapportés à la valeur de chaque proportion théorique, les différences sont d'environ 16% et 18% respectivement.

Concernant les valeurs du SSD, on remarque comme pour ceux de Trump que les trois chiffres sont assez petits. En effet ils sont tous inférieurs à 7 (respectivement 6.22, 2.03 et 3.04). Selon la classification, ils sont considérés comme assez proches et donc acceptables pour la LBD.

Les résultats du chi-carré et de la SSD pour le premier chiffre sont assez contradictoires. Tandis que le premier rejette largement l'hypothèse nulle de conformité à Benford, le deuxième montre que celle-ci est plutôt assez proche de Benford et est donc largement acceptable.

Selon l'analyse du premier chiffre par le chi-carré, les données du premier chiffre suggèrent une possible manipulation des données de Biden. Cependant d'après la SSD, les données de celui-ci sont assez proches et sont donc largement acceptables par la LDB. Cette contradiction nous amène à nous questionner sur les hypothèses de départ dans le cadre de l'utilisation de ces tests.

En regard des résultats du chi-carré, du z-statistique et des intervalles de confiance, les chiffres 4 & 5 du premier CS peuvent être sujets à une investigation plus précise. En passant à l'analyse du premier-deuxième CS, on remarque que les chiffres 40,43,51,59 et 94 sont rejetés par la valeur critique du z-statistique. Les quatre premiers chiffres cités sont en cohérence avec les valeurs significatives des chiffres 4 et 5. Une recherche plus poussée concernant les procédures électorales des comtés en question peut être menée.

    ## # A tibble: 46 × 3
    ##    county_name county_fips      n
    ##    <chr>             <int>  <int>
    ##  1 FRANKLIN          39049 409144
    ##  2 RENSSELAER        36083  40969
    ##  3 GASTON            37071  40959
    ##  4 DOUGLAS           20045  40785
    ##  5 WEBER             49057  40695
    ##  6 SANDOVAL          35043  40588
    ##  7 MINNEHAHA         46099  40482
    ##  8 CASS              38017  40311
    ##  9 STAFFORD          51179  40245
    ## 10 CENTRE            42027  40055
    ## # … with 36 more rows

Discussions et Conclusion
=========================

Cette contradiction entre les résultats du chi-carré et ceux de la SSD pour les votes de Biden nous poussent à scruter les hypothèses de départ du premier test. En effet les intervalles de confiance, le chi-carrée et le z-statistique indique une possible irrégularité. Mais la mesure de la sommme des écarts aux carrées nous indique le contraire.

Cette question est très bien débattue et résumée par l'article de Kossovsky \[4\]. L'auteur explique que le chi-carrée n'est pas adapté à une recherche de conformité sous loi de Benford. En effet, ce test repose sur l'indépendence du set de données analysés. Les données de ce dernier doivent être sélectionnées de manière totalement aléatoire dans une population infinie. Et cette population infinie doit respecter de manière parfaite la distribution sous laquelle la conformité est recherchée. Cependant la plupart des données de la vie réelle ne respecte pas ce procédé.

Cette hypothèse non satisfaite, l'usage du chi-carré sur cette analyse semble être erroné. Une mesure de distance semble être plus appropriée pour les données réelles comme conseillé par Kossovsky.

Comme vu précédemment, cette mesure place les données de Biden et de Trump comme étant largement Benford. Il n'y a donc aucune raison d'émettre un doute sur une manipulation en défaveur des résultats de ce dernier.

La loi de Benford ici, ne nous permet pas d'indiqueé une manipulation électorale ni sur Trump, ni sur Biden. De plus, son utilisation pour détecter les fraudes électorales est assez controversé (voir \[1\]). Cependant, la LB ne fait que gagner en popularité ces dernières décennies de par sa curiosité mathématique et son application à la vie réelle. Elle n'est qu'à son crépuscule et son potentiel reste assez grand.

Annexe
======

Ressources citées :

1.  Fernández-Gracia & Lucas Lacasa, "Bipartisanship Breakdown, Functional Networks, and Forensic Analysis in Spanish 2015 and 2016 National Elections" [2018](https://www.hindawi.com/journals/complexity/2018/9684749/#forensic-analysis)

2.  Hill T., “Base-invariance implies Benford’s law” [1995](https://www.semanticscholar.org/paper/Base-Invariance-Implies-Benford%27s-Law-Hill/6997052a48e0a399ab1ae7b82c6b83e7e7e35efc)

3.  Pericchi & Torres, "Quick Anomaly Detection by the Newcomb--Benford Law, with Applications to Electoral Processes Data from the USA, Puerto Rico and Venezuela" [2012](https://projecteuclid.org/journals/statistical-science/volume-26/issue-4/Quick-Anomaly-Detection-by-the-NewcombBenford-Law-with-Applications-to/10.1214/09-STS296.full)

4.  Kossovsky, "On the Mistaken Use of the Chi-Square Test in Benford’s Law" [2021](https://www.mdpi.com/2571-905X/4/2/27/htm)

5.  Cerqueti & Maggi, "Data validity and statistical conformity with Benford’s Law" [2021](https://www.researchgate.net/publication/349593474_Data_validity_and_statistical_conformity_with_Benford's_Law)

6.  Nigrini, "Benford's Law, Applications for Forensic Accounting, Auditing and Fraud Detection" [2011](http://library.wbi.ac.id/repository/34.pdf)

7.  Grammatikos & Papanikolaou, "Applying Benford’s Law to Detect Accounting Data Manipulation in the Banking Industry" [2021](https://link.springer.com/article/10.1007/s10693-020-00334-9)

8.  Nigrini & Mittermaier, "The Use of Benford's law as an Aid in Analytical Procedures" [1997](https://www.thefreelibrary.com/The+use+of+Benford%27s+Law+as+an+aid+in+analytical+procedures-a020746462)

Ressources non citées :

1.  Barabesi, Cerasa, Cerioli & Perrotta "On Characterizations and Tests of Benford’s Law" [2021](https://www.tandfonline.com/doi/full/10.1080/01621459.2021.1891927)

2.  Kossovsky, Arithmetical Tugs of War and Benford’s Law [2015](https://arxiv.org/pdf/1410.2174.pdf)

3.  Reality Check team, "US election 2020: Fact-checking Trump team's main fraud claims" [2020](https://www.bbc.com/news/election-us-2020-55016029)

4.  V.Genest & C.Genest, La loi de Newcomb-Benford ou la loi du premier chiffre significatif [2011](https://archimede.mat.ulaval.ca/amq/bulletins/mai11/Article_Genest.pdf)
