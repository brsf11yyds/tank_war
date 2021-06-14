#include<stdint.h>
#include<stdbool.h>

//INTERRUPT DEF
#define NVIC_CTRL_ADDR (*(volatile unsigned *)0xe000e100)


//Keyboard

#define Keyboard_BASE 0x40001000
#define KeyboardReg (*(uint32_t *)Keyboard_BASE)


void Delay(int interval);
void LCD_write(uint16_t data,uint32_t isData);
