# Définition des variables
set project_name "MNIST_NN"
set project_path "../vivado_project"
set part_name "xc7a200tfbg676-2"

# Création ou ouverture du projet
if { [file exists $project_path] } {
    open_project $project_path/$project_name.xpr
} else {
    create_project $project_name $project_path -part $part_name
}

# Ajout des fichiers VHDL
add_files ../hardware_description/Neuron.vhd
add_files ../hardware_description/Layer.vhd
add_files ../hardware_description/NeuralNetwork.vhd
add_files ../hardware_description/NeuralNetwork_tb.vhd

# Ajout des fichiers de poids
add_files -fileset sources_1 ../hardware_description/weights/weights_layer1.coe
add_files -fileset sources_1 ../hardware_description/weights/biases_layer1.coe
add_files -fileset sources_1 ../hardware_description/weights/weights_layer2.coe
add_files -fileset sources_1 ../hardware_description/weights/biases_layer2.coe

# Configuration du top module
set_property top NeuralNetwork [current_fileset]

# Configuration du test bench
set fileset [get_filesets sim_1]
set_property top NeuralNetwork_tb $fileset

# Lancement de la simulation
launch_simulation

# Exécution de la simulation
run all

# Fermeture du projet
close_project
exit
