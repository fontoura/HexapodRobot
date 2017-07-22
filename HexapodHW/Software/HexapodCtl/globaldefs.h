/*
 * globaldefs.cpp
 *
 *  Created on: 20/03/2012
 */

#ifndef GLOBALDEFS_H_
#define GLOBALDEFS_H_

#ifndef NULL
#define NULL 0
#endif

#define _POOL_SIZE_FOR_CONTROLBLOCKS 128
#define _POOL_SIZE_FOR_THREADS 12
#define _POOL_SIZE_FOR_SEMAPHORES 20
#define _POOL_SIZE_FOR_JOBQUEUES 6
#define _POOL_SIZE_FOR_STOPTIMERS 8
#define _POOL_SIZE_FOR_SERIALPORTSTREAMS 2
#define _POOL_SIZE_FOR_MESSAGES 32
#define _POOL_SIZE_FOR_CHANNELS 2
#define _POOL_SIZE_FOR_FLOWS 2
#define _POOL_SIZE_FOR_REPLIERS 32

#define POOLSIZE_bot_firmware_movement_HaltOperation 2
#define POOLSIZE_bot_firmware_movement_WalkOperation 6
#define POOLSIZE_bot_firmware_movement_RotateOperation 6
#define POOLSIZE_bot_firmware_movement_WalkSidewaysOperation 6
#define POOLSIZE_bot_firmware_movement_HulaHoopOperation 6
#define POOLSIZE_bot_firmware_movement_PushUpOperation 6
#define POOLSIZE_bot_firmware_movement_PunchOperation 6
#define POOLSIZE_bot_firmware_NotificationSender _POOL_SIZE_FOR_MESSAGES
#define POOLSIZE_bot_firmware_movement_AdjustOperation 2

#define _MAX_MESSAGE_SIZE 256

#ifdef __NIOS2__
#define _POOLS_ENABLED
#define _STACK_SIZE_IN_NIOS2 1024
#endif /* __NIOS2__ */

#endif /* GLOBALDEFS_H_ */
