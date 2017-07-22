/*
 * UartManager.h
 *
 *  Created on: 22/03/2013
 */

#ifndef BOT_FIRMWARE_UARTMANAGER_H_
#define BOT_FIRMWARE_UARTMANAGER_H_

#include "../../globaldefs.h"
#include "../../base.h"
#include "../../concurrent.managed.h"
#include "../../protocol/Message.h"
#include "../../protocol/Flow.h"
#include "../../protocol/FlowReplier.h"
#include "../../protocol/MessageRequestCallback.h"
#include "../../protocol/MessageReplyCallback.h"

namespace bot
{
	namespace firmware
	{
		class RobotManager;
		class MovementOperation;

		/**
		 * Classe que gerencia oparações pela UART.
		 */
		class UartManager :
			public protocol::MessageRequestCallback,
			private protocol::MessageReplyCallback
		{
			private:
				/* pool de objetos. */
				friend class base::ObjectPool<UartManager, 1>;
				static base::ObjectPool<UartManager, 1> m_pool;

			protected:
				/* construtor e destrutor. */
				UartManager();
				~UartManager();

				/* gerência de memória. */
				void initialize(_strong(RobotManager)& robot, _strong(protocol::Flow)& flow);
				void finalize();

			public:
				/* factory. */
				static UartManager* create(_strong(RobotManager)& robot, _strong(protocol::Flow)& flow);

			protected:
				/* gerente do robô. */
				_strong(RobotManager) m_robot;

				/* fluxo de dados utilizado para transmitir mensagens. */
				_strong(protocol::Flow) m_flow;

				/* operação seguinte a enviar para o robô. */
				_strong(MovementOperation) m_operation;

				/* flag indicando se operação seguinte é um ajuste. */
				bool m_willAdjust;

				/* identificador do movimento de ajuste. */
				int m_adjustId;

				/* implementação de MessageReplyCallback. */
				void onReply(_strong(protocol::Message)& request, _strong(protocol::Message)& reply, int error);

				/* implementação de MessageReplyCallback. */
				void onMovementFinishedNotifictionReply(_strong(protocol::Message)& request, _strong(protocol::Message)& reply, int error);

				/* implementação de MessageReplyCallback. */
				void onMovementAbortedNotifictionReply(_strong(protocol::Message)& request, _strong(protocol::Message)& reply, int error);

				/* implementação de MessageRequestCallback. */
				void onRequest(_strong(protocol::Message)& request, _strong(protocol::FlowReplier)& replier);

				/* tratamento de mensagem de handshake. */
				void onHandshakeRequest(_strong(protocol::Message)& request, _strong(protocol::FlowReplier)& replier);

				/* tratamento de mensagem de leitura de estado. */
				void onCheckStatusRequest(_strong(protocol::Message)& request, _strong(protocol::FlowReplier)& replier);

				/* tratamento de mensagem de abortar movimento. */
				void onHaltRequest(_strong(protocol::Message)& request, _strong(protocol::FlowReplier)& replier);

				/* tratamento de mensagem de definir movimento. */
				void onSetMovementRequest(_strong(protocol::Message)& request, _strong(protocol::FlowReplier)& replier);

				/* tratamento de mensagem de iniciar movimento. */
				void onMoveRequest(_strong(protocol::Message)& request, _strong(protocol::FlowReplier)& replier);

				/* tratamento de mensagem de ler sensor. */
				void onFetchSensorRequest(_strong(protocol::Message)& request, _strong(protocol::FlowReplier)& replier);

				/* tratamento de mensagem desconhecida. */
				void onUnknownRequest(_strong(protocol::Message)& request, _strong(protocol::FlowReplier)& replier);

				/* envia uma notificação. */
				void sendNotification(_strong(protocol::Message)& notification);
			public:
				/* envia notificação de término normal de movimento. */
				void sendMovementFinishedNotification(_strong(MovementOperation)& operation);

				/* envia notificação de término precoce de movimento. */
				void sendMovementAbortedNotification(_strong(MovementOperation)& operation);

				/* inicia o controle de fluxo. */
				void start();
		};
	}
}


#endif /* BOT_FIRMWARE_UARTMANAGER_H_ */
