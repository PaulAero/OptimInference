# export_weights.py
import tensorflow as tf
from tensorflow.keras import layers, models
import numpy as np

def float_to_fixed(value, fractional_bits=8):
    scale = 2 ** fractional_bits
    max_int = 2 ** (16 - 1) - 1
    min_int = -2 ** (16 - 1)
    int_value = int(round(value * scale))
    return max(min(int_value, max_int), min_int)

def quantize_weights(weights, fractional_bits=8):
    vectorized_quantize = np.vectorize(float_to_fixed)
    return vectorized_quantize(weights)

def write_coe_file(quantized_weights, filename):
    with open(filename, 'w') as f:
        f.write("; Fichier COE généré par export_weights.py\n")
        f.write("memory_initialization_radix=10;\n")
        f.write("memory_initialization_vector=\n")
        flat_weights = quantized_weights.flatten()
        f.write(",\n".join(map(str, flat_weights)))
        f.write(";\n")

# Chargement du modèle
model = models.Sequential()
model.add(layers.Dense(16, activation='relu', input_shape=(28 * 28,)))
model.add(layers.Dense(10, activation='softmax'))
model.load_weights('model_weights.weights.h5')

# Exportation des poids et biais
weights_layer1 = model.layers[0].get_weights()[0]
biases_layer1 = model.layers[0].get_weights()[1]

weights_layer2 = model.layers[1].get_weights()[0]
biases_layer2 = model.layers[1].get_weights()[1]

# Quantification des poids et biais
weights_layer1_q = quantize_weights(weights_layer1)
biases_layer1_q = quantize_weights(biases_layer1)

weights_layer2_q = quantize_weights(weights_layer2)
biases_layer2_q = quantize_weights(biases_layer2)

# Écriture des fichiers COE
write_coe_file(weights_layer1_q, '../hardware_description/weights/weights_layer1.coe')
write_coe_file(biases_layer1_q, '../hardware_description/weights/biases_layer1.coe')
write_coe_file(weights_layer2_q, '../hardware_description/weights/weights_layer2.coe')
write_coe_file(biases_layer2_q, '../hardware_description/weights/biases_layer2.coe')
