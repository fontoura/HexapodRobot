/*
 * defines.h
 *
 *  Created on: 29/10/2012
 *      Author: Felipe Michels Fontoura
 */

#ifndef DEFINES_H_
#define DEFINES_H_

#define new(type) ((type*)malloc(sizeof(type)))
#define new_1d(type,size1) ((type*)malloc((size1)*sizeof(type)))
#define new_2d(type,size1,size2) ((type*)malloc((size1)*(size2)*sizeof(type)))
#define delete(pointer) free((void*)(pointer))

#endif /* DEFINES_H_ */
