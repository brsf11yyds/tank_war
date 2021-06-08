#include <stdint.h>
#include <stdio.h>
#include "code_def.h"
#include <math.h>
extern uint16_t fps_flag;
extern uint16_t fps_count;

typedef struct object
{
    uint16_t axis_x;       //x坐标
    uint16_t axis_y;       //y坐标
    char attr;             //属性：1：墙  2：木箱  3：草  4：己方坦克 5：敌方坦克 6：子弹
    char direct;           //方向：wasd
    struct object *next;   //链表指针

};                         
struct object *T,*H,*L1,*L2,*L1B,*L2B; //H头指针
	


void GAME_CREAT_TANK()
{
    T = (struct object*)malloc(sizeof(struct object));
    T->next = NULL;
    T->axis_x = 20*2+16;
    T->axis_y = 320-20*2-16;
    T->attr = '5';
    T->direct = 'd';
    T->next = H->next;
    H->next = T;
}

void GAME_INI()
{
    uint32_t i;
    H = (struct object*)malloc(sizeof(struct object));
    H->next = NULL;
    H->attr = '4';
    H->direct = 'w';
    H->axis_x = 240-20-16;
    H->axis_y = 320-20-16;

    GAME_CREAT_TANK();

    for(i=0;i<=12;i++)
    {
        T = (struct object*)malloc(sizeof(struct object));
        T->next = NULL;
        T->axis_x = 0;
        T->axis_y = 60 +i*20;
        T->attr = '1';
        T->direct = 'w';
        T->next = H->next;
        H->next = T;
    }
    for(i=0;i<=12;i++)
    {
        T = (struct object*)malloc(sizeof(struct object));
        T->next = NULL;
        T->axis_x = 240-20;
        T->axis_y = 60+i*20;
        T->attr = '1';
        T->direct = 'w';
        T->next = H->next;
        H->next = T;
    }
    for(i=1;i<=10;i++)
    {
        T = (struct object*)malloc(sizeof(struct object));
        T->next = NULL;
        T->axis_x = i*20;
        T->axis_y = 60;
        T->attr = '1';
        T->direct = 'w';
        T->next = H->next;
        H->next = T;
    }
    for(i=1;i<=10;i++)
    {
        T = (struct object*)malloc(sizeof(struct object));
        T->next = NULL;
        T->axis_x = i*20;
        T->axis_y = 320-20;
        T->attr = '1';
        T->direct = 'w';
        T->next = H->next;
        H->next = T;
    }

}


void GAME_OVER()
{

}

