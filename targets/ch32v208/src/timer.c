/**
 * @file timer.c
 * @author Viacheslav (viacheslav@mcublog.ru)
 * @brief Периодический тик на SysTick CH32V208
 * @version 0.1
 * @date 2026-11-18
 *
 * @copyright Viacheslav mcublog (c) 2026
 *
 */
#include "utils/timer.h"

#include "board.h"
#include "ch32v20x_conf.h"
//>>---------------------- Log control
#define LOG_MODULE_NAME timer
#if defined(NDEBUG)
#define LOG_MODULE_LEVEL (0)
#else
#define LOG_MODULE_LEVEL (3)
#endif
#include "log_libs.h"
//<<----------------------

/*
 * SysTick в CH32V20x - не стандартный RISC-V mtime, а собственный модуль:
 *   0xE000F000 CTLR, +0x4 SR, +0x8 CNT (64 бит), +0x10 CMP (64 бит)
 * Конфигурация как в EVT/EXAM/SYSTICK: CTLR = 0xF (enable|irq|HCLK|reload),
 * счёт вверх от 0 до CMP, сброс по сравнению.
 */

//>>---------------------- Local variables
static timer_systick_callback_t s_systick_callback = 0;
//<<----------------------

//>>---------------------- Public
/**
 * @brief Сохранить колбэк SysTick
 *
 * @param systick_callback
 */
void timer_init(timer_systick_callback_t systick_callback)
{
    s_systick_callback = systick_callback;
}

/**
 * @brief Запустить SysTick с периодом BOARD_SYSTICK_PERIOD_MS
 *
 */
void timer_irq_enable(void)
{
    SysTick->SR = 0;
    SysTick->CNT = 0;
    SysTick->CMP = (SystemCoreClock / (1000U / BOARD_SYSTICK_PERIOD_MS)) - 1U;
    SysTick->CTLR = 0x0F;

    NVIC_SetPriority(SysTicK_IRQn, 1);
    NVIC_EnableIRQ(SysTicK_IRQn);
}

/**
 * @brief Остановить SysTick
 *
 */
void timer_irq_disable(void)
{
    NVIC_DisableIRQ(SysTicK_IRQn);
    SysTick->CTLR = 0;
    SysTick->SR = 0;
}

/**
 * @brief Вызывается из SysTick_Handler (ch32v20x_it.c)
 *
 */
void timer_systick_irq_handler(void)
{
    SysTick->SR = 0;
    if (s_systick_callback != 0)
    {
        s_systick_callback();
    }
}
//<<----------------------
