#ifndef _BUZZE_H_
#define _BUZZE_H_
#include<stdint.h>

//Buzzer DEF
typedef struct
{
    volatile uint32_t BuzzerBGMAddr;
    volatile uint32_t BuzzerBGMCtr;
    volatile uint32_t BuzzerSoundAddr;
    volatile uint32_t BuzzerSoundCtr;
}BuzzerStr;

#define Buzzer_BASE 0x40000000
#define Buzzer ((BuzzerStr *)Buzzer_BASE)

#endif
