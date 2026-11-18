/**
 * @file application.c
 * @author Viacheslav (viacheslav@mcublog.ru)
 * @brief hwtest: логи через SDI printf (аналог RTT для WCH-LinkE)
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
#include "utils/delay.h"
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
#define TICK_PERIOD_MS (500U)
//<<----------------------

/**
 * @brief Точка входа приложения (вызывается из board/main.c)
 *
 * SDI printf уже включён в board_init() (SDI_PR_OPEN), поэтому все
 * LOG_* уходят через отладочный интерфейс WCH-LinkE, а не в USART1.
 */
void application(void)
{
    bool led = false;
    uint32_t counter = 0;

    LOG_INFO("hwtest_sdi_printf: fw %s", FW_VERSION);
    LOG_INFO("SDI printf: WCH-LinkE, USART1 disabled");

    while (1)
    {
        delay_ms(TICK_PERIOD_MS);
        led = !led;
        io_gpio_led(led);
        LOG_INFO("sdi tick: %u, led: %s", (unsigned)counter,
                 led ? "on" : "off");
        counter++;
    }
}
