#include <stdio.h>
#include <limits.h>
#include <float.h>

extern int my_printf(const char *format, ...);

int main(void)
{
    printf("========================================\n");
    printf("     MY_PRINTF: COMPREHENSIVE TESTS\n");
    printf("========================================\n\n");

    // ========== 1. 20 FLOAT С РАЗНЫМИ ЗНАКАМИ ==========
    printf("=== 1. 20 FLOATS WITH DIFFERENT SIGNS ===\n\n");
    
    my_printf("%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n", 
        3.14, -2.71, 1.41, -1.73, 2.718, -3.141, 0.5, -0.25, 100.1, -200.2,
        0.001, -0.001, 12345.67, -9876.54, 0.0001, -0.0001, 9999.99, -8888.88,
        7777.77, -6666.66);
    printf("%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n", 
        3.14, -2.71, 1.41, -1.73, 2.718, -3.141, 0.5, -0.25, 100.1, -200.2,
        0.001, -0.001, 12345.67, -9876.54, 0.0001, -0.0001, 9999.99, -8888.88,
        7777.77, -6666.66);
    printf("\n");

    // ========== 2. 20 FLOAT + 20 ЦЕЛЫХ ПЕРЕМЕШАНЫ ==========
    printf("=== 2. 20 FLOATS + 20 INTS INTERLEAVED ===\n\n");
    
    my_printf(
        "%d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f\n",
        1, 1.1, 2, -2.2, 3, 3.3, 4, -4.4, 5, 5.5, 6, -6.6, 7, 7.7, 8, -8.8, 
        9, 9.9, 10, -10.1, 11, 11.11, 12, -12.12, 13, 13.13, 14, -14.14, 
        15, 15.15, 16, -16.16, 17, 17.17, 18, -18.18, 19, 19.19, 20, -20.20);
    printf(
        "%d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f %d %f\n",
        1, 1.1, 2, -2.2, 3, 3.3, 4, -4.4, 5, 5.5, 6, -6.6, 7, 7.7, 8, -8.8, 
        9, 9.9, 10, -10.1, 11, 11.11, 12, -12.12, 13, 13.13, 14, -14.14, 
        15, 15.15, 16, -16.16, 17, 17.17, 18, -18.18, 19, 19.19, 20, -20.20);
    printf("\n");

    // ========== 3. ВСЕ СПЕЦИФИКАТОРЫ ПЕРЕМЕШАНЫ (20+ аргументов) ==========
    printf("=== 3. ALL SPECIFIERS MIXED (20+ ARGS) ===\n\n");
    
    my_printf(
        "int:%d | hex:%x | oct:%o | bin:%b | char:%c | str:%s | float:%f | "
        "int:%d | hex:%x | oct:%o | bin:%b | char:%c | str:%s | float:%f | "
        "int:%d | hex:%x | oct:%o | bin:%b | char:%c | str:%s | float:%f | "
        "int:%d | ptr:%p\n",
        42, 0xFF, 0777, 0b1010, 'A', "hello", 3.14,
        -42, 0xABC, 0123, 0b1111, 'B', "world", -2.71,
        100, 0xDEAD, 0644, 0b1100, 'C', "test", 1.618,
        999, (void*)0x7FFF);
    printf(
        "int:%d | hex:%x | oct:%o | char:%c | str:%s | float:%f | "
        "int:%d | hex:%x | oct:%o | char:%c | str:%s | float:%f | "
        "int:%d | hex:%x | oct:%o | char:%c | str:%s | float:%f | "
        "int:%d | ptr:%p\n",
        42, 0xFF, 0777, 'A', "hello", 3.14,
        -42, 0xABC, 0123, 'B', "world", -2.71,
        100, 0xDEAD, 0644, 'C', "test", 1.618,
        999, (void*)0x7FFF);
    printf("\n");

    // ========== 4. 8 СТРОК ПО 1000 СИМВОЛОВ В ОДНОМ PRINTF ==========
    printf("=== 4. 8 STRINGS OF 1000 CHARS EACH ===\n\n");
    
    char lines[8][1001];
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 1000; j++) {
            lines[i][j] = 'A' + (i + j) % 26;
        }
        lines[i][1000] = '\0';
    }
    
    printf("--- 8x1000 chars (8000 total) ---\n");
    my_printf("%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n", 
        lines[0], lines[1], lines[2], lines[3], 
        lines[4], lines[5], lines[6], lines[7]);
    printf("[8 strings of 1000 chars each printed above]\n\n");

    // ========== 5. СТРОКА 6000 СИМВОЛОВ ==========
    printf("=== 5. SINGLE STRING OF 6000 CHARS ===\n\n");
    
    char long_str[6001];
    for (int i = 0; i < 6000; i++) {
        long_str[i] = '0' + (i % 10);
    }
    long_str[6000] = '\0';
    
    printf("--- 6000 chars string ---\n");
    my_printf("%s\n", long_str);
    printf("[6000 chars string printed above]\n\n");

    // ========== 6. СТРОКИ + ВСЕ СПЕЦИФИКАТОРЫ ==========
    printf("=== 6. STRINGS + ALL SPECIFIERS ===\n\n");
    
    char str1[2001], str2[2001], str3[2001];
    for (int i = 0; i < 2000; i++) {
        str1[i] = 'A' + (i % 26);
        str2[i] = 'a' + (i % 26);
        str3[i] = '0' + (i % 10);
    }
    str1[2000] = '\0';
    str2[2000] = '\0';
    str3[2000] = '\0';
    
    my_printf(
        "Long string1: %s\nLong string2: %s\nLong string3: %s\n"
        "Numbers: %d %d %d %d %d\n"
        "Hex: %x %x %x\n"
        "Octal: %o %o\n"
        "Binary: %b %b\n"
        "Chars: %c %c %c\n"
        "Floats: %f %f %f\n"
        "Pointer: %p\n",
        str1, str2, str3,
        12345, -6789, 0, INT_MAX, INT_MIN,
        0xDEAD, 0xBEEF, 0xCAFE,
        0644, 0755,
        0b1010, 0b1111,
        'X', 'Y', 'Z',
        3.14159, -2.71828, 1.41421,
        (void*)0x12345678);
    printf(
        "Long string1: %s\nLong string2: %s\nLong string3: %s\n"
        "Numbers: %d %d %d %d %d\n"
        "Hex: %x %x %x\n"
        "Octal: %o %o\n"
        "Chars: %c %c %c\n"
        "Floats: %f %f %f\n"
        "Pointer: %p\n",
        str1, str2, str3,
        12345, -6789, 0, INT_MAX, INT_MIN,
        0xDEAD, 0xBEEF, 0xCAFE,
        0644, 0755,
        'X', 'Y', 'Z',
        3.14159, -2.71828, 1.41421,
        (void*)0x12345678);
    printf("\n");

    // ========== 7. МНОГО АРГУМЕНТОВ (40+ СМЕШАНЫХ) ==========
    printf("=== 7. MANY MIXED ARGUMENTS (40+) ===\n\n");
    
    my_printf(
        "1:%d 2:%f 3:%x 4:%o 5:%b 6:%c 7:%s 8:%f 9:%d 10:%x "
        "11:%o 12:%b 13:%c 14:%s 15:%f 16:%d 17:%x 18:%o 19:%b 20:%c "
        "21:%s 22:%f 23:%d 24:%x 25:%o 26:%b 27:%c 28:%s 29:%f 30:%d "
        "31:%x 32:%o 33:%b 34:%c 35:%s 36:%f 37:%d 38:%x 39:%o 40:%b\n",
        1, 1.1, 0xA, 010, 0b1010, 'A', "one", 2.2, 2, 0xB,
        020, 0b1011, 'B', "two", 3.3, 3, 0xC, 030, 0b1100, 'C',
        "three", 4.4, 4, 0xD, 040, 0b1101, 'D', "four", 5.5, 5,
        0xE, 050, 0b1110, 'E', "five", 6.6, 6, 0xF, 060, 0b1111);
    printf(
        "1:%d 2:%f 3:%x 4:%o 5:%c 6:%s 7:%f 8:%d 9:%x 10:%o "
        "11:%c 12:%s 13:%f 14:%d 15:%x 16:%o 17:%c 18:%s 19:%f 20:%d "
        "21:%x 22:%o 23:%c 24:%s 25:%f 26:%d 27:%x 28:%o 29:%c 30:%s "
        "31:%f 32:%d 33:%x 34:%o 35:%c 36:%s 37:%f 38:%d 39:%x 40:%o\n",
        1, 1.1, 0xA, 010, 'A', "one", 2.2, 2, 0xB, 020,
        'B', "two", 3.3, 3, 0xC, 030, 'C', "three", 4.4, 4,
        0xD, 040, 'D', "four", 5.5, 5, 0xE, 050, 'E', "five",
        6.6, 6, 0xF, 060, 'F', "six", 7.7, 7, 0x10, 070);
    printf("\n");

    // ========== 8. ПРОВЕРКА БУФЕРА: МНОГОКОМПОНЕНТНЫЙ ВЫВОД ==========
    printf("=== 8. BUFFER STRESS TEST ===\n\n");
    
    // Создаём длинную строку и много аргументов
    char huge_str[3001];
    for (int i = 0; i < 3000; i++) {
        huge_str[i] = '#' + (i % 15);
    }
    huge_str[3000] = '\0';
    
    my_printf(
        "START\n"
        "String (3000 chars): %s\n"
        "Floats: %f %f %f %f %f %f %f %f %f %f\n"
        "Ints: %d %d %d %d %d %d %d %d %d %d\n"
        "Hex: %x %x %x %x %x\n"
        "Chars: %c %c %c %c %c\n"
        "END\n",
        huge_str,
        1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.1,
        100, 200, 300, 400, 500, 600, 700, 800, 900, 1000,
        0xA, 0xB, 0xC, 0xD, 0xE,
        '!', '@', '#', '$', '%');
    printf(
        "START\n"
        "String (3000 chars): %s\n"
        "Floats: %f %f %f %f %f %f %f %f %f %f\n"
        "Ints: %d %d %d %d %d %d %d %d %d %d\n"
        "Hex: %x %x %x %x %x\n"
        "Chars: %c %c %c %c %c\n"
        "END\n",
        huge_str,
        1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.1,
        100, 200, 300, 400, 500, 600, 700, 800, 900, 1000,
        0xA, 0xB, 0xC, 0xD, 0xE,
        '!', '@', '#', '$', '%');
    printf("\n");

    printf("========================================\n");
    printf("          ALL TESTS COMPLETE\n");
    printf("========================================\n");
    
    return 0;
}