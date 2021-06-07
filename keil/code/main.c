#include <stdint.h>
#include <stdio.h>
#include <math.h>

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
    T->axis_x = 3*16;
    T->axis_y = 16;
    T->attr = '5';
    T->direct = 's';
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
    H->axis_x = 8*16;
    H->axis_y = 13*16;

    GAME_CREAT_TANK();

    for(i=0;i<=14;i++)
    {
        T = (struct object*)malloc(sizeof(struct object));
        T->next = NULL;
        T->axis_x = 0;
        T->axis_y = i*16;
        T->attr = '1';
        T->direct = 'w';
        T->next = H->next;
        H->next = T;
    }
    for(i=0;i<=14;i++)
    {
        T = (struct object*)malloc(sizeof(struct object));
        T->next = NULL;
        T->axis_x = i*16;
        T->axis_y = 0;
        T->attr = '1';
        T->direct = 'w';
        T->next = H->next;
        H->next = T;
    }
    for(i=0;i<=14;i++)
    {
        T = (struct object*)malloc(sizeof(struct object));
        T->next = NULL;
        T->axis_x = i*16;
        T->axis_y = 224;
        T->attr = '1';
        T->direct = 'w';
        T->next = H->next;
        H->next = T;
    }
    for(i=0;i<=14;i++)
    {
        T = (struct object*)malloc(sizeof(struct object));
        T->next = NULL;
        T->axis_x = 224;
        T->axis_y = i*16;
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


	
    while(1)
    {
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
                if(ans == 0) 
                {
                    L1->axis_x += 1;
                    L1->direct = 'd';
                    move_flag = 1;
                }
                if(ans == 1) 
                {
                    L1->axis_y += 1;
                    L1->direct = 's';
                    move_flag = 1;
                }
                if(ans == 2) 
                {
                    L1->axis_x += -1;
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
                    if(T->direct == 'd')
                    {
                        T->axis_x = L1->axis_x + 16;
                        T->axis_y = L1->axis_y;
                    }
                    if(T->direct == 's')
                    {
                        T->axis_x = L1->axis_x;
                        T->axis_y = L1->axis_y + 16;
                    }
                    if(T->direct == 'a')
                    {
                        T->axis_x = L1->axis_x - 16;
                        T->axis_y = L1->axis_y;
                    }
                    if(T->direct == 'w')
                    {
                        T->axis_x = L1->axis_x;
                        T->axis_y = L1->axis_y - 16;
                    }
                }
            }

            //子弹移动
            if(L1->attr == '6')
            {
                if(L1->direct == 'd') 
                {
                    L1->axis_x += 2;
                }
                if(L1->direct == 's') 
                {
                    L1->axis_y += 2;
                }
                if(L1->direct == 'a') 
                {
                    L1->axis_x += -2;
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
                        if((abs(L1->axis_x-L2->axis_x)<14) || (abs(L1->axis_y-L2->axis_y)<14))
                        {
                            ai_shoot_count = 0;
                            T = (struct object*)malloc(sizeof(struct object));
                            T->next = NULL; 
                            T->attr = '6';
                            T->direct = L1->direct;
                            T->next = H->next;
                            H->next = T;
                            if(T->direct == 'd')
                            {
                                T->axis_x = L1->axis_x + 16;
                                T->axis_y = L1->axis_y;
                            }
                            if(T->direct == 's')
                            {
                                T->axis_x = L1->axis_x;
                                T->axis_y = L1->axis_y + 16;
                            }
                            if(T->direct == 'a')
                            {
                                T->axis_x = L1->axis_x - 16;
                                T->axis_y = L1->axis_y;
                            }
                            if(T->direct == 'w')
                            {
                                T->axis_x = L1->axis_x;
                                T->axis_y = L1->axis_y - 16;
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
                    if((L1->axis_x == 3*16) && (L1->axis_y < 11*16))
                    {
                        L1->axis_y += 1;
                        L1->direct = 's';
                    }
                    elseif((L1->axis_x < 11*16) && (L1->axis_y == 11*16))
                    {
                        L1->axis_x += 1;
                        L1->direct = 'd';
                    }
                    elseif((L1->axis_x == 11*16) && (L1->axis_y >= 3*16))
                    {
                        L1->axis_y += -1;
                        L1->direct = 'w';
                    }
                    elseif((L1->axis_x >= 3*16) && (L1->axis_y == 11*16))
                    {
                        L1->axis_x += -1;
                        L1->direct = 'a';
                    }

                }
            }
            
            L2 = H;
            //碰撞判定
            while(L2->next != NULL)
            {
                if((abs(L1->axis_x-L2->axis_x)<14) && (abs(L1->axis_y-L2->axis_y)<14))
                {
                    crash_flag = 1;
                    break;
                }
                L2B = L2;
                L2 = L2->next;
            }

            //自机碰撞处理
            if(L1->attr == '4' && crash_flag == 1 && move_flag == 1)
            {
                move_flag = 0;
                if(L1->direct == 'd') 
                {
                    L1->axis_x += -1;
                }
                if(L1->direct == 's') 
                {
                    L1->axis_y += -1;
                }
                if(L1->direct == 'a') 
                {
                    L1->axis_x += 1;
                }
                if(L1->direct = 'w') 
                {
                    L1->axis_x += 1;
                }    
            }

            //子弹碰撞处理
            if(L1->attr == '6' && crash_flag == 1)
            {
                
                //自机被击中
                if(L2->attr == '4')
                {
                    GAME_OVER();
                }

                //击中敌机
                if(L2->attr == '5')
                {
                    L2B->next = L2->next;
                    free(L2);
                    L1B->next = L1->next;
                    free(L1);
                    score += 1;
                    break;
                }

                //击中木箱
                if(L2->attr == '2')
                {
                    L2B->next = L2->next;
                    free(L2);
                    L1B->next = L1->next;
                    free(L1);
                    break;
                }

                //击中墙
                if(L2->attr == '1')
                {
                    L1B->next = L1->next;
                    free(L1);
                    break;
                }
                if(L2->attr == '6')
                {
                    L2B->next = L2->next;
                    free(L2);
                    L1B->next = L1->next;
                    free(L1);
                    break;
                }

            }

            //敌机碰撞处理
            if(L1->attr == '5' && crash_flag == 1 && move_flag == 1)
            {
                ai_move_flag = 0;
                if(L1->direct == 'd') 
                {
                    L1->axis_x += -1;
                }
                if(L1->direct == 's') 
                {
                    L1->axis_y += -1;
                }
                if(L1->direct == 'a') 
                {
                    L1->axis_x += 1;
                }
                if(L1->direct = 'w') 
                {
                    L1->axis_x += 1;
                }    
            }
            
            L1B = L1;
            L1=L1->next;
        }

    }
    
}
