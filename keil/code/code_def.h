#include <stdint.h>

//中断控制
#define NVIC_CTRL_ADDR (*(volatile unsigned *)0xe000e100)

//数码管输出帧率
#define ledisp (*(volatile unsigned *)0x40000000)

//读键盘
#define ledisp (*(volatile unsigned *)0x40000100)