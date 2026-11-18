/**
 * @file ch32v20x_it.c
 * @author Viacheslav (viacheslav@mcublog.ru)
 * @brief Обработчики исключений/прерываний CH32V208
 * @version 0.1
 * @date 2026-11-18
 *
 * @copyright Viacheslav mcublog (c) 2026
 *
 */
#include "ch32v20x_it.h"

void NMI_Handler(void) __attribute__((interrupt("WCH-Interrupt-fast")));
void HardFault_Handler(void) __attribute__((interrupt("WCH-Interrupt-fast")));
void SysTick_Handler(void) __attribute__((interrupt("WCH-Interrupt-fast")));

/**
 * @brief NMI
 *
 */
void NMI_Handler(void)
{
    while (1)
    {
    }
}

/**
 * @brief Hard Fault: останавливаемся, чтобы поймать отладчиком
 *
 */
void HardFault_Handler(void)
{
    while (1)
    {
    }
}

/**
 * @brief SysTick (1 мс, см. src/timer.c)
 *
 */
void SysTick_Handler(void)
{
    timer_systick_irq_handler();
}
