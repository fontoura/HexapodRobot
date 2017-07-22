/*
 * LegNumber.h
 *
 *  Created on: 16/09/2013
 */

#ifndef DRIVERS_LEGNUMBER_H_
#define DRIVERS_LEGNUMBER_H_

namespace drivers
{
	/**
	 * Constantes inteiras referentes aos números das patas.
	 */
	enum LegNumber
	{
		/**
		 * Pata dianteira da direita.
		 */
		RightFrontLeg = 0,

		/**
		 * Pata central da direita.
		 */
		RightMiddleLeg = 1,

		/**
		 * Para traseira da direita.
		 */
		RightBackLeg = 2,

		/**
		 * Pata traseira da esquerda.
		 */
		LeftBackLeg = 3,

		/**
		 * Pata central da esquerda.
		 */
		LeftMiddleLeg = 4,

		/**
		 * Pata dianteira da esquerda.
		 */
		LeftFrontLeg = 5,
	};
}

#endif /* DRIVERS_LEGNUMBER_H_ */
