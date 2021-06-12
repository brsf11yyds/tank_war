#include <stdint.h>
#include "code_def.h"
uint16_t fps_flag;
uint16_t fps_count;

void fps_hanlder(void)
{
    fps_flag = 1;
    if(fps_count == 30)
    {
        fps_count =0;
    }
    else
    {
        fps_count += 1;
    }
}

void disp_fps(uint16_t fps_count_game)
{
    ledisp = fps_count_game;
}