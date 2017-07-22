/*
 * UartManager.cpp
 *
 *  Created on: 22/03/2013
 */

#include "./fw_defines.h"
#include "./RobotManager.h"
#include "./UartManager.h"
#include "./SensorsManager.h"
#include "./NotificationSender.h"
#include "./MagnetometerData.h"
#include "./MovementManager.h"
#include "./MovementOperation.h"
#include "./movement/WalkOperation.h"
#include "./movement/WalkSidewaysOperation.h"
#include "./movement/RotateOperation.h"
#include "./movement/HulaHoopOperation.h"
#include "./movement/PushUpOperation.h"
#include "./movement/PunchOperation.h"
#include "../../global.h"

using namespace base;
using namespace global;
using namespace protocol;
using namespace bot::firmware::movement;

#include "string.h"

/* macros para debug */
#ifdef DEBUG_bot_firmware_UartManager
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_UartManager */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_UartManager */

namespace bot
{
	namespace firmware
	{
		_pool_inst(UartManager, 1)

		/* construtor e destrutor. */
		UartManager::UartManager()
		{
			m_willAdjust = false;
			m_adjustId = 0;
			DEBUG("UartManager alocado!");
		}

		UartManager::~UartManager()
		{
			m_robot = NULL;
			m_flow = NULL;
			DEBUG("UartManager apagado!");
		}

		/* gerência de memória. */
		void UartManager::initialize(_strong(RobotManager)& robot, _strong(Flow)& flow)
		{
			DEBUG("Inicializando UartManager...");
			m_robot = robot;
			m_flow = flow;
			m_willAdjust = false;
			m_adjustId = 0;
			_strong(MessageRequestCallback) _this = this;
			flow->setRequestCallback(_this);
		}

		void UartManager::finalize()
		{
			DEBUG("Finalizando UartManager...");
			m_robot = NULL;
			m_flow = NULL;
			_del_inst(UartManager);
		}

		/* factory. */
		UartManager* UartManager::create(_strong(RobotManager)& robot, _strong(Flow)& flow)
		{
			DEBUG("Criando UartManager...");
			_new_inst(UartManager, uartManager);
			uartManager->initialize(robot, flow);
			return uartManager;
		}

		/* implementação de MessageReplyCallback. */
		void UartManager::onReply(_strong(protocol::Message)& request, _strong(protocol::Message)& reply, int error)
		{
			if (request->getType() == MOVEMENT_FINISHED_NOTIFICATION_REPLY)
			{
				this->onMovementFinishedNotifictionReply(request, reply, error);
			}
			else if (request->getType() == MOVEMENT_ABORTED_NOTIFICATION_REPLY)
			{
				this->onMovementAbortedNotifictionReply(request, reply, error);
			}
			else
			{
				if (reply != NULL)
				{
					DEBUG("UartManager recebeu reply indeterminado");
				}
				else
				{
					DEBUG("UartManager nao recebeu reply indeterminado a tempo");
				}
			}
		}

		/* implementação de MessageReplyCallback. */
		void UartManager::onMovementFinishedNotifictionReply(_strong(protocol::Message)& request, _strong(protocol::Message)& reply, int error)
		{
			if (reply != NULL)
			{
				DEBUG("UartManager recebeu reply de notificacao de movimento terminado");
			}
			else
			{
				DEBUG("UartManager nao recebeu reply de notificacao de movimento terminado a tempo");
			}
		}

		/* implementação de MessageReplyCallback. */
		void UartManager::onMovementAbortedNotifictionReply(_strong(protocol::Message)& request, _strong(protocol::Message)& reply, int error)
		{
			if (reply != NULL)
			{
				DEBUG("UartManager recebeu reply de notificacao de movimento abortado");
			}
			else
			{
				DEBUG("UartManager nao recebeu reply de notificacao de movimento abortado a tempo");
			}
		}

