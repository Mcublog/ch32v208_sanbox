/**
 * @file cpp_support.c
 * @author Viacheslav (viacheslav@mcublog.ru)
 * @brief Заглушки _init/_fini для линковки с -nostartfiles
 * @version 0.1
 * @date 2026-11-18
 *
 * @copyright Viacheslav mcublog (c) 2026
 *
 */
/*
 * __libc_init_array()/__libc_fini_array() вызывают _init()/_fini(),
 * которые обычно приходят из crti.o. Мы линкуемся с -nostartfiles,
 * поэтому символы объявляем здесь (weak, чтобы можно было переопределить).
 */
void _init(void) __attribute__((weak));
void _fini(void) __attribute__((weak));

void _init(void)
{
}

void _fini(void)
{
}
