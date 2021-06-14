#include"Driver/code_def.h"
#include"Driver/Buzzer.h"
#include"Driver/LCD.h"
#include"Driver/Timer.h"
#include"Driver/UART.h"

#include"GameSDK/Game.h"
#include"RealTank.h"

uint32_t timer_flag;
uint16_t y;
uint16_t x;

int main()
{
    NVIC_CTRL_ADDR = 0x0;
	Delay(6000000);
	LCD_init();
	Delay(1000000);
    GameInit();

    UART_Init();

    int i,j;
    for(i=0;i<10;i++)
    {
        UART_putc('h');
    }

    Draw_pic(black,110,300,20);

    
    for(i=0;i<12;i++)
    {
        for(j=0;j<16;j++)
        {
            Draw_pic(black,i*20,j*20,20);
        }
    }

    NVIC_CTRL_ADDR = 0x3;

    timer_flag = 0;
    
    y = 0;
    x = 0;
    while(1)
    {
        if(x>=220)
        {
            x = 0;
        }
        Draw_pic(box,x,y,20);
        while(!timer_flag);
        Draw_pic(black,x,y,20);
        x++;
        timer_flag = 0;
    }

    
		
    return 0;
}



void KEY()
{

}

void Timer_IRQ()
{
    timer_flag = 1;
    if(TimerReg == 15)
    {
        if(y>=300)
        {
            Draw_pic(black,x,y,20);
            y = 0;
        }
        else
        {
            Draw_pic(black,x,y,20);
            y += 20;
        }
    }
}
