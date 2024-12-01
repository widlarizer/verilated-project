// wrapper.h
#ifndef WRAPPER_H
#define WRAPPER_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct VtopWrapper VtopWrapper;

VtopWrapper* Vtop_new();
void Vtop_delete(VtopWrapper* wrapper);
void Vtop_eval(VtopWrapper* wrapper);
void Vtop_set_input(VtopWrapper* wrapper, uint32_t Vtope);
uint32_t Vtop_get_output(VtopWrapper* wrapper);

#ifdef __cplusplus
}
#endif

#endif // WRAPPER_H
