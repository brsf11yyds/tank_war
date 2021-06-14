#include"Game.h"

void GameInit()
{
    ObjectMemSize = sizeof(object);
    MemTabCursor   = 0;

    int i;
    for(i=0;i<MaxObjNum;i++)
    {
        MemTab[i] = 0;
    }
}

object* Omalloc(void)
{
    uint32_t i;
    for(i=MemTabCursor;i<MaxObjNum;i++)
    {
        if(MemTab[i] == 0)
        {
            MemTabCursor = i+1;
            MemTab[i] = 1;
            return (object*)(i*ObjectMemSize);
        }
    }
    return 0;
}

void Ofree(object* game_obj)
{
    uint32_t temp;
    temp = (uint32_t)game_obj / (uint32_t)ObjectMemSize;
    MemTab[temp] = 0;
    MemTabCursor = temp;
}
