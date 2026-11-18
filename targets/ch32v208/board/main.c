/**
 * @file main.c
 * @author Viacheslav (viacheslav@mcublog.ru)
 * @brief Точка входа прошивки CH32V208
 * @version 0.1
 * @date 2026-11-18
 *
 * @copyright Viacheslav mcublog (c) 2026
 *
 */
#include "ch32v20x_conf.h"

#include "application.h"
#include "board.h"
#include "debug.h"
#include "version.h"
//>>---------------------- Log control
#define LOG_MODULE_NAME main
#if defined(NDEBUG)
#define LOG_MODULE_LEVEL (0)
#else
#define LOG_MODULE_LEVEL (3)
#endif
#include "log_libs.h"
//<<----------------------

/* Из newlib: выполняет .init_array (нужно для C++ и __attribute__((constructor))) */
void __libc_init_array(void);

//>>---------------------- Global
int main(void)
{
    __libc_init_array();

    board_init();

    LOG_INFO("CH32V208WBU6-EVT-R0, fw %s", FW_VERSION);
    LOG_INFO("SystemClk: %u Hz, ChipID: %08x",
             (unsigned)SystemCoreClock, (unsigned)DBGMCU_GetCHIPID());

    application();

    while (1)
    {
    }
}
//<<----------------------
