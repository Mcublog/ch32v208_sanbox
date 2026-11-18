/**
 * @file application.c
 * @author Viacheslav (viacheslav@mcublog.ru)
 * @brief hwtest: мигание LED + периодический лог (USART1)
 * @version 0.1
 * @date 2026-11-18
 *
 * @copyright Viacheslav mcublog (c) 2026
 *
 */
#include <stdint.h>

#include "application.h"
#include "board.h"
#include "io/io_gpio.h"
#include "utils/timer.h"
#include "version.h"
//>>---------------------- Log control
#define LOG_MODULE_NAME app
#if defined(NDEBUG)
#define LOG_MODULE_LEVEL (0)
#else
#define LOG_MODULE_LEVEL (3)
#endif
#include "log_libs.h"
//<<----------------------

//>>---------------------- Local
#define LED_PERIOD_MS (500U)

static volatile uint32_t s_uptime_ms = 0;

static void systick_handler(void)
{
    s_uptime_ms++;
}
//<<----------------------

/**
 * @brief Точка входа приложения (вызывается из board/main.c)
 *
 */
void application(void)
{
    bool led = false;
    uint32_t next_toggle_ms = 0;

    LOG_INFO("hwtest_gpio_toggle: fw %s, LED PA0, SysTick %u ms",
             FW_VERSION, (unsigned)BOARD_SYSTICK_PERIOD_MS);

    timer_init(systick_handler);
    timer_irq_enable();

    while (1)
    {
        const uint32_t now = s_uptime_ms;
        if ((uint32_t)(now - next_toggle_ms) >= LED_PERIOD_MS)
        {
            next_toggle_ms = now;
            led = !led;
            io_gpio_led(led);
            LOG_INFO("led: %s, uptime: %u ms", led ? "on" : "off",
                     (unsigned)now);
        }
    }
}
