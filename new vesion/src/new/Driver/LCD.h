#ifndef _LCD_H_
#define _LCD_H_
#include<stdint.h>

//PTFIFO
#define PTFIFO_BASE 0x50000000
#define PTFIFO (*(uint32_t *)PTFIFO_BASE)

#define X_Limit 240
#define Y_Limit 320

void LCD_init(void);
void Draw_pic(const uint16_t* pic,uint16_t x,uint16_t y,uint16_t size);

#endif
