/**
 * @file delay.c
 * @author Viacheslav (viacheslav@mcublog.ru)
 * @brief Реализация delay_ms() на WCH Delay_Ms
 * @version 0.1
 * @date 2026-11-18
 *
 * @copyright Viacheslav mcublog (c) 2026
 *
 */
#include "utils/delay.h"

#include "debug.h"
//>>---------------------- Log control
#define LOG_MODULE_NAME delay
#if defined(NDEBUG)
#define LOG_MODULE_LEVEL (0)
#else
#define LOG_MODULE_LEVEL (3)
#endif
#include "log_libs.h"
//<<----------------------

//>>---------------------- Public
/**
 * @brief Задержка, мс (Delay_Init() вызывается в board_init())
 *
 * @param ms
 */
void delay_ms(uint32_t ms)
{
    Delay_Ms(ms);
}
//<<----------------------
