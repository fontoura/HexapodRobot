/*
 * MovementOperation.h
 *
 *  Created on: 28/03/2013
 */

#ifndef BOT_FIRMWARE_MOVEMENTOPERATION_H_
#define BOT_FIRMWARE_MOVEMENTOPERATION_H_

#include "../../globaldefs.h"
#include "../../base.h"
#include "../../concurrent.managed.h"
#include "../../bot/firmware/LegPositions.h"

namespace bot
{
	namespace firmware
	{
		class MovementManager;

		/**
		 * Classe abstrata definindo uma operação de movimentação.
		 */
		class MovementOperation :
				public virtual base::Object
		{
			private:
				int m_label;

			public:
				/* destrutor virtual para permitir herança. */
				virtual ~MovementOperation();

				/* getter e setter da label do movimento. */
				int getLabel();
				void setLabel(int value);

				/* obtém o tamanho da operação. */
				virtual int getLength() = 0;

				/* retorna o valor atual da operação. */
				virtual int getValue() = 0;

				/* executa a operação de movimentação. */
				virtual void run(int id, LegPositions& position, _strong(MovementManager)& manager) = 0;
		};
	}
}


#endif /* BOT_FIRMWARE_MOVEMENTOPERATION_H_ */
