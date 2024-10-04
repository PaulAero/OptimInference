# main_mnist.py
import tensorflow as tf
from tensorflow.keras import layers, models
import numpy as np

# Chargement des données MNIST
(train_images, train_labels), (test_images, test_labels) = tf.keras.datasets.mnist.load_data()

# Prétraitement des données
train_images = train_images.reshape((60000, 28 * 28)) / 255.0
test_images = test_images.reshape((10000, 28 * 28)) / 255.0

# Modèle du réseau de neurones
model = models.Sequential()
model.add(layers.Dense(16, activation='relu', input_shape=(28 * 28,)))
model.add(layers.Dense(10, activation='softmax'))

# Compilation du modèle
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# Entraînement du modèle
model.fit(train_images, train_labels, epochs=5, batch_size=64)

# Évaluation du modèle
test_loss, test_acc = model.evaluate(test_images, test_labels)
print(f"Précision sur le jeu de test : {test_acc}")

# Sauvegarde des poids
model.save_weights('model_weights.weights.h5')
# ValueError: The filename must end in `.weights.h5`. Received: filepath=model_weights.h5