		/* implementação de MessageRequestCallback. */
		void UartManager::onRequest(_strong(Message)& request, _strong(FlowReplier)& replier)
		{
			DEBUG("UartManager recebeu request.");
			switch (0xFFFF & request->getType())
			{
				case HANDSHAKE_REQUEST:
					this->onHandshakeRequest(request, replier);
					break;
				case CHECKSTATUS_REQUEST:
					this->onCheckStatusRequest(request, replier);
					break;
				case HALT_REQUEST:
					this->onHaltRequest(request, replier);
					break;
				case SETMOVEMENT_REQUEST:
					this->onSetMovementRequest(request, replier);
					break;
				case MOVE_REQUEST:
					this->onMoveRequest(request, replier);
					break;
				case FETCHSENSOR_REQUEST:
					this->onFetchSensorRequest(request, replier);
					break;
				default:
					this->onUnknownRequest(request, replier);
					break;
			}
		}

		/* tratamento de mensagem de handshake. */
		void UartManager::onHandshakeRequest(_strong(Message)& request, _strong(FlowReplier)& replier)
		{
			DEBUG("UartManager recebeu request de handshake.");
			_strong(Message) reply = Message::create(HANDSHAKE_REPLY, 0);
			m_robot->getMovementManager()->halt();
			replier->sendReply(reply);
			DEBUG("UartManager enviou reply de handshake.");
		}

		/* tratamento de mensagem de leitura de estado. */
		void UartManager::onCheckStatusRequest(_strong(Message)& request, _strong(FlowReplier)& replier)
		{
			DEBUG("UartManager recebeu request de leitura de estado.");
			_strong(Message) reply = Message::create(CHECKSTATUS_REPLY, 1);
			if (m_robot->getMovementManager()->isMoving())
			{
				reply->setByte(0, -1);
			}
			else
			{
				reply->setByte(0, 0);
			}
			replier->sendReply(reply);
			DEBUG("UartManager enviou reply de leitura de estado.");
		}

		/* tratamento de mensagem de abortar movimento. */
		void UartManager::onHaltRequest(_strong(Message)& request, _strong(FlowReplier)& replier)
		{
			DEBUG("UartManager recebeu request de abortar movimento.");
			m_robot->getMovementManager()->halt();
			_strong(Message) reply = Message::create(HALT_REPLY, 0);
			replier->sendReply(reply);
			DEBUG("UartManager enviou reply de abortar movimento.");
		}