int main()
{


    GAME_INI();
    uint16_t i;
    uint16_t shoot_count;
    uint32_t din;
    uint32_t ans;
    uint16_t crash_flag = 0;
    uint16_t move_flag = 0;
    uint16_t ai_shoot_count =0; 
    uint16_t ai_move_flag=0;     
    uint16_t score = 0;

    uint16_t fps_count_game;


	
    while(1)
    {   NVIC_CTRL_ADDR = 0xf;
        while(fps_flag) ;
        fps_flag = 0;
        NVIC_CTRL_ADDR = 0;
        if(shoot_count < 30) shoot_count += 1; //射击计时
        if(ai_shoot_count < 60) ai_shoot_count += 1; //ai射击计时

        din = Keyboard;     //读键盘


        for (i = 0; i < 16; i++) 
        {
		    if ((din >> i) & 1) 
            {
		    	ans = i;
		        break;
		    }
	    }

        L1=H;
        while(L1->next != NULL)
        {
            
            crash_flag = 0;
            move_flag = 0;
            ai_move_flag =0;
            
            //自机控制
            if(L1->attr == '4')
            {
                if(ans == 8) 
                {
                    L1->axis_y += -1;
                    L1->direct = 'd';
                    move_flag = 1;
                }
                if(ans == 4) 
                {
                    L1->axis_x += 1;
                    L1->direct = 's';
                    move_flag = 1;
                }
                if(ans == 0) 
                {
                    L1->axis_y += 1;
                    L1->direct = 'a';
                    move_flag = 1;
                }
                if(ans == 5) 
                {
                    L1->axis_x += -1;
                    L1->direct = 'w';
                    move_flag = 1;
                }


                //自机发射
                if((ans == 7) && (shoot_count == 30))
                {
                    shoot_count = 0;
                    T = (struct object*)malloc(sizeof(struct object));
                    T->next = NULL; 
                    T->attr = '6';
                    T->direct = L1->direct;
                    T->next = H->next;
                    H->next = T;
                    if(T->direct == 'd' && L1->axis_y > 16)
                    {
                        T->axis_x = L1->axis_x;
                        T->axis_y = L1->axis_y - 16;
                    }
                    if(T->direct == 's' && L1->axis_x < 240-16)
                    {
                        T->axis_x = L1->axis_x + 16;
                        T->axis_y = L1->axis_y;
                    }
                    if(T->direct == 'a' && L1->axis_y < 320-16)
                    {
                        T->axis_x = L1->axis_x;
                        T->axis_y = L1->axis_y + 16;
                    }
                    if(T->direct == 'w' && L1->axis_x > 16)
                    {
                        T->axis_x = L1->axis_x - 16;
                        T->axis_y = L1->axis_y; 
                    }
                }
            }

            //子弹移动
            if(L1->attr == '6')
            {
                if(L1->direct == 'd') 
                {
                    L1->axis_y += -2;
                }
                if(L1->direct == 's') 
                {
                    L1->axis_x += 2;
                }
                if(L1->direct == 'a') 
                {
                    L1->axis_y += 2;
                }
                if(L1->direct = 'w') 
                {
                    L1->axis_x += -2;
                }
            }
            
            //敌机AI
            if(L1->attr == '5')
            {
                //ai扫描自机并开火
                L2 = H;
                while(L2->next != NULL)
                {
                    if((L2->attr == '4') && (ai_shoot_count == 60))
                    {
                        if((abs(L1->axis_x - L2->axis_x)<16) || (abs(L1->axis_y - L2->axis_y)<16))             //开火逻辑待修改
                        {
                            ai_shoot_count = 0;
                            T = (struct object*)malloc(sizeof(struct object));
                            T->next = NULL; 
                            T->attr = '6';
                            T->direct = L1->direct;
                            T->next = H->next;
                            H->next = T;
                            if(T->direct == 'd' && L1->axis_y > 16)
                            {
                                T->axis_x = L1->axis_x;
                                T->axis_y = L1->axis_y - 16;
                            }
                            if(T->direct == 's' && L1->axis_x < 240-16)
                            {
                                T->axis_x = L1->axis_x + 16;
                                T->axis_y = L1->axis_y;
                            }
                            if(T->direct == 'a' && L1->axis_y < 320-16)
                            {
                                T->axis_x = L1->axis_x;
                                T->axis_y = L1->axis_y + 16;
                            }
                            if(T->direct == 'w' && L1->axis_x > 16)
                            {
                                T->axis_x = L1->axis_x - 16;
                                T->axis_y = L1->axis_y; 
                            }
                        }
                    }
                    L2B = L2;
                    L2 = L2->next;
                }

                //ai移动
                if(ai_shoot_count >= 30)
                {
                    ai_move_flag = 1;
                    if((L1->axis_y == 60+20*2) && (L1->axis_x < 240-16-20*2))
                    {
                        L1->axis_x += 1;
                        L1->direct = 's';
                    }
                    else if((L1->axis_y < 320-20*2-16) && (L1->axis_x == 240-16-20*2))
                    {
                        L1->axis_y += 1;
                        L1->direct = 'a';
                    }
                    else if((L1->axis_y == 320-20*2-16) && (L1->axis_x > 20*2))
                    {
                        L1->axis_x += -1;
                        L1->direct = 'w';
                    }
                    else if((L1->axis_x == 20*2) && (L1->axis_y > 60+20*2))
                    {
                        L1->axis_y += -1;
                        L1->direct = 'd';
                    }

                }
            }
            
            L2 = H;
            //碰撞判定
            while(L2->next != NULL)
            {
                //自机碰撞处理
                if(L1->attr == '4' && move_flag == 1)
                {
                    if(L2->attr == '1' || L2->attr == '2' || L2->attr == '5')
                    {
                    
                        
                        if(L1->direct == 'd' && L2->axis_y - L1->axis_y < 16) 
                        {
                            L1->axis_y += 1;
                            move_flag = 0;
                        }
                        if(L1->direct == 's' && L2->axis_x - L1->axis_x < 16) 
                        {
                            L1->axis_x += -1;
                            move_flag = 0;
                        }
                        if(L1->direct == 'a' && L1->axis_y - L2->axis_y < 20) 
                        {
                            L1->axis_y += -1;
                            move_flag = 0;
                        }
                        if(L1->direct = 'w' && L1->axis_x - L2->axis_x < 20) 
                        {
                            L1->axis_x += 1;
                            move_flag = 0;
                        }
                    }    
                }

                //子弹碰撞处理
                if(L1->attr == '6')
                {
                    //击中墙
                    if(L2->attr == '1')
                    {
                        if(L1->direct == 'd' && L2->axis_y - L1->axis_y < 16) 
                        {
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                        if(L1->direct == 's' && L2->axis_x - L1->axis_x < 16) 
                        {
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                        if(L1->direct == 'a' && L1->axis_y - L2->axis_y < 20) 
                        {
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                        if(L1->direct = 'w' && L1->axis_x - L2->axis_x < 20) 
                        {
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                    }

                    //击中木箱
                    if(L2->attr == '2')
                    {
                        if(L1->direct == 'd' && L2->axis_y - L1->axis_y < 16) 
                        {
                            L2B->next = L2->next;
                            free(L2);
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                        if(L1->direct == 's' && L2->axis_x - L1->axis_x < 16) 
                        {
                            L2B->next = L2->next;
                            free(L2);
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                        if(L1->direct == 'a' && L1->axis_y - L2->axis_y < 20) 
                        {
                            L2B->next = L2->next;
                            free(L2);
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                        if(L1->direct = 'w' && L1->axis_x - L2->axis_x < 20) 
                        {
                            L2B->next = L2->next;
                            free(L2);
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                    }        
                
                    //击中敌机
                    if(L2->attr == '5')
                    {
                        if(L1->direct == 'd' && L2->axis_y - L1->axis_y < 16) 
                        {
                            score += 1;
                            L2B->next = L2->next;
                            free(L2);
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                        if(L1->direct == 's' && L2->axis_x - L1->axis_x < 16) 
                        {
                            score += 1;
                            L2B->next = L2->next;
                            free(L2);
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                        if(L1->direct == 'a' && L1->axis_y - L2->axis_y < 20) 
                         {
                            score += 1;
                            L2B->next = L2->next;
                            free(L2);
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                        if(L1->direct = 'w' && L1->axis_x - L2->axis_x < 20) 
                        {
                            score += 1;
                            L2B->next = L2->next;
                            free(L2);
                            L1B->next = L1->next;
                            free(L1);
                            break;
                        }
                    }       

                    //击中自机
                    if(L2->attr == '4')
                    {
                        if(L1->direct == 'd' && L2->axis_y - L1->axis_y < 16) 
                        {
                            GAME_OVER();
                        }
                        if(L1->direct == 's' && L2->axis_x - L1->axis_x < 16) 
                        {
                            GAME_OVER();
                        }
                        if(L1->direct == 'a' && L1->axis_y - L2->axis_y < 20) 
                         {
                            GAME_OVER();
                        }
                        if(L1->direct = 'w' && L1->axis_x - L2->axis_x < 20) 
                        {
                            GAME_OVER();
                        }
                    }
                
                }

                //敌机碰撞处理
                if(L1->attr == '5' && ai_move_flag == 1)
                {
                    if(L2->attr == '1' || L2->attr == '2' || L2->attr == '5')
                    {
                    
                        
                        if(L1->direct == 'd' && L2->axis_y - L1->axis_y < 16) 
                        {
                            L1->axis_y += 1;
                            ai_move_flag = 0;
                        }
                        if(L1->direct == 's' && L2->axis_x - L1->axis_x < 16) 
                        {
                            L1->axis_x += -1;
                            ai_move_flag = 0;
                        }
                        if(L1->direct == 'a' && L1->axis_y - L2->axis_y < 20) 
                        {
                            L1->axis_y += -1;
                            ai_move_flag = 0;
                        }
                        if(L1->direct = 'w' && L1->axis_x - L2->axis_x < 20) 
                        {
                            L1->axis_x += 1;
                            ai_move_flag = 0;
                        }
                    }    
                }
                
                
                
                L2B = L2;
                L2 = L2->next;
            }

            

            

            
            L1B = L1;
            L1=L1->next;
        }
    //fps显示
    fps_count_game += 1;
    if(fps_count == 30)
    {
        dispfps(fps_count_game);
        fps_count_game = 0;
    }
    }
    
}
