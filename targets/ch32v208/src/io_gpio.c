/**
 * @file io_gpio.c
 * @author Viacheslav (viacheslav@mcublog.ru)
 * @brief GPIO-слой CH32V208
 * @version 0.1
 * @date 2026-11-18
 *
 * @copyright Viacheslav mcublog (c) 2026
 *
 */
#include "io/io_gpio.h"

#include "board.h"
#include "ch32v20x_conf.h"
//>>---------------------- Log control
#define LOG_MODULE_NAME io_gpio
#if defined(NDEBUG)
#define LOG_MODULE_LEVEL (0)
#else
#define LOG_MODULE_LEVEL (3)
#endif
#include "log_libs.h"
//<<----------------------

//>>---------------------- Public
/**
 * @brief Управление LED (PA0, см. board.h)
 *
 * @param on
 */
void io_gpio_led(bool on)
{
    GPIO_WriteBit(BOARD_LED_PORT, BOARD_LED_PIN,
                  on ? Bit_SET : Bit_RESET);
}
//<<----------------------
