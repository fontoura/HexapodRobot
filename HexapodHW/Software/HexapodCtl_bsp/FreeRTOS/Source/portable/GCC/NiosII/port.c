/*
    FreeRTOS V7.5.2 - Copyright (C) 2013 Real Time Engineers Ltd.

    VISIT http://www.FreeRTOS.org TO ENSURE YOU ARE USING THE LATEST VERSION.

    ***************************************************************************
     *                                                                       *
     *    FreeRTOS provides completely free yet professionally developed,    *
     *    robust, strictly quality controlled, supported, and cross          *
     *    platform software that has become a de facto standard.             *
     *                                                                       *
     *    Help yourself get started quickly and support the FreeRTOS         *
     *    project by purchasing a FreeRTOS tutorial book, reference          *
     *    manual, or both from: http://www.FreeRTOS.org/Documentation        *
     *                                                                       *
     *    Thank you!                                                         *
     *                                                                       *
    ***************************************************************************

    This file is part of the FreeRTOS distribution.

    FreeRTOS is free software; you can redistribute it and/or modify it under
    the terms of the GNU General Public License (version 2) as published by the
    Free Software Foundation >>!AND MODIFIED BY!<< the FreeRTOS exception.

    >>! NOTE: The modification to the GPL is included to allow you to distribute
    >>! a combined work that includes FreeRTOS without being obliged to provide
    >>! the source code for proprietary components outside of the FreeRTOS
    >>! kernel.

    FreeRTOS is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  Full license text is available from the following
    link: http://www.freertos.org/a00114.html

    1 tab == 4 spaces!

    ***************************************************************************
     *                                                                       *
     *    Having a problem?  Start by reading the FAQ "My application does   *
     *    not run, what could be wrong?"                                     *
     *                                                                       *
     *    http://www.FreeRTOS.org/FAQHelp.html                               *
     *                                                                       *
    ***************************************************************************

    http://www.FreeRTOS.org - Documentation, books, training, latest versions,
    license and Real Time Engineers Ltd. contact details.

    http://www.FreeRTOS.org/plus - A selection of FreeRTOS ecosystem products,
    including FreeRTOS+Trace - an indispensable productivity tool, a DOS
    compatible FAT file system, and our tiny thread aware UDP/IP stack.

    http://www.OpenRTOS.com - Real Time Engineers ltd license FreeRTOS to High
    Integrity Systems to sell under the OpenRTOS brand.  Low cost OpenRTOS
    licenses offer ticketed support, indemnification and middleware.

    http://www.SafeRTOS.com - High Integrity Systems also provide a safety
    engineered and independently SIL3 certified version for use in safety and
    mission critical applications that require provable dependability.

    1 tab == 4 spaces!
*/

/*-----------------------------------------------------------
 * Implementation of functions defined in portable.h for the NIOS2 port.
 *----------------------------------------------------------*/

/* Standard Includes. */
#include <string.h>
#include <errno.h>

/* Altera includes. */
#include "sys/alt_irq.h"
#include "priv/alt_legacy_irq.h"
#include "altera_avalon_timer_regs.h"
#include "priv/alt_irq_table.h"

/* Scheduler includes. */
#include "FreeRTOS.h"
#include "task.h"

/* If required, define SYS_CLK(...) macros as aliases for TIMER_SYS(...) macros */
#ifndef SYS_CLK_BASE
#define SYS_CLK_ALWAYS_RUN TIMER_SYS_ALWAYS_RUN
#define SYS_CLK_BASE TIMER_SYS_BASE
#define SYS_CLK_COUNTER_SIZE TIMER_SYS_COUNTER_SIZE
#define SYS_CLK_FIXED_PERIOD TIMER_SYS_FIXED_PERIOD
#define SYS_CLK_FREQ TIMER_SYS_FREQ
#define SYS_CLK_IRQ TIMER_SYS_IRQ
#define SYS_CLK_IRQ_INTERRUPT_CONTROLLER_ID TIMER_SYS_IRQ_INTERRUPT_CONTROLLER_ID
#define SYS_CLK_LOAD_VALUE TIMER_SYS_LOAD_VALUE
#define SYS_CLK_MULT TIMER_SYS_MULT
#define SYS_CLK_NAME TIMER_SYS_NAME
#define SYS_CLK_PERIOD TIMER_SYS_PERIOD
#define SYS_CLK_PERIOD_UNITS TIMER_SYS_PERIOD_UNITS
#define SYS_CLK_RESET_OUTPUT TIMER_SYS_RESET_OUTPUT
#define SYS_CLK_SNAPSHOT TIMER_SYS_SNAPSHOT
#define SYS_CLK_SPAN TIMER_SYS_SPAN
#define SYS_CLK_TICKS_PER_SEC TIMER_SYS_TICKS_PER_SEC
#define SYS_CLK_TIMEOUT_PULSE_OUTPUT TIMER_SYS_TIMEOUT_PULSE_OUTPUT
#define SYS_CLK_TYPE TIMER_SYS_TYPE
#endif

/* Interrupts are enabled. */
#define portINITIAL_ESTATUS     ( portSTACK_TYPE ) 0x01 

/*-----------------------------------------------------------*/

/* 
 * Setup the timer to generate the tick interrupts.
 */
static void prvSetupTimerInterrupt( void );

/*
 * Call back for the alarm function.
 */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
void vPortSysTickHandler( void * context );
#else
void vPortSysTickHandler( void * context, alt_u32 id );
#endif

/*-----------------------------------------------------------*/

static void prvReadGp( unsigned long *ulValue )
{
	asm( "stw gp, (%0)" :: "r"(ulValue) );
}
/*-----------------------------------------------------------*/

/* 
 * See header file for description. 
 */
portSTACK_TYPE *pxPortInitialiseStack( portSTACK_TYPE *pxTopOfStack, pdTASK_CODE pxCode, void *pvParameters )
{    
portSTACK_TYPE *pxFramePointer = pxTopOfStack - 1;
portSTACK_TYPE xGlobalPointer;

    prvReadGp( &xGlobalPointer ); 

    /* End of stack marker. */
    *pxTopOfStack = 0xdeadbeef;
    pxTopOfStack--;
    
    *pxTopOfStack = ( portSTACK_TYPE ) pxFramePointer; 
    pxTopOfStack--;
    
    *pxTopOfStack = xGlobalPointer; 
    
    /* Space for R23 to R16. */
    pxTopOfStack -= 9;

    *pxTopOfStack = ( portSTACK_TYPE ) pxCode; 
    pxTopOfStack--;

    *pxTopOfStack = portINITIAL_ESTATUS; 

    /* Space for R15 to R5. */    
    pxTopOfStack -= 12;
    
    *pxTopOfStack = ( portSTACK_TYPE ) pvParameters; 

    /* Space for R3 to R1, muldiv and RA. */
    pxTopOfStack -= 5;
    
    return pxTopOfStack;
}
/*-----------------------------------------------------------*/

/* 
 * See header file for description. 
 */
portBASE_TYPE xPortStartScheduler( void )
{
	/* Start the timer that generates the tick ISR.  Interrupts are disabled
	here already. */
	prvSetupTimerInterrupt();
	
	/* Start the first task. */
    asm volatile (  " movia r2, restore_sp_from_pxCurrentTCB        \n"
                    " jmp r2                                          " );

	/* Should not get here! */
	return 0;
}
/*-----------------------------------------------------------*/

void vPortEndScheduler( void )
{
	/* It is unlikely that the NIOS2 port will require this function as there
	is nothing to return to.  */
}
/*-----------------------------------------------------------*/

/*
 * Setup the systick timer to generate the tick interrupts at the required
 * frequency.
 */
void prvSetupTimerInterrupt( void )
{
	/* Try to register the interrupt handler. */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
	if ( -EINVAL ==     alt_ic_isr_register(SYS_CLK_IRQ_INTERRUPT_CONTROLLER_ID, SYS_CLK_IRQ,
			vPortSysTickHandler, 0x0, 0x0) )
#else
	if ( -EINVAL == alt_irq_register( SYS_CLK_IRQ, 0x0, vPortSysTickHandler ) )
#endif
	{ 
		/* Failed to install the Interrupt Handler. */
		asm( "break" );
	}
	else
	{
		/* Configure SysTick to interrupt at the requested rate. */
		IOWR_ALTERA_AVALON_TIMER_CONTROL( SYS_CLK_BASE, ALTERA_AVALON_TIMER_CONTROL_STOP_MSK );
		IOWR_ALTERA_AVALON_TIMER_PERIODL( SYS_CLK_BASE, ( configCPU_CLOCK_HZ / configTICK_RATE_HZ ) & 0xFFFF );
		IOWR_ALTERA_AVALON_TIMER_PERIODH( SYS_CLK_BASE, ( configCPU_CLOCK_HZ / configTICK_RATE_HZ ) >> 16 );
		IOWR_ALTERA_AVALON_TIMER_CONTROL( SYS_CLK_BASE, ALTERA_AVALON_TIMER_CONTROL_CONT_MSK | ALTERA_AVALON_TIMER_CONTROL_START_MSK | ALTERA_AVALON_TIMER_CONTROL_ITO_MSK );	
	} 

	/* Clear any already pending interrupts generated by the Timer. */
	IOWR_ALTERA_AVALON_TIMER_STATUS( SYS_CLK_BASE, ~ALTERA_AVALON_TIMER_STATUS_TO_MSK );
}
/*-----------------------------------------------------------*/

#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
void vPortSysTickHandler( void * context )
#else
void vPortSysTickHandler( void * context, alt_u32 id )
#endif
{
	/* Increment the kernel tick. */
	if( xTaskIncrementTick() != pdFALSE )
	{
        vTaskSwitchContext();
	}
		
	/* Clear the interrupt. */
	IOWR_ALTERA_AVALON_TIMER_STATUS( SYS_CLK_BASE, ~ALTERA_AVALON_TIMER_STATUS_TO_MSK );
}
/*-----------------------------------------------------------*/

/** This function is a re-implementation of the Altera provided function.
 * The function is re-implemented to prevent it from enabling an interrupt
 * when it is registered. Interrupts should only be enabled after the FreeRTOS.org
 * kernel has its scheduler started so that contexts are saved and switched 
 * correctly.
 */
#ifndef ALT_ENHANCED_INTERRUPT_API_PRESENT
int alt_irq_register( alt_u32 id, void* context, void (*handler)(void*, alt_u32) )
#else
int alt_irq_register( alt_u32 id, void* context, alt_isr_func handler )
#endif
{
	int rc = -EINVAL;  
	alt_irq_context status;

	if (id < ALT_NIRQ)
	{
		/* 
		 * interrupts are disabled while the handler tables are updated to ensure
		 * that an interrupt doesn't occur while the tables are in an inconsistent
		 * state.
		 */
	
		status = alt_irq_disable_all ();
	
		alt_irq[id].handler = handler;
		alt_irq[id].context = context;
	
		rc = (handler) ? alt_irq_enable (id): alt_irq_disable (id);
	
		/* alt_irq_enable_all(status); This line is removed to prevent the interrupt from being immediately enabled. */
	}
    
	return rc; 
}

/** @Function Description:  This function registers an interrupt handler.
 * If the function is succesful, then the requested interrupt will be enabled
 * upon return. Registering a NULL handler will disable the interrupt.
 *
 * @API Type:              External
 * @param ic_id            Interrupt controller ID
 * @param irq              IRQ ID number
 * @param isr              Pointer to interrupt service routine
 * @param isr_context      Opaque pointer passed to ISR
 * @param flags
 * @return                 0 if successful, else error (-1)
 */
int alt_iic_isr_register(alt_u32 ic_id, alt_u32 irq, alt_isr_func isr,
 void *isr_context, void *flags)
{
 int rc = -EINVAL;
 int id = irq;             /* IRQ interpreted as the interrupt ID. */
 alt_irq_context status;

 if (id < ALT_NIRQ)
 {
   /*
    * interrupts are disabled while the handler tables are updated to ensure
    * that an interrupt doesn't occur while the tables are in an inconsistant
    * state.
    */

   status = alt_irq_disable_all();

   alt_irq[id].handler = isr;
   alt_irq[id].context = isr_context;

   rc = (isr) ? alt_ic_irq_enable(ic_id, id) : alt_ic_irq_disable(ic_id, id);

 //  alt_irq_enable_all(status);
 }

 return rc;
}

/*-----------------------------------------------------------*/

