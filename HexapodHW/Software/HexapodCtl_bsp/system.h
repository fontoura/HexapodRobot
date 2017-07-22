/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'cpu' in SOPC Builder design 'Teste_SOPC'
 * SOPC Builder design path: ../../Teste_SOPC.sopcinfo
 *
 * Generated: Mon Sep 09 03:27:39 BRT 2013
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x4000820
#define ALT_CPU_CPU_FREQ 100000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x0
#define ALT_CPU_CPU_IMPLEMENTATION "tiny"
#define ALT_CPU_DATA_ADDR_WIDTH 0x1b
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x2000020
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 100000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 0
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 0
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x1b
#define ALT_CPU_NAME "cpu"
#define ALT_CPU_RESET_ADDR 0x2000000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x4000820
#define NIOS2_CPU_FREQ 100000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x0
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 0x1b
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x2000020
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 0
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 0
#define NIOS2_ICACHE_LINE_SIZE_LOG2 0
#define NIOS2_ICACHE_SIZE 0
#define NIOS2_INST_ADDR_WIDTH 0x1b
#define NIOS2_RESET_ADDR 0x2000000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_NEW_SDRAM_CONTROLLER
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_SPI
#define __ALTERA_AVALON_TIMER
#define __ALTERA_NIOS2
#define __ALTPLL
#define __FIFOED_AVALON_UART
#define __I2C_OPENCORES
#define __TERASIC_SPI_3WIRE


/*
 * I2C_Master configuration
 *
 */

#define ALT_MODULE_CLASS_I2C_Master i2c_opencores
#define I2C_MASTER_BASE 0x40010c0
#define I2C_MASTER_IRQ 4
#define I2C_MASTER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define I2C_MASTER_NAME "/dev/I2C_Master"
#define I2C_MASTER_SPAN 32
#define I2C_MASTER_TYPE "i2c_opencores"


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "CYCLONEIVE"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x4001180
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart"
#define ALT_STDIN_BASE 0x4001180
#define ALT_STDIN_DEV jtag_uart
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x4001180
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "Teste_SOPC"


/*
 * TERASIC_SPI_3WIRE_0 configuration
 *
 */

#define ALT_MODULE_CLASS_TERASIC_SPI_3WIRE_0 TERASIC_SPI_3WIRE
#define TERASIC_SPI_3WIRE_0_BASE 0x4001000
#define TERASIC_SPI_3WIRE_0_IRQ -1
#define TERASIC_SPI_3WIRE_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TERASIC_SPI_3WIRE_0_NAME "/dev/TERASIC_SPI_3WIRE_0"
#define TERASIC_SPI_3WIRE_0_SPAN 64
#define TERASIC_SPI_3WIRE_0_TYPE "TERASIC_SPI_3WIRE"


/*
 * altpll_sdram configuration
 *
 */

#define ALTPLL_SDRAM_BASE 0x40010f0
#define ALTPLL_SDRAM_IRQ -1
#define ALTPLL_SDRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ALTPLL_SDRAM_NAME "/dev/altpll_sdram"
#define ALTPLL_SDRAM_SPAN 16
#define ALTPLL_SDRAM_TYPE "altpll"
#define ALT_MODULE_CLASS_altpll_sdram altpll


/*
 * hal configuration
 *
 */

#define ALT_MAX_FD 32
#define ALT_SYS_CLK TIMER_SYS
#define ALT_TIMESTAMP_CLK none


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x4001180
#define JTAG_UART_IRQ 0
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 64
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 64
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * pio_bot_endcalc configuration
 *
 */

#define ALT_MODULE_CLASS_pio_bot_endcalc altera_avalon_pio
#define PIO_BOT_ENDCALC_BASE 0x4001130
#define PIO_BOT_ENDCALC_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_BOT_ENDCALC_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_BOT_ENDCALC_CAPTURE 0
#define PIO_BOT_ENDCALC_DATA_WIDTH 1
#define PIO_BOT_ENDCALC_DO_TEST_BENCH_WIRING 0
#define PIO_BOT_ENDCALC_DRIVEN_SIM_VALUE 0x0
#define PIO_BOT_ENDCALC_EDGE_TYPE "NONE"
#define PIO_BOT_ENDCALC_FREQ 100000000u
#define PIO_BOT_ENDCALC_HAS_IN 1
#define PIO_BOT_ENDCALC_HAS_OUT 0
#define PIO_BOT_ENDCALC_HAS_TRI 0
#define PIO_BOT_ENDCALC_IRQ -1
#define PIO_BOT_ENDCALC_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_BOT_ENDCALC_IRQ_TYPE "NONE"
#define PIO_BOT_ENDCALC_NAME "/dev/pio_bot_endcalc"
#define PIO_BOT_ENDCALC_RESET_VALUE 0x0
#define PIO_BOT_ENDCALC_SPAN 16
#define PIO_BOT_ENDCALC_TYPE "altera_avalon_pio"


/*
 * pio_bot_legselect configuration
 *
 */

#define ALT_MODULE_CLASS_pio_bot_legselect altera_avalon_pio
#define PIO_BOT_LEGSELECT_BASE 0x4001150
#define PIO_BOT_LEGSELECT_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_BOT_LEGSELECT_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_BOT_LEGSELECT_CAPTURE 0
#define PIO_BOT_LEGSELECT_DATA_WIDTH 3
#define PIO_BOT_LEGSELECT_DO_TEST_BENCH_WIRING 0
#define PIO_BOT_LEGSELECT_DRIVEN_SIM_VALUE 0x0
#define PIO_BOT_LEGSELECT_EDGE_TYPE "NONE"
#define PIO_BOT_LEGSELECT_FREQ 100000000u
#define PIO_BOT_LEGSELECT_HAS_IN 0
#define PIO_BOT_LEGSELECT_HAS_OUT 1
#define PIO_BOT_LEGSELECT_HAS_TRI 0
#define PIO_BOT_LEGSELECT_IRQ -1
#define PIO_BOT_LEGSELECT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_BOT_LEGSELECT_IRQ_TYPE "NONE"
#define PIO_BOT_LEGSELECT_NAME "/dev/pio_bot_legselect"
#define PIO_BOT_LEGSELECT_RESET_VALUE 0x6
#define PIO_BOT_LEGSELECT_SPAN 16
#define PIO_BOT_LEGSELECT_TYPE "altera_avalon_pio"


/*
 * pio_bot_reset configuration
 *
 */

#define ALT_MODULE_CLASS_pio_bot_reset altera_avalon_pio
#define PIO_BOT_RESET_BASE 0x4001140
#define PIO_BOT_RESET_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_BOT_RESET_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_BOT_RESET_CAPTURE 0
#define PIO_BOT_RESET_DATA_WIDTH 1
#define PIO_BOT_RESET_DO_TEST_BENCH_WIRING 0
#define PIO_BOT_RESET_DRIVEN_SIM_VALUE 0x0
#define PIO_BOT_RESET_EDGE_TYPE "NONE"
#define PIO_BOT_RESET_FREQ 100000000u
#define PIO_BOT_RESET_HAS_IN 0
#define PIO_BOT_RESET_HAS_OUT 1
#define PIO_BOT_RESET_HAS_TRI 0
#define PIO_BOT_RESET_IRQ -1
#define PIO_BOT_RESET_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_BOT_RESET_IRQ_TYPE "NONE"
#define PIO_BOT_RESET_NAME "/dev/pio_bot_reset"
#define PIO_BOT_RESET_RESET_VALUE 0x1
#define PIO_BOT_RESET_SPAN 16
#define PIO_BOT_RESET_TYPE "altera_avalon_pio"


/*
 * pio_bot_updateflag configuration
 *
 */

#define ALT_MODULE_CLASS_pio_bot_updateflag altera_avalon_pio
#define PIO_BOT_UPDATEFLAG_BASE 0x4001160
#define PIO_BOT_UPDATEFLAG_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_BOT_UPDATEFLAG_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_BOT_UPDATEFLAG_CAPTURE 0
#define PIO_BOT_UPDATEFLAG_DATA_WIDTH 1
#define PIO_BOT_UPDATEFLAG_DO_TEST_BENCH_WIRING 0
#define PIO_BOT_UPDATEFLAG_DRIVEN_SIM_VALUE 0x0
#define PIO_BOT_UPDATEFLAG_EDGE_TYPE "NONE"
#define PIO_BOT_UPDATEFLAG_FREQ 100000000u
#define PIO_BOT_UPDATEFLAG_HAS_IN 0
#define PIO_BOT_UPDATEFLAG_HAS_OUT 1
#define PIO_BOT_UPDATEFLAG_HAS_TRI 0
#define PIO_BOT_UPDATEFLAG_IRQ -1
#define PIO_BOT_UPDATEFLAG_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_BOT_UPDATEFLAG_IRQ_TYPE "NONE"
#define PIO_BOT_UPDATEFLAG_NAME "/dev/pio_bot_updateflag"
#define PIO_BOT_UPDATEFLAG_RESET_VALUE 0x0
#define PIO_BOT_UPDATEFLAG_SPAN 16
#define PIO_BOT_UPDATEFLAG_TYPE "altera_avalon_pio"


/*
 * pio_bot_wrcoord configuration
 *
 */

#define ALT_MODULE_CLASS_pio_bot_wrcoord altera_avalon_pio
#define PIO_BOT_WRCOORD_BASE 0x4001170
#define PIO_BOT_WRCOORD_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_BOT_WRCOORD_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_BOT_WRCOORD_CAPTURE 0
#define PIO_BOT_WRCOORD_DATA_WIDTH 1
#define PIO_BOT_WRCOORD_DO_TEST_BENCH_WIRING 0
#define PIO_BOT_WRCOORD_DRIVEN_SIM_VALUE 0x0
#define PIO_BOT_WRCOORD_EDGE_TYPE "NONE"
#define PIO_BOT_WRCOORD_FREQ 100000000u
#define PIO_BOT_WRCOORD_HAS_IN 0
#define PIO_BOT_WRCOORD_HAS_OUT 1
#define PIO_BOT_WRCOORD_HAS_TRI 0
#define PIO_BOT_WRCOORD_IRQ -1
#define PIO_BOT_WRCOORD_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_BOT_WRCOORD_IRQ_TYPE "NONE"
#define PIO_BOT_WRCOORD_NAME "/dev/pio_bot_wrcoord"
#define PIO_BOT_WRCOORD_RESET_VALUE 0x0
#define PIO_BOT_WRCOORD_SPAN 16
#define PIO_BOT_WRCOORD_TYPE "altera_avalon_pio"


/*
 * pio_bot_x configuration
 *
 */

#define ALT_MODULE_CLASS_pio_bot_x altera_avalon_pio
#define PIO_BOT_X_BASE 0x4001100
#define PIO_BOT_X_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_BOT_X_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_BOT_X_CAPTURE 0
#define PIO_BOT_X_DATA_WIDTH 16
#define PIO_BOT_X_DO_TEST_BENCH_WIRING 0
#define PIO_BOT_X_DRIVEN_SIM_VALUE 0x0
#define PIO_BOT_X_EDGE_TYPE "NONE"
#define PIO_BOT_X_FREQ 100000000u
#define PIO_BOT_X_HAS_IN 0
#define PIO_BOT_X_HAS_OUT 1
#define PIO_BOT_X_HAS_TRI 0
#define PIO_BOT_X_IRQ -1
#define PIO_BOT_X_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_BOT_X_IRQ_TYPE "NONE"
#define PIO_BOT_X_NAME "/dev/pio_bot_x"
#define PIO_BOT_X_RESET_VALUE 0x0
#define PIO_BOT_X_SPAN 16
#define PIO_BOT_X_TYPE "altera_avalon_pio"


/*
 * pio_bot_y configuration
 *
 */

#define ALT_MODULE_CLASS_pio_bot_y altera_avalon_pio
#define PIO_BOT_Y_BASE 0x4001110
#define PIO_BOT_Y_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_BOT_Y_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_BOT_Y_CAPTURE 0
#define PIO_BOT_Y_DATA_WIDTH 16
#define PIO_BOT_Y_DO_TEST_BENCH_WIRING 0
#define PIO_BOT_Y_DRIVEN_SIM_VALUE 0x0
#define PIO_BOT_Y_EDGE_TYPE "NONE"
#define PIO_BOT_Y_FREQ 100000000u
#define PIO_BOT_Y_HAS_IN 0
#define PIO_BOT_Y_HAS_OUT 1
#define PIO_BOT_Y_HAS_TRI 0
#define PIO_BOT_Y_IRQ -1
#define PIO_BOT_Y_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_BOT_Y_IRQ_TYPE "NONE"
#define PIO_BOT_Y_NAME "/dev/pio_bot_y"
#define PIO_BOT_Y_RESET_VALUE 0x0
#define PIO_BOT_Y_SPAN 16
#define PIO_BOT_Y_TYPE "altera_avalon_pio"


/*
 * pio_bot_z configuration
 *
 */

#define ALT_MODULE_CLASS_pio_bot_z altera_avalon_pio
#define PIO_BOT_Z_BASE 0x4001120
#define PIO_BOT_Z_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_BOT_Z_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_BOT_Z_CAPTURE 0
#define PIO_BOT_Z_DATA_WIDTH 16
#define PIO_BOT_Z_DO_TEST_BENCH_WIRING 0
#define PIO_BOT_Z_DRIVEN_SIM_VALUE 0x0
#define PIO_BOT_Z_EDGE_TYPE "NONE"
#define PIO_BOT_Z_FREQ 100000000u
#define PIO_BOT_Z_HAS_IN 0
#define PIO_BOT_Z_HAS_OUT 1
#define PIO_BOT_Z_HAS_TRI 0
#define PIO_BOT_Z_IRQ -1
#define PIO_BOT_Z_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_BOT_Z_IRQ_TYPE "NONE"
#define PIO_BOT_Z_NAME "/dev/pio_bot_z"
#define PIO_BOT_Z_RESET_VALUE 0x0
#define PIO_BOT_Z_SPAN 16
#define PIO_BOT_Z_TYPE "altera_avalon_pio"


/*
 * pio_led configuration
 *
 */

#define ALT_MODULE_CLASS_pio_led altera_avalon_pio
#define PIO_LED_BASE 0x40010e0
#define PIO_LED_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_LED_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_LED_CAPTURE 0
#define PIO_LED_DATA_WIDTH 8
#define PIO_LED_DO_TEST_BENCH_WIRING 0
#define PIO_LED_DRIVEN_SIM_VALUE 0x0
#define PIO_LED_EDGE_TYPE "NONE"
#define PIO_LED_FREQ 100000000u
#define PIO_LED_HAS_IN 0
#define PIO_LED_HAS_OUT 1
#define PIO_LED_HAS_TRI 0
#define PIO_LED_IRQ -1
#define PIO_LED_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_LED_IRQ_TYPE "NONE"
#define PIO_LED_NAME "/dev/pio_led"
#define PIO_LED_RESET_VALUE 0x0
#define PIO_LED_SPAN 16
#define PIO_LED_TYPE "altera_avalon_pio"


/*
 * sdram configuration
 *
 */

#define ALT_MODULE_CLASS_sdram altera_avalon_new_sdram_controller
#define SDRAM_BASE 0x2000000
#define SDRAM_CAS_LATENCY 3
#define SDRAM_CONTENTS_INFO ""
#define SDRAM_INIT_NOP_DELAY 0.0
#define SDRAM_INIT_REFRESH_COMMANDS 2
#define SDRAM_IRQ -1
#define SDRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_IS_INITIALIZED 1
#define SDRAM_NAME "/dev/sdram"
#define SDRAM_POWERUP_DELAY 100.0
#define SDRAM_REFRESH_PERIOD 15.625
#define SDRAM_REGISTER_DATA_IN 1
#define SDRAM_SDRAM_ADDR_WIDTH 0x18
#define SDRAM_SDRAM_BANK_WIDTH 2
#define SDRAM_SDRAM_COL_WIDTH 9
#define SDRAM_SDRAM_DATA_WIDTH 16
#define SDRAM_SDRAM_NUM_BANKS 4
#define SDRAM_SDRAM_NUM_CHIPSELECTS 1
#define SDRAM_SDRAM_ROW_WIDTH 13
#define SDRAM_SHARED_DATA 0
#define SDRAM_SIM_MODEL_BASE 0
#define SDRAM_SPAN 33554432
#define SDRAM_STARVATION_INDICATOR 0
#define SDRAM_TRISTATE_BRIDGE_SLAVE ""
#define SDRAM_TYPE "altera_avalon_new_sdram_controller"
#define SDRAM_T_AC 5.5
#define SDRAM_T_MRD 3
#define SDRAM_T_RCD 20.0
#define SDRAM_T_RFC 70.0
#define SDRAM_T_RP 20.0
#define SDRAM_T_WR 14.0


/*
 * spi configuration
 *
 */

#define ALT_MODULE_CLASS_spi altera_avalon_spi
#define SPI_BASE 0x4001080
#define SPI_CLOCKMULT 1
#define SPI_CLOCKPHASE 1
#define SPI_CLOCKPOLARITY 1
#define SPI_CLOCKUNITS "Hz"
#define SPI_DATABITS 8
#define SPI_DATAWIDTH 16
#define SPI_DELAYMULT "1.0E-9"
#define SPI_DELAYUNITS "ns"
#define SPI_EXTRADELAY 1
#define SPI_INSERT_SYNC 0
#define SPI_IRQ 1
#define SPI_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SPI_ISMASTER 1
#define SPI_LSBFIRST 0
#define SPI_NAME "/dev/spi"
#define SPI_NUMSLAVES 1
#define SPI_PREFIX "spi_"
#define SPI_SPAN 32
#define SPI_SYNC_REG_DEPTH 2
#define SPI_TARGETCLOCK 400u
#define SPI_TARGETSSDELAY "500.0"
#define SPI_TYPE "altera_avalon_spi"


/*
 * timer_sys configuration
 *
 */

#define ALT_MODULE_CLASS_timer_sys altera_avalon_timer
#define TIMER_SYS_ALWAYS_RUN 1
#define TIMER_SYS_BASE 0x40010a0
#define TIMER_SYS_COUNTER_SIZE 32
#define TIMER_SYS_FIXED_PERIOD 1
#define TIMER_SYS_FREQ 100000000u
#define TIMER_SYS_IRQ 3
#define TIMER_SYS_IRQ_INTERRUPT_CONTROLLER_ID 0
#define TIMER_SYS_LOAD_VALUE 999999ull
#define TIMER_SYS_MULT 0.0010
#define TIMER_SYS_NAME "/dev/timer_sys"
#define TIMER_SYS_PERIOD 10
#define TIMER_SYS_PERIOD_UNITS "ms"
#define TIMER_SYS_RESET_OUTPUT 0
#define TIMER_SYS_SNAPSHOT 0
#define TIMER_SYS_SPAN 32
#define TIMER_SYS_TICKS_PER_SEC 100u
#define TIMER_SYS_TIMEOUT_PULSE_OUTPUT 0
#define TIMER_SYS_TYPE "altera_avalon_timer"


/*
 * uart configuration
 *
 */

#define ALT_MODULE_CLASS_uart fifoed_avalon_uart
#define UART_ADD_ERROR_BITS 0
#define UART_BASE 0x4001040
#define UART_BAUDRATE 57600
#define UART_DATA_BITS 8
#define UART_FIFO_EXPORT_USED 0
#define UART_FIXED_BAUD 1
#define UART_GAP_VALUE 4
#define UART_HAS_IRQ 1
#define UART_IRQ 5
#define UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define UART_NAME "/dev/uart"
#define UART_PASS_ERROR_BITS 0
#define UART_RX_FIFO_LE 1
#define UART_RX_FIFO_SIZE 32
#define UART_RX_IRQ_THRESHOLD 1
#define UART_SPAN 64
#define UART_STOP_BITS 1
#define UART_TIMEOUT_VALUE 4
#define UART_TIMESTAMP_WIDTH 8
#define UART_TRANSMIT_PIN 0
#define UART_TX_FIFO_LE 1
#define UART_TX_FIFO_SIZE 32
#define UART_TX_IRQ_THRESHOLD 1
#define UART_TYPE "fifoed_avalon_uart"
#define UART_UHW_CTS 0
#define UART_USE_CTS_RTS 0
#define UART_USE_EOP_REGISTER 0
#define UART_USE_EXT_TIMESTAMP 0
#define UART_USE_GAP_DETECTION 0
#define UART_USE_RX_FIFO 1
#define UART_USE_RX_TIMEOUT 0
#define UART_USE_TIMESTAMP 0
#define UART_USE_TX_FIFO 1

#endif /* __SYSTEM_H_ */