		/* tratamento de mensagem de definir movimento. */
		void UartManager::onSetMovementRequest(_strong(Message)& request, _strong(FlowReplier)& replier)
		{
			DEBUG("UartManager recebeu request de definir movimento.");
			bool ok = false;
			if (request->getLength() >= 0x6)
			{
				int label = readLittleEndian32(request->getBuffer(), 0x2);
				switch (readLittleEndian16(request->getBuffer(), 0))
				{
					case MOVEMENT_WALK:
						if (request->getLength() >= 0xa)
						{
							DEBUG3("UartManager recebeu request de definir movimento para andar com ID ", label, ".");
							int distance = readLittleEndian32(request->getBuffer(), 0x6);
							if (distance > 0)
							{
								m_operation = WalkOperation::create(distance, 0, false, false);
							}
							else
							{
								distance = -distance;
								m_operation = WalkOperation::create(distance, 0, false, true);
							}
							ok = true;
							m_willAdjust = false;
						}
						break;
					case MOVEMENT_WALKSIDEWAYS:
						if (request->getLength() >= 0xa)
						{
							DEBUG3("UartManager recebeu request de definir movimento para andar de lado com ID ", label, ".");
							int distance = readLittleEndian32(request->getBuffer(), 0x6);
							if (distance > 0)
							{
								m_operation = WalkSidewaysOperation::create(true, distance);
							}
							else
							{
								distance = -distance;
								m_operation = WalkSidewaysOperation::create(false, distance);
							}
							ok = true;
							m_willAdjust = false;
						}
						break;
					case MOVEMENT_ROTATE:
						if (request->getLength() >= 0xa)
						{
							DEBUG3("UartManager recebeu request de definir movimento para rotacionar com ID ", label, ".");
							int angle = ((int32_t)readLittleEndian32(request->getBuffer(), 0x6)) / 1024;
							bool isClock;
							if (angle < 0) {
								isClock = false;
								angle = -angle;
							} else {
								isClock = true;
							}
							MagnetometerData data;
							m_robot->getSensorsManager()->readMagnetometer(data);
							m_operation = RotateOperation::create(angle, isClock, true, data);
							ok = true;
							m_willAdjust = false;
						}
						break;
					case MOVEMENT_LOOKTO:
						if (request->getLength() >= 0xa)
						{
							int angle = ((int32_t)readLittleEndian32(request->getBuffer(), 0x6)) / 1024;
							DEBUG5("UartManager recebeu request de definir movimento para olha para direcao com ID ", label, " e angulo ", angle, ".");
							if (angle < 0) {
								angle = 360 + angle;
							}
							MagnetometerData data;
							m_robot->getSensorsManager()->readMagnetometer(data);
							m_operation = RotateOperation::create(angle, false, false, data);
							ok = true;
							m_willAdjust = false;
						}
						break;
					case MOVEMENT_WALKTO:
						if (request->getLength() >= 0xe)
						{
							DEBUG3("UartManager recebeu request de definir movimento para andar para direcao com ID ", label, ".");
							int angle = ((int32_t)readLittleEndian32(request->getBuffer(), 0x6)) / 1024;
							int distance = readLittleEndian32(request->getBuffer(), 0xa);
							if (angle < 0) {
								angle = 360 + angle;
							}
							if (distance > 0)
							{
								m_operation = WalkOperation::create(distance, angle, true, false);
							}
							else
							{
								distance = -distance;
								m_operation = WalkOperation::create(distance, angle, true, true);
							}
							ok = true;
							m_willAdjust = false;
						}
						break;
					case MOVEMENT_HULAHOOP:
						if (request->getLength() >= 0xa)
						{
							DEBUG3("UartManager recebeu request de definir movimento para bambolear com ID ", label, ".");
							int cycles = readLittleEndian32(request->getBuffer(), 0x6);
							if (cycles > 0)
							{
								m_operation = HulaHoopOperation::create(cycles);
								ok = true;
								m_willAdjust = false;
							}
						}
						break;
					case MOVEMENT_PUNCH:
						if (request->getLength() >= 0xa)
						{
							DEBUG3("UartManager recebeu request de definir movimento para socar com ID ", label, ".");
							int cycles = readLittleEndian32(request->getBuffer(), 0x6);
							if (cycles > 0)
							{
								m_operation = PunchOperation::create(cycles);
								ok = true;
								m_willAdjust = false;
							}
						}
						break;
					case MOVEMENT_PUSHUP:
						if (request->getLength() >= 0xa)
						{
							DEBUG3("UartManager recebeu request de definir movimento para fazer flexoes com ID ", label, ".");
							int pushUps = readLittleEndian32(request->getBuffer(), 0x6);
							if (pushUps > 0)
							{
								m_operation = PushUpOperation::create(pushUps);
								ok = true;
								m_willAdjust = false;
							}
						}
						break;
					case MOVEMENT_ADJUST:
						if (request->getLength() >= 0x6)
						{
							DEBUG3("UartManager recebeu request de definir movimento para ajustar com ID ", label, ".");
							m_operation = NULL;
							ok = true;
							m_willAdjust = true;
						}
						break;
					default:
						DEBUG3("UartManager recebeu request de definir movimento desconhecido com ID ", label, "!");
						break;
				}
				if (ok)
				{
					if (m_willAdjust)
					{
						m_adjustId = label;
					}
					else
					{
						m_operation->setLabel(label);
					}
				}
			}
			_strong(Message) reply;
			if (ok)
			{
				reply = Message::create(SETMOVEMENT_REPLY, 0);
			}
			else
			{
				reply = Message::create(HALT_REPLY, 0);
			}
			replier->sendReply(reply);
			if (ok)
			{
				DEBUG("UartManager enviou reply de definir movimento.");
			}
			else
			{
				DEBUG("UartManager enviou reply de movimento desconhecido.");
			}
		}

		/* tratamento de mensagem de iniciar movimento */
		void UartManager::onMoveRequest(_strong(Message)& request, _strong(FlowReplier)& replier)
		{
			DEBUG("UartManager recebeu request de iniciar movimento.");
			if (m_willAdjust)
			{
				m_willAdjust = false;
				m_robot->getMovementManager()->adjust(m_adjustId);
			}
			else if (m_operation != NULL)
			{
				m_robot->getMovementManager()->move(m_operation);
				m_operation = NULL;
			}
			_strong(Message) reply = Message::create(MOVE_REPLY, 0);
			replier->sendReply(reply);
			DEBUG("UartManager enviou reply de iniciar movimento.");
		}


