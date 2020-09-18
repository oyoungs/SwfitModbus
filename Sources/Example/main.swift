import SwiftModbus





let modbus = ModbusTCP(ipAddress: "127.0.0.1", port: 5002)


modbus.byteTimeout = 1
modbus.responseTimeout = 1


do {
  try modbus.set(slave: 1)
  try modbus.connect()

  

  var bits: [UInt8 ] = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1]
  
  print("写线圈状态:", bits)

  try modbus.writeBits(address: 0, bits: bits)

  bits = try modbus.readBits(address: 0, n: 10)

  print("读线圈状态:", bits)

  bits = try modbus.readInputBits(address: 0, n: 10)

  print("读输入状态:", bits)

  var registers: [UInt16] = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

  print("写保持寄存器:", registers)

  try modbus.writeRegisters(address: 0, values: registers)

  registers = try modbus.readRegisters(address: 0, n : 10)

  print("读保持寄存器:", registers)

  registers = try modbus.readInputRegisters(address: 0, n : 10)

  print("读输入寄存器:", registers)
} catch {
  if let e = error as? ModbusError {
      print(e.description)
  }
}



