/**
 * @file board.c
 * @author Viacheslav (viacheslav@mcublog.ru)
 * @brief Инициализация платы CH32V208WBU6-EVT-R0
 * @version 0.1
 * @date 2026-11-18
 *
 * @copyright Viacheslav mcublog (c) 2026
 *
 */
#include "board.h"
#include "debug.h"
//>>---------------------- Log control
#define LOG_MODULE_NAME board
#if defined(NDEBUG)
#define LOG_MODULE_LEVEL (0)
#else
#define LOG_MODULE_LEVEL (3)
#endif
#include "log_libs.h"
//<<----------------------

//>>---------------------- Public
/**
 * @brief Базовая инициализация: тактирование, delay, debug UART, LED
 *
 */
void board_init(void)
{
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_1);
    SystemCoreClockUpdate();

    Delay_Init();

    /* Логи: по умолчанию USART1, в hwtest/sdi_printf - SDI printf (WCH-LinkE) */
#if (SDI_PRINT == SDI_PR_OPEN)
    SDI_Printf_Enable();
#else
    USART_Printf_Init(BOARD_DEBUG_BAUDRATE);
#endif

    GPIO_InitTypeDef gpio = {0};
    RCC_APB2PeriphClockCmd(BOARD_LED_RCC, ENABLE);
    gpio.GPIO_Pin = BOARD_LED_PIN;
    gpio.GPIO_Mode = GPIO_Mode_Out_PP;
    gpio.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(BOARD_LED_PORT, &gpio);

    LOG_DEBUG("board init done, SystemCoreClock=%u", (unsigned)SystemCoreClock);
}
//<<----------------------
