#ifndef CMODBUS_VERSION_H
#define CMODBUS_VERSION_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _modbus modbus_t;

const char *CModbus_Version();

void modbus_set_response_timeout_seconds(modbus_t *ctx, double seconds);

double modbus_get_response_timeout_seconds(modbus_t *ctx);

void modbus_set_byte_timeout_seconds(modbus_t *ctx, double seconds);

double modbus_get_byte_timeout_seconds(modbus_t *ctx);

#ifdef __cplusplus
}
#endif

#endif
