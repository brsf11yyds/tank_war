#ifndef _UART_H_
#define _UART_H_

#include<stdint.h>

typedef struct
{
    uint32_t DATA;
    uint32_t STATE;
    uint32_t CTRL;
    uint32_t INTSTATUSnCLEAR;
    uint32_t BAUDDIV;
}UARTStr;

#define UART_BASE 0x40002000
#define UART ((UARTStr *)UART_BASE)

#endif