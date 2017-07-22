/*
 * fw_defines.h
 *
 *  Created on: 22/03/2013
 */

#ifndef BOT_FIRMWARE_FW_DEFINES_H_
#define BOT_FIRMWARE_FW_DEFINES_H_

// macros para debug.
#define DEBUG_bot_firmware_fw_main
//#define DEBUG_bot_firmware_MovementManager
#define DEBUG_bot_firmware_SensorsManager
//#define DEBUG_bot_firmware_RobotManager
//#define DEBUG_bot_firmware_UartManager
//#define DEBUG_bot_firmware_MovementAdjuster
//#define DEBUG_bot_firmware_NotificationSender
#define DEBUG_bot_firmware_movement_AdjustOperation
#define DEBUG_bot_firmware_movement_HaltOperation
#define DEBUG_bot_firmware_movement_WalkOperation
#define DEBUG_bot_firmware_movement_RotateOperation
#define DEBUG_bot_firmware_movement_WalkSidewaysOperation
#define DEBUG_bot_firmware_movement_HulaHoopOperation
#define DEBUG_bot_firmware_movement_PushUpOperation

// TODO pensar melhor como vão ser essas variáveis.
extern int x_base;
extern int y_base;
extern int z_base;

// informações sobre o canal serial.
#define _UART_BAUDRATE 115200
#define _MAGIC_WORD 0x000FF0FF
#define _BYTE_TIMEOUT 4
#define _MINIMAL_TIMEOUT 128

// tipos de movimento.
#define MOVEMENT_WALK 0xACE
#define MOVEMENT_WALKSIDEWAYS 0xC0A
#define MOVEMENT_ROTATE 0xCAB
#define MOVEMENT_LOOKTO 0xB0A
#define MOVEMENT_WALKTO 0xFACA
#define MOVEMENT_HULAHOOP 0xC0CA
#define MOVEMENT_PUSHUP 0xB0DE
#define MOVEMENT_ADJUST 0xBEC0

// tipos de sensor
#define SENSOR_ACCELEROMETER 0xBEBA
#define SENSOR_MAGNETOMETER 0xC0CA

// tipos de mensagens.
#define HANDSHAKE_REQUEST 0x0000
#define HANDSHAKE_REPLY 0x0001
#define CHECKSTATUS_REQUEST 0x0002
#define CHECKSTATUS_REPLY 0x0003
#define HALT_REQUEST 0x0020
#define HALT_REPLY 0x0021
#define SETMOVEMENT_REQUEST 0x0022
#define SETMOVEMENT_REPLY 0x0023
#define MOVE_REQUEST 0x0024
#define MOVE_REPLY 0x0025
#define FETCHSENSOR_REQUEST 0x0040
#define FETCHSENSOR_REPLY 0x0041
#define UNKNOWN_REQUEST 0xFFFF
#define UNKNOWN_REPLY 0xFFFE
#define MOVEMENT_FINISHED_NOTIFICATION_REQUEST 0x0102
#define MOVEMENT_FINISHED_NOTIFICATION_REPLY 0x0103
#define MOVEMENT_ABORTED_NOTIFICATION_REQUEST 0x0104
#define MOVEMENT_ABORTED_NOTIFICATION_REPLY 0x0105

#endif /* BOT_FIRMWARE_FW_DEFINES_H_ */
