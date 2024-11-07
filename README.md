# OptimInference

## Introduction

Ce projet vise à améliorer l'inférence d'une IA déjà entraînée sur FPGA en utilisant une IA tierce. Cette IA tierce utilisera probablement un algorithme génétique.

Ainsi, on a l'architecture suivante :

- IA entraînée via un script Python qui est ensuite décrite en VHDL

- La description VHDL, le fichier de test bench et les poids (exportés au format COE)

- Des données de test mises en forme pour faciliter l'implémentation sur FPGA

- Un programme Python tiers qui lance les simulations sur Vivado par l'intermédiaire d'un script TCL, qui lit les résultats obtenus lors de la simulation puis modifie l'implémentation.

Il est à noter qu'il existe des techniques plus simples, comme la quantification des poids ou la compression de réseau, qui contribuent également à optimiser l'inférence d'une IA sur FPGA. Ceci sera développé dans l'état de l'art.

Le projet est exploratoire mais doit rester transposable pour une application sur une architecture de FPGA embarqué, permettant ainsi une implémentation pratique dans des systèmes réels.

## État de l'Art

Pour optimiser l'inférence d'une IA sur FPGA, des techniques plus simples sont souvent testées en premier lieu. Elles incluent principalement la quantization et la compression des réseaux, comme mentionné ci-dessus. La quantization consiste à réduire la précision des poids et des activations (par exemple, passer de nombres en virgule flottante à des entiers de faible précision), ce qui permet de réduire la complexité de calcul et la consommation de ressources sur FPGA, sans sacrifier significativement les performances du modèle. Cependant, il est important d'évaluer systématiquement les performances après chaque modification.

### Quantization

La quantization est particulièrement utile dans des contextes où la mémoire et la puissance de calcul sont limitées. Elle permet de réduire les besoins en stockage et en bande passante, ce qui est essentiel pour des architectures embarquées. Des approches populaires incluent la quantization uniforme et la quantization non-uniforme, chacune ayant ses propres compromis entre complexité et efficacité. 

### Compression des réseaux

La compression de réseau vise à réduire le nombre de paramètres du modèle en utilisant des techniques telles que le pruning (élimination des connexions non pertinentes) ou la factorisation de matrices. Le pruning, par exemple, identifie et supprime les poids ayant une influence négligeable sur la sortie, ce qui permet de simplifier le modèle tout en maintenant des performances élevées. La factorisation de matrices consiste à décomposer les poids en plusieurs matrices plus petites, réduisant ainsi le nombre total de calculs nécessaires.

Ces techniques permettent de diminuer la taille du modèle et d'accélérer les inférences, rendant l'implémentation sur FPGA plus efficace et accessible.



**A continuer**



## Pipeline de test

Le dossier "Tests" permet de vérifier la bonne installation des différents logiciels et de valider le fonctionnement du pipeline suivant :

- Script Python

- Script TCL

- Simulation

Note : le script TCL utilisé actuellement crée un projet si celui-ci n'existe pas et le FPGA utilisé pour le test est le xc7a200tfbg676-2.

## Application : cas simple MNIST

### Présentation du réseau de neurones utilisé

On souhaite faire fonctionner dans un premier temps une IA simple pour comprendre comment implémenter une IA sur FPGA avant de chercher à l'optimiser.

Pour cela, on construit et entraîne l'IA suivante via Python :

```python
# Modèle du réseau de neurones pour MNIST
model = models.Sequential()
model.add(layers.Dense(16, activation='relu', input_shape=(28 * 28,)))
model.add(layers.Dense(10, activation='softmax'))
```

