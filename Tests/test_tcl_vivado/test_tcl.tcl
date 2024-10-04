# Définir le chemin du projet
set project_name "test_adder"
set project_path "./test_adder_project"
set part_name "xc7a200tfbg676-2"

# Vérifier si le projet existe déjà
if { [file exists $project_path] } {
    # Si le projet existe, l'ouvrir
    open_project $project_path/$project_name.xpr
    puts "Le projet existe déjà. Ouverture du projet."
} else {
    # Si le projet n'existe pas, le créer
    create_project $project_name $project_path -part $part_name
    puts "Création d'un nouveau projet."
}

# Ajouter les fichiers sources avec des chemins absolus
add_files /home/pi-project-admin/PycharmProjects/OptimInference/Tests/test_tcl_vivado/simple_adder.vhd
add_files /home/pi-project-admin/PycharmProjects/OptimInference/Tests/test_tcl_vivado/simple_adder_tb.vhd

# Définir la propriété de bibliothèque en utilisant des chemins absolus
set_property library work [get_files /home/pi-project-admin/PycharmProjects/OptimInference/Tests/test_tcl_vivado/simple_adder.vhd]
set_property library work [get_files /home/pi-project-admin/PycharmProjects/OptimInference/Tests/test_tcl_vivado/simple_adder_tb.vhd]

# Spécifier le module principal pour la synthèse
set_property top simple_adder [current_fileset]

# Lancer la synthèse
synth_design -top simple_adder -part $part_name

# Assurez-vous que le fileset de simulation est actif et définissez le top module
set fileset [get_filesets sim_1]
set_property top simple_adder_tb $fileset

# Lancer la simulation
launch_simulation

# **Ajouter les commandes pour le VCD**

# Ouvrir le fichier VCD
open_vcd ./simulation_results.vcd

# Spécifier les signaux à enregistrer
log_vcd *

# Exécuter la simulation pendant 1000 ns
run 1000 ns

# Fermer le fichier VCD
close_vcd

# Fermer le projet
close_project
exit
