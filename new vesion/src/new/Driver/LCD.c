#include"LCD.h"

void LCD_init(void)
{
    PTFIFO = 0xffffffff;
}

void Draw_pic(const uint16_t* pic,uint16_t x,uint16_t y,uint16_t size)
{
    if((x+size <= X_Limit)&&(y+size <= Y_Limit))
    {
       uint32_t xy,temp_size;
        xy = ((uint32_t)x << 16) | (uint32_t)y;
        temp_size = (uint32_t)(size - 1);

        PTFIFO = xy;
        PTFIFO = temp_size;
        PTFIFO = (uint32_t)pic; 
    }
}
