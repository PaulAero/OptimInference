import subprocess
import os

# Ajoutez le chemin de Vivado à l'environnement virtuel
os.environ['PATH'] += ':/tools/Xilinx/Vivado/2024.1/bin'

# La commande à exécuter
path_tcl = "/home/pi-project-admin/PycharmProjects/OptimInference/Tests/test_tcl_vivado/test_tcl.tcl"
command = "vivado -mode batch -source " + path_tcl

# Exécuter la commande
try:
    # Capture la sortie standard et les erreurs de la commande
    result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)

    # Affiche la sortie standard
    print("Vivado command executed successfully.")
    print(result.stdout)  # Affiche la sortie standard

    # Optionnel : Afficher les erreurs si nécessaire
    if result.stderr:
        print("Error output:")
        print(result.stderr)

except subprocess.CalledProcessError as e:
    print(f"Error executing Vivado command: {e}")