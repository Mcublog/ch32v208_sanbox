#ifndef BOARD_H
#define BOARD_H

#include "ch32v20x.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 * CH32V208WBU6-EVT-R0
 *
 * LED1/LED2 и KEY S2 выведены на гребёнку P1 и соединяются с I/O джамперами.
 * По умолчанию (как в официальном примере GPIO_Toggle) LED висит на PA0.
 * См. docs/CH32V20xEvaluationBoardReference.pdf
 */
#define BOARD_LED_RCC       RCC_APB2Periph_GPIOA
#define BOARD_LED_PORT      GPIOA
#define BOARD_LED_PIN       GPIO_Pin_0

/* USART1 (debug/printf), PA9 - TX, PA10 - RX */
#define BOARD_DEBUG_BAUDRATE 115200

/* Тактовая частота: HSE 32 МГц -> SYSCLK 144 МГц (SYSCLK_FREQ_144MHz_HSE) */
#define BOARD_SYSCLK_HZ     144000000U

/* Период SysTick-прерывания, мс (см. src/timer.c) */
#define BOARD_SYSTICK_PERIOD_MS 1U

    void board_init(void);

#ifdef __cplusplus
}
#endif

#endif // BOARD_H
