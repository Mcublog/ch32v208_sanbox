#ifndef __CH32V20x_IT_H
#define __CH32V20x_IT_H

#include "ch32v20x.h"

#ifdef __cplusplus
extern "C" {
#endif

void NMI_Handler(void);
void HardFault_Handler(void);
void SysTick_Handler(void);

/* Реализация в targets/ch32v208/src/timer.c */
void timer_systick_irq_handler(void);

#ifdef __cplusplus
}
#endif

#endif /* __CH32V20x_IT_H */
