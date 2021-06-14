#ifndef _REALTANK_H_
#define _REALTANK_H_

#include<stdint.h>

#include"GameSDK/Game.h"
#include"Asset.h"

#define ObjTypeNum 7

#define ObjTypeBlack 0
#define ObjTypeWall 1
#define ObjTypeBox 2
#define ObjTypeGrass 3
#define ObjTypeTank_alliance 4
#define ObjTypeTank_hostile 5
#define ObjTypeBullet 6

static const uint16_t* AssetTab[ObjTypeNum];

void RealTank_GameInit(void);

#endif
