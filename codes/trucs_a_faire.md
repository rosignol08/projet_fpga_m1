
Ce document définit les étapes clés pour la réalisation du système mixte matériel/logiciel (VHDL/C) permettant de commander des trains miniatures via le protocole DCC.

----------

## Phase 1 : Développement des Blocs de Base (VHDL)

_Objectif : Implémenter les briques élémentaires de l'architecture matérielle._

-   [ ] **1.1. Diviseur d'Horloge & Tempo**
    
    -   Récupérer les codes fournis sur Moodle.
        
    -   Valider le signal `CLK_1MHz` (100 MHz -> 1 MHz).
        
    -   Vérifier le compteur de temporisation (délai de 6 ms entre les trames).
        
-   [ ] **1.2. Modules DCC_Bit_0 & DCC_Bit_1**
    
    -   Concevoir les machines à états (MAE) pour chaque bit.
        
    -   **Bit 0** : Impulsion 0 (100 µs) puis Impulsion 1 (100 µs).
        
    -   **Bit 1** : Impulsion 0 (58 µs) puis Impulsion 1 (58 µs).
        
    -   Sortie par défaut au niveau bas quand inactif.
        
-   [ ] **1.3. Registre à décalage DCC**
    
    -   Créer un registre capable de stocker la trame la plus longue.
        
    -   Gérer les fonctions de chargement (`load`) et de décalage (`shift`).
        

----------

## Phase 2 : Intégration Matérielle & Tests (VHDL)

_Objectif : Assembler une centrale autonome pilotée par interrupteurs._

-   [ ] **2.1. MAE Globale de Contrôle**
    
    -   Orchestrer les modules : charger le registre, envoyer les bits un par un via les modules `DCC_Bit`, et gérer la pause de 6 ms.
        
-   [ ] **2.2. Générateur de Trames de Test**
    
    -   Compléter le squelette VHDL avec des trames réelles (ex: Adresse 2, Marche Avant, Vitesse Max).
        
-   [ ] **2.3. Top_DCC & Simulation**
    
    -   Assembler tous les modules dans un fichier `Top_DCC.vhd`.
        
    -   **Testbench critique** : Vérifier les chronogrammes via simulation comportementale (Vivado) avant l'implémentation.
        
-   [ ] **2.4. Validation Physique (Oscilloscope)**
    
    -   Affecter la sortie à la broche `JA[4]` (PMOD A).
        
    -   Vérifier à l'oscilloscope la conformité des signaux (niveaux logiques et timings).
        

----------

## Phase 3 : Intégration Système sur Puce (IP & Microblaze)

_Objectif : Remplacer les interrupteurs par un processeur Microblaze._

-   [ ] **3.1. Création de l'IP Centrale DCC**
    
    -   Créer l'IP dans Vivado avec un **AXI Wrapper**.
        
    -   Choisir la stratégie de registre :
        
        -   _Option A_ : Le Microblaze calcule toute la trame (bit à bit).
            
        -   _Option B_ : Le Microblaze envoie juste l'adresse/vitesse, l'IP génère la trame.
            
-   [ ] **3.2. Design Block (Vivado)**
    
    -   Connecter : Microblaze, Bus AXI, RAM, GPIO (LED/Boutons/Switches) et l'IP Centrale DCC.
        
    -   Générer le Bitstream.
        

----------

## Phase 4 : Développement Logiciel (C / Vitis)

_Objectif : Piloter les trains via une interface utilisateur logicielle._

-   [ ] **4.1. Gestion des Entrées (GPIO)**
    
    -   Lire l'état des boutons/interrupteurs pour définir la consigne (direction, vitesse, fonctions F0-F21).
        
-   [ ] **4.2. Algorithme de Calcul de Trame**
    
    -   Calculer l'octet de contrôle (XOR entre adresse et commande).
        
    -   Respecter le format : Préambule (14+ bits à 1) | Start | Adresse | Start | Commande | Start | Contrôle | Stop.
        
-   [ ] **4.3. Pilotage & Validation Finale**
    
    -   Envoyer la trame uniquement lors de l'appui sur un bouton de validation.
        
    -   Tester sur la plateforme de trains réels.