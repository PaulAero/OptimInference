import os
import numpy as np
import tensorflow as tf

# Chargement du jeu de données MNIST
(train_images, train_labels), (test_images, test_labels) = tf.keras.datasets.mnist.load_data()

# Créer un répertoire pour stocker les fichiers texte
output_dir = '../data/mnist_samples/'
os.makedirs(output_dir, exist_ok=True)

# Fonction pour sauver une image dans un fichier texte
def save_image_as_text(image, filename):
    with open(filename, 'w') as f:
        # Aplatir l'image en 1D et écrire chaque valeur de pixel dans une nouvelle ligne
        for pixel in image.flatten():
            f.write(f"{pixel}\n")

# Sauvegarder les 5 premières images du dataset MNIST
for i in range(10):
    image = train_images[i]
    filename = os.path.join(output_dir, f"image{i+1}.txt")
    save_image_as_text(image, filename)

print("Fichiers d'images MNIST sauvegardés dans 'data/mnist_samples/'")
