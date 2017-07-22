#ifndef UTILS_H
#define UTILS_H

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

float deg_to_rad(float degree);
float rad_to_deg(float rad);
#ifdef __NIOS2__
#include "alt_types.h"
float calculate_altitude(alt_32 pressure);
#endif /* __NIOS2__ */

#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /* UTILS_H */
