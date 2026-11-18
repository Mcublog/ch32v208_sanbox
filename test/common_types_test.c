/**
 * @file app_test.c
 * @author Viacheslav (viacheslav@mcublog.ru)
 * @brief
 * @version 0.1
 * @date 2022-10-27
 *
 * @copyright Viacheslav mcublog (c) 2022
 *
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "common_type.h"
int main(void)
{
    if (strcmp(cm_irq_edge_stringify(APP_GPIO_IRQ_RISING), "APP_GPIO_IRQ_RISING") != 0 ||
        strcmp(cm_irq_edge_stringify(APP_GPIO_IRQ_FALLING), "APP_GPIO_IRQ_FALLING") != 0 ||
        strcmp(cm_stringify_bool(true), "True") != 0 ||
        strcmp(cm_stringify_bool(false), "False") != 0)
    {
        fputs("Stringify error\n", stderr);
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
