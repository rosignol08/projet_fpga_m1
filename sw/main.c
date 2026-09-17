#include <stdint.h>
#include "xparameters.h"
#include "xgpio.h"
#include "xil_io.h"

// Déclaration des périphériques GPIO
XGpio Gpio_Switches;
XGpio Gpio_Buttons;
XGpio Gpio_Leds; // DECOMMENTE SI TU AS UN BLOC GPIO POUR LES LEDS DANS VIVADO

int main() {
    //les GPIO TODO
    XGpio_Initialize(&Gpio_Switches, XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_Initialize(&Gpio_Buttons,  XPAR_AXI_GPIO_1_DEVICE_ID);

    // Si tu as des LEDs (ex: GPIO 2)
    XGpio_Initialize(&Gpio_Leds, XPAR_AXI_GPIO_2_DEVICE_ID);
    XGpio_SetDataDirection(&Gpio_Leds, 1, 0x00000000); // 0 = Sortie

    //direction 1 pour entree
    XGpio_SetDataDirection(&Gpio_Switches, 1, 0xFFFFFFFF);//F partout pour dire toutes broches sont des entrees si 0 c'est des sorties
    XGpio_SetDataDirection(&Gpio_Buttons,  1, 0xFFFFFFFF);

    uint8_t adresse_train = 4;//de base elle peut varier avec le switch 0
    //uint8_t commande = 0;
    uint8_t mode = 0;
    uint8_t commande_finale = 0;
    uint8_t controle = 0;
    uint32_t reg0 = 0;//car une tramme de 64 bit ça fait importer une lib de 700 octets donc trop louds
	uint32_t reg1 = 0;
    uint32_t BASE_ADDR_DCC = XPAR_IP_CENTRALE_DCC_0_S00_AXI_BASEADDR;
    uint32_t val_lue;
    uint32_t affichage;
    //pour les fonction F13-F20
    uint8_t commande2 = 0;
    uint8_t octets_2 = 0;
    while (1) {
    	//faut lire les valeurs des switches et boutons
        uint32_t switches_val = XGpio_DiscreteRead(&Gpio_Switches, 1);
        uint32_t btn_val = XGpio_DiscreteRead(&Gpio_Buttons, 1);

        //si bouton central appuie on construit et envoie la commande
        if (btn_val & 0x01) {
        	//adresse
        	if (switches_val & 1){//si le sw0 == 1 alors train 5 sinon 4
        		adresse_train = 5;
        	}else{//sinon train 4
        		adresse_train = 4;
        	}

        	//mode
        	// (switches_val >> 1) ca decale de 1 bit vu qu'on a plus besoin du switch 0 ducoup sw1 est au bit 0
        	//pour lire le mode 00 ou 01 ou 10 ou 11 des 2 premiers bits
            if (((switches_val >> 1) & 0b11) == 0) {
                mode = 0;//commande de vitesse pour le faire avancer
            }
            else if (((switches_val >> 1) & 0b11) == 1) {
            	mode = 1;//groupe F0–F4
            }
            else if (((switches_val >> 1) & 0b11) == 2) {
            	mode = 2;//groupe F5–F12
            }
            else if (((switches_val >> 1) & 0b11) == 3) {
            	mode = 3;//groupe F13–F20
            }else{
            	mode = 0;//par defaut au cas ou on va le stoper
            }

            //parametre
            // (switches_val >> 3)ca decale de 3 bit vu qu'on a plus besoin des 3 premiers switch
            val_lue = (switches_val >> 3) & 0b11111;//les 5 bits de parametres

            if(mode == 0){//si mode 0 on fait une commande vitesse 01DXXXXX D c'est la direction ducoup
            	uint8_t direction = (switches_val >> 7) & 0x01;//sw7 c'est la direction
            	uint8_t vitesse = (switches_val >> 3) & 0x0F; //0x0F = 0b00001111
            	commande_finale = 0b01000000 | (direction << 5) | vitesse;
            	octets_2 = 0;
            }
            else if(mode == 1){//si mode 1 on fait F0-F4 donc 10000000
            	commande_finale = 0b10000000 | val_lue;
            	octets_2 = 0;
            }
            else if(mode == 2){//si mode 1 on fait F5-F12 donc 101S0000 s pour groupe de fonctions
            	commande_finale = 0b10100000 | val_lue;
            	octets_2 = 0;
            }
            else if(mode == 3){//F13-F17
            	commande_finale = 0b11011110;//octet qui bouge pas
            	commande2 = (uint8_t)(val_lue & 0b11111); //F18 et F20 c'est 0 on a pas de place :(
            	octets_2 = 1;
            }else{
            	//sinon on donne la commande stop
            	commande_finale = 0b01000000;
            	octets_2 = 0;
            }

            //bit de controle
            if (octets_2) {
                controle = adresse_train ^ commande_finale ^ commande2;
                affichage = (adresse_train << 8) | commande2;//faut afficher la commande 2 psk la 1 bouge pas

            } else {
                controle = adresse_train ^ commande_finale;
                //affiche la commande envoyee + l'adresse sur les LEDs de la carte
                affichage = (adresse_train << 8) | commande_finale;

            }

            //affiche la commande envoyee + l'adresse sur les LEDs de la carte
            XGpio_DiscreteWrite(&Gpio_Leds, 1, affichage);

            //les 2 slaves reg qui stoquent les 51 bits reset a 0

            reg0 = 0;
            reg1 = 0;
            if(!octets_2){
            	reg0 = 1;//bit de stop (le signal de fin)
            	reg0 |= (controle << 1);//les bits de control le 1 c'est psk on a mis de stop bit
            	reg0 |= (commande_finale << 10);//les parametres des fonctions parei pour le 10
            	reg0 |= (adresse_train << 19);//l'adresse du train
            	reg0 |= (0xF << 28);//preambule
            	reg1 = 0x7FFFF;
            }else{
            	//sinon on doit faire la trame en 2 octets
            	//[preambule] 0 [addr] 0 [cmd1] 0 [cmd2] 0 [ctrl] 1
            	reg0 = 1;//bit de stop (le signal de fin)
            	reg0 |= (controle << 1);//les bits de control le 1 c'est psk on a mis de stop bit
            	reg0 |= (commande2 << 10);//la commande num 2 octet 2 (bits 10-17)
            	reg0 |= (commande_finale << 19);//la commande des fonctions 19 car on a 9 bit avant pour la cmd 2 (bits 19-26)
				reg0 |= ((adresse_train & 0x0F) << 28);//l'addresse du train
				reg1 = ((adresse_train >> 4) & 0x0F);//preambule plus petit ducoup car on lui a vole les 9 bits de la cmd 2
				reg1 |= (0x3FFF << 5);
            }
            Xil_Out32(BASE_ADDR_DCC + 0, reg0);
            Xil_Out32(BASE_ADDR_DCC + 4, reg1);

            //anti-rebond
            while(XGpio_DiscreteRead(&Gpio_Buttons, 1) != 0);
        }
    }
    return 0;
}