		/* tratamento de mensagem de ler sensor. */
		void UartManager::onFetchSensorRequest(_strong(Message)& request, _strong(FlowReplier)& replier)
		{
			DEBUG("UartManager recebeu request de ler sensor.");
			bool ok = false;
			if (request->getLength() >= 2)
			{
				uint16_t sensorId = readLittleEndian16(request->getBuffer(), 0);
				_strong(Message) reply;
				if (sensorId == SENSOR_MAGNETOMETER)
				{
					ok = true;
					_strong(Message) reply = Message::create(FETCHSENSOR_REPLY, 0x08);
					MagnetometerData data;
					m_robot->getSensorsManager()->readMagnetometer(data);
					writeLittleEndian16(reply->getBuffer(), 0x00, data.xyz[0]);
					writeLittleEndian16(reply->getBuffer(), 0x02, data.xyz[1]);
					writeLittleEndian16(reply->getBuffer(), 0x04, data.xyz[2]);
					writeLittleEndian16(reply->getBuffer(), 0x06, (int)(data.heading * 64));
					replier->sendReply(reply);
				}
				if (sensorId == SENSOR_ACCELEROMETER)
				{
					ok = true;
					_strong(Message) reply = Message::create(FETCHSENSOR_REPLY, 0x06);
					AccelerometerData data;
					m_robot->getSensorsManager()->readAccelerometer(data);
					writeLittleEndian16(reply->getBuffer(), 0x00, (int)(data.xyz[0] * 16));
					writeLittleEndian16(reply->getBuffer(), 0x02, (int)(data.xyz[1] * 16));
					writeLittleEndian16(reply->getBuffer(), 0x04, (int)(data.xyz[2] * 16));
					replier->sendReply(reply);
				}
				// TODO adicionar mais sensores.
			}

			if (!ok)
			{
				_strong(Message) reply = Message::create(FETCHSENSOR_REPLY, 0x00);
				replier->sendReply(reply);
			}
		}

		/* tratamento de mensagem desconhecida. */
		void UartManager::onUnknownRequest(_strong(Message)& request, _strong(FlowReplier)& replier)
		{
			DEBUG("UartManager recebeu request desconhecido.");
			_strong(Message) reply = Message::create(UNKNOWN_REPLY, 0);
			replier->sendReply(reply);
		}

		void UartManager::sendNotification(_strong(Message)& notification)
		{
			_strong(MessageReplyCallback) _this = this;
			_strong(NotificationSender) sender = NotificationSender::create(16, m_flow, _this, 100);
			sender->send(notification);
		}

		/* envia notificação de término normal de movimento. */
		void UartManager::sendMovementFinishedNotification(_strong(MovementOperation)& operation)
		{
			DEBUG("UartManager enviando notificacao de movimento terminado");
			_strong(Message) notification = Message::create(MOVEMENT_FINISHED_NOTIFICATION_REQUEST, 0x8);
			writeLittleEndian32(notification->getBuffer(), 0x0, operation->getLabel());
			writeLittleEndian32(notification->getBuffer(), 0x4, operation->getLength());
			this->sendNotification(notification);
		}

		/* envia notificação de término precoce de movimento. */
		void UartManager::sendMovementAbortedNotification(_strong(MovementOperation)& operation)
		{
			DEBUG("UartManager enviando notificacao de movimento abortado");
			_strong(Message) notification = Message::create(MOVEMENT_ABORTED_NOTIFICATION_REQUEST, 0xc);
			writeLittleEndian32(notification->getBuffer(), 0x0, operation->getLabel());
			writeLittleEndian32(notification->getBuffer(), 0x4, operation->getValue());
			writeLittleEndian32(notification->getBuffer(), 0x8, operation->getLength());
			this->sendNotification(notification);
		}

		/* inicia o controle de fluxo. */
		void UartManager::start() {
			m_flow->start();
		}
	}
}
