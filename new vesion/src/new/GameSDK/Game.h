#ifndef _GAME_H_
#define _GAME_H_

#include<stdint.h>

#define MaxObjNum 180

typedef struct obj_str object;

typedef struct obj_str
{
    object* last;
    object* next;
    uint16_t axis_x;       
    uint16_t axis_y;       
    char attr;             
    char direct;           
    
}object;

static unsigned char ObjectMemSize;
static unsigned char MemTab[MaxObjNum];
static unsigned MemTabCursor;

void    GameInit(void);
object* Omalloc(void);
void    Ofree(object* game_obj);

#endif
