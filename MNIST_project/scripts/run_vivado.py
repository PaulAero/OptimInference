# run_vivado.py
import subprocess
import os

# Ajouter le chemin de Vivado à l'environnement
os.environ['PATH'] += ':/tools/Xilinx/Vivado/2024.1/bin'

# Commande pour exécuter le script TCL
tcl_script_path = "../tcl_scripts/run_simulation.tcl"
command = "vivado -mode batch -source " + tcl_script_path

# Exécution de la commande
try:
    result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
    if result.returncode != 0:
        print("Erreur lors de l'exécution de Vivado :")
        print(result.stderr)
    else:
        print("Simulation terminée avec succès.")
        # Analyse des résultats
        with open('simulation_results.txt', 'r') as f:
            simulation_outputs = f.read()
        # Comparaison avec les résultats Python
        # À implémenter selon vos besoins
except Exception as e:
    print(f"Erreur lors de l'exécution : {e}")
    print(f"Détails : {e.stderr}")