Concrètement, on aplatit l'image 2D en une dimension et on obtient donc un vecteur d'entrée de 784x1 (28x28). Les 16 neurones de la première couche prennent en entrée ce vecteur. Chaque neurone de la deuxième couche est connecté à chacune des sorties des 16 neurones de la première couche (connexion entièrement connectée, ou 'dense', avec un vecteur d'entrée de chaque neurone 16x1).

La première couche utilise la fonction ReLU (Rectified Linear Unit), qui remplace les valeurs négatives par zéro et laisse les positives inchangées. Ce choix est motivé par la capacité de ReLU à introduire de la non-linéarité, indispensable pour que le réseau puisse apprendre des relations complexes dans les données. De plus, elle est rapide à calculer et réduit le risque de problème de gradient qui disparaît, souvent observé avec d'autres fonctions.

Pour la couche de sortie, la fonction Softmax est utilisée, car elle convertit les sorties des neurones en une distribution de probabilités. En rendant la somme des sorties égale à 1, Softmax permet d’interpréter chaque neurone de la sortie comme la probabilité de chaque chiffre de 0 à 9.

**Remarque** : l'ensemble de données MNIST permet d'entraîner une IA à reconnaître des chiffres manuscrits sur un dataset d'images de 28x28 pixels. Voir [Base de données MNIST — Wikipédia](https://fr.wikipedia.org/wiki/Base_de_donn%C3%A9es_MNIST).

### Implémentation en VHDL

#### Décrire un neurone

Pour créer notre réseau de neurones, nous allons utiliser comme brique de base un fichier neurone générique qu'il est donc nécessaire de décrire.

Fonctionnement général d'un neurone :

- Optionnel : en cas de réseau convolutionnel, on applique une fonction *f* au vecteur d'entrée *x*.

- On effectue le calcul matriciel suivant : *z = Wx + b* avec *W* le poids et *b* le biais.

- On applique la fonction d'activation choisie *g* à *z*.

La fonction ReLU (Rectified Linear Unit) est une fonction d'activation qui met à zéro toutes les valeurs négatives d'un vecteur d'entrée, tout en laissant inchangées les valeurs positives. 

La fonction d'activation Softmax n'est pas évidente, notamment du fait de la présence de l'exponentielle. Ceci peut être pallié grâce à l'utilisation du développement limité de type série de Taylor-Young, qui doit être d'un degré suffisamment élevé (au moins de 4 à 5) pour ne pas fausser le modèle.

Si on traduit ceci en VHDL, voici comment il faut procéder :

- Créer une entité VHDL représentant le neurone avec des ports pour les entrées, les poids, le biais, et la sortie et un bus de sélection de la fonction d'activation.

- Décrire le comportement interne de l'entité pour effectuer les opérations de multiplication des entrées par les poids, ajouter le biais, et appliquer la fonction d'activation spécifiée.

Pour faciliter la vérification et le debug, il est recommandé de réaliser un test bench du fichier *Neuron.vhd*. Ce test bench doit simuler différentes combinaisons de valeurs d'entrée, de poids et de biais, afin de s'assurer que chaque composant du neurone fonctionne correctement. Les tests devraient vérifier :

- La précision des opérations de multiplication et d'addition.

- Le comportement des différentes fonctions d'activation (par exemple, vérifier que ReLU remplace correctement les valeurs négatives).

- La stabilité et la validité des résultats, notamment lorsque des valeurs limites (très grandes ou très petites) sont fournies en entrée.

#### Décrire un réseau de neurones

(travail en cours)

Pour décrire un réseau de neurones complet en VHDL, il est essentiel de définir une entité représentant chaque couche et de les organiser de manière hiérarchique pour former le réseau complet. Chaque couche du réseau est constituée de plusieurs instances du composant 'neurone', connectées entre elles afin de permettre la propagation des données.

On crée donc une description VHDL pour chaque couche. Cette entité regroupe les neurones de la couche et inclut des ports pour les entrées, les poids, et les sorties. Les entrées de la couche sont représentées par un vecteur qui est partagé par tous les neurones de cette couche, tandis que les poids peuvent être organisés sous forme de matrice, où chaque colonne correspond aux poids d'un neurone spécifique. Les sorties, quant à elles, forment un vecteur qui regroupe les résultats de chaque neurone après l'application de la fonction d'activation choisie.

Une fois les entités de chaque couche définies, il est nécessaire de décrire les interconnexions entre les différentes couches du réseau. Ces interconnexions sont cruciales pour assurer la propagation des données d'une couche à l'autre. Concrètement, les sorties d'une couche sont directement reliées aux entrées de la couche suivante. Cette structure hiérarchique permet de faciliter l'organisation du réseau, où chaque couche est encapsulée dans une entité supérieure représentant l'ensemble du réseau. Cette approche modulaire facilite non seulement la conception, mais aussi le débogage et les modifications ultérieures.

Les fonctions d'activation jouent également un rôle central dans le fonctionnement du réseau. Chaque couche peut avoir une fonction d'activation différente, qui est spécifiée au niveau de chaque neurone. Par exemple, la première couche peut utiliser la fonction ReLU pour introduire de la non-linéarité, tandis que la dernière couche applique souvent la fonction Softmax pour obtenir des probabilités de classification. Ces fonctions doivent être soigneusement implémentées et paramétrées pour garantir le bon comportement du réseau.

La gestion des poids et des biais est un autre aspect crucial de la description du réseau. Les poids et biais peuvent être initialisés à partir de fichiers externes, souvent au format COE, qui contiennent les valeurs obtenues lors de l'entraînement du modèle en Python. Cette approche permet une intégration cohérente des résultats de l'entraînement dans l'implémentation matérielle, assurant ainsi que le comportement du réseau sur FPGA reflète celui observé lors de la simulation logicielle.

Enfin, la validation de l'ensemble du réseau via un test bench est indispensable. Ce test bench doit vérifier la propagation correcte des valeurs d'entrée à travers toutes les couches du réseau, ainsi que la précision des résultats finaux. Pour cela, il est recommandé de tester différentes configurations de poids, de biais et de valeurs d'entrée. Ces tests doivent permettre de s'assurer que la sortie finale correspond aux résultats attendus, et ce pour chaque étape de traitement à travers les couches du réseau.#### Implémenter le réseau complet

À faire

## Sources utiles
