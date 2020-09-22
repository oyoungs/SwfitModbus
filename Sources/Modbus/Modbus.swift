#if os(macOS) 
import Darwin.C
#else 
import Glibc
#endif

import CModbus


func modbus_get_response_timeout_seconds(_ ctx: OpaquePointer!) -> Double {
    let sec = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
    let usec = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
    guard modbus_get_response_timeout(ctx, sec, usec) > 0 else {
        return 0
    }
    return Double(sec.pointee) + Double(usec.pointee) * 0.000001
}

func modbus_get_byte_timeout_seconds(_ ctx: OpaquePointer!) -> Double {
    let sec = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
    let usec = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
    guard modbus_get_byte_timeout(ctx, sec, usec) > 0 else {
        return 0
    }
    return Double(sec.pointee) + Double(usec.pointee) * 0.000001
}

func modbus_set_response_timeout_seconds(_ ctx: OpaquePointer!, _ timeout: Double) -> Bool {
    let sec = UInt32(Int(timeout))
    let usec = UInt32((timeout - Double(sec)) * 1000000)
    
    guard modbus_set_response_timeout(ctx, sec, usec) > 0 else {
        return false
    }
    
    return true
}


func modbus_set_byte_timeout_seconds(_ ctx: OpaquePointer!, _ timeout: Double) -> Bool {
    let sec = UInt32(Int(timeout))
    let usec = UInt32((timeout - Double(sec)) * 1000000)

    guard modbus_set_byte_timeout(ctx, sec, usec) > 0 else {
        return false
    }
    
    return true
}

public class Version {

    public static var major: UInt32 {
        return libmodbus_version_major
    }

    public static var minor: UInt32 {
        return libmodbus_version_minor
    }

    public static var micro: UInt32 {
        return libmodbus_version_micro
    }

    public static var string: String {
        return LIBMODBUS_VERSION_STRING
    }

}

public enum ModbusError: Error {
  case illegalFunction
  case illegalDataAddress
  case illegalDataValue
  case slaveOrServerFailure
  case acknowledge
  case slaveOrServerBusy
  case negativeAcknowledge
  case memoryParity
  case notDefined
  case gatewayPath
  case gatewayTarget
  case unknown(Int)
}

public enum CommonError: Error {
  case notImplemented
}

extension ModbusError {
  
  public var description: String {
    
    return String(cString: modbus_strerror(errno))
  
  }

  static var fromErrno: ModbusError {
    switch errno {
    case MODBUS_ENOBASE + 1:
      return .illegalFunction
    case MODBUS_ENOBASE + 2:
      return .illegalDataAddress
    case MODBUS_ENOBASE + 3:
      return .illegalDataValue
    case MODBUS_ENOBASE + 4:
      return .slaveOrServerFailure
    case MODBUS_ENOBASE + 5:
      return .acknowledge
    case MODBUS_ENOBASE + 6:
      return .slaveOrServerBusy
    case MODBUS_ENOBASE + 7:
      return .negativeAcknowledge
    case MODBUS_ENOBASE + 8:
      return .memoryParity
    case MODBUS_ENOBASE + 9:
      return .notDefined
    case MODBUS_ENOBASE + 10:
      return .gatewayPath
    case MODBUS_ENOBASE + 11:
      return .gatewayTarget
    default: 
      return .unknown(Int(errno))
    }
  }
}

public enum ModbusErrorRecoveryMode {
    case none
    case link
    case `protocol`

    public var mode: modbus_error_recovery_mode {
        switch self {
        case .none:
            return MODBUS_ERROR_RECOVERY_NONE
        case .link:
            return MODBUS_ERROR_RECOVERY_LINK
        case .protocol:
            return MODBUS_ERROR_RECOVERY_PROTOCOL
        }
      
    }
}

public typealias ModbusMappingHandle = UnsafeMutablePointer<modbus_mapping_t>

public typealias ModbusContext = OpaquePointer

public class ModbusMapping {
    
    public let context: ModbusMappingHandle
    
    public typealias Address = (start: UInt32, count: UInt32)
    
    init(bits: Address, inputBits: Address, registers: Address, inputRegisters: Address) {
        context =  modbus_mapping_new_start_address(
            bits.start, bits.count,
            inputBits.start, inputBits.count,
            registers.start, registers.count,
            inputRegisters.start, inputRegisters.count
        )
    }
    
    init(bits: Int32, inputBits: Int32, registers: Int32, inputRegisters: Int32) {
        context =  modbus_mapping_new(bits, inputBits, registers, inputRegisters )
    }
    
    deinit {
        modbus_mapping_free(context)
    }
    
}


public class Modbus {

    let context: ModbusContext
  
    init(context: ModbusContext) {
        self.context = context
    }

    deinit {
        modbus_free(context)
    }

    public func set(slave: Int32) throws {
        guard  modbus_set_slave(context, slave) == 0 else {
            throw ModbusError.fromErrno
        }
    }

    public func set(errorRecoveryMode mode: ModbusErrorRecoveryMode) throws {
        guard modbus_set_error_recovery(context, mode.mode) == 0 else {
            throw ModbusError.fromErrno
        }
    }

    public var socket: Int32 {
        get {
            return modbus_get_socket(context)
        }

        set {
            modbus_set_socket(context, newValue)
        }
    }

    public var responseTimeout: Double {
        get {
            return modbus_get_response_timeout_seconds(context)

        }
        set {
            _ = modbus_set_response_timeout_seconds(context, newValue)
        }
    }

    public var byteTimeout: Double {
        get {
            return modbus_get_byte_timeout_seconds(context)
        }

        set {
            _ = modbus_set_byte_timeout_seconds(context, newValue)
        }
    }

    public func connect() throws {
        guard modbus_connect(context) == 0 else {
            throw ModbusError.fromErrno
        }
    }

    public func close() {
        modbus_close(context)
    }

    public func flush() throws {
       guard modbus_flush(context) == 0 else {
          throw ModbusError.fromErrno
       }
    }
    
    func sendRawRequest(request: [UInt8]) throws {
        let buffer = request.withUnsafeBufferPointer { $0.baseAddress }
        
        guard modbus_send_raw_request(context, buffer!, Int32(request.count)) >= 0 else {
            throw ModbusError.fromErrno
        }
    }
    
    func receive(count: Int) throws -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: count)
        let bufferPointer = buffer.withUnsafeMutableBufferPointer { $0.baseAddress }
        
        let n = modbus_receive(context, bufferPointer)
        
        guard n >= 0 else {
            throw ModbusError.fromErrno
        }
        
        return count == Int(n) ? buffer: [UInt8](buffer.dropLast(count - Int(n)))
    }
    
    func receive(confirmation count: Int) throws -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: count)
        let bufferPointer = buffer.withUnsafeMutableBufferPointer { $0.baseAddress }
        
        let n = modbus_receive(context, bufferPointer)
        
        guard n >= 0 else {
            throw ModbusError.fromErrno
        }
        
        return count == Int(n) ? buffer: [UInt8](buffer.dropLast(count - Int(n)))
    }
    
    func reply(reqeust: [UInt8], mapping: ModbusMapping)  throws {
        let req = reqeust.withUnsafeBufferPointer {$0.baseAddress}
        
        guard modbus_reply(context, req!, Int32(reqeust.count), mapping.context) >= 0 else {
            throw ModbusError.fromErrno
        }
    }
    
    
    func reply(reqeust: [UInt8], code: UInt32)  throws {
        let req = reqeust.withUnsafeBufferPointer {$0.baseAddress}
        
        guard modbus_reply_exception(context, req!, code) >= 0 else {
            throw ModbusError.fromErrno
        }
    }

    public var debug: Bool {
      get {
          return debug_
      }
      set {
          if debug_ != newValue {
              debug_ = newValue
              modbus_set_debug(context, debug_ ? 1: 0)
          }
      }
    }
    private var debug_: Bool = false


    public func readBits(address: Int, n: Int) throws -> [UInt8] {
        var bits = [UInt8](repeating: 0, count: n)
        let buffer = bits.withUnsafeMutableBufferPointer { $0.baseAddress }

        let ret = modbus_read_bits(context, Int32(address), Int32(n), buffer!)

        guard ret >= 0 else {
            throw ModbusError.fromErrno
        }

        return n == Int(ret) ? bits: [UInt8](bits.dropLast(n - Int(ret)))
    }


    public func readInputBits(address: Int, n: Int) throws -> [UInt8] {
        var bits = [UInt8](repeating: 0, count: n)
        let buffer = bits.withUnsafeMutableBufferPointer { $0.baseAddress }

        let ret = modbus_read_input_bits(context, Int32(address), Int32(n), buffer!)

        guard ret >= 0 else {
            throw ModbusError.fromErrno
        }

        return n == Int(ret) ? bits: [UInt8](bits.dropLast(n - Int(ret)))
 
    }


    public func readRegisters(address: Int, n: Int) throws -> [UInt16] {
        var bits = [UInt16](repeating: 0, count: n)
        let buffer = bits.withUnsafeMutableBufferPointer { $0.baseAddress }

        let ret = modbus_read_registers(context, Int32(address), Int32(n), buffer!)

        guard ret >= 0 else {
            throw ModbusError.fromErrno
        }

        return n == Int(ret) ? bits: [UInt16](bits.dropLast(n - Int(ret)))

    }

    public func readInputRegisters(address: Int, n: Int) throws -> [UInt16] {
        var bits = [UInt16](repeating: 0, count: n)
        let buffer = bits.withUnsafeMutableBufferPointer { $0.baseAddress }

        let ret = modbus_read_input_registers(context, Int32(address), Int32(n), buffer!)

        guard ret >= 0 else {
            throw ModbusError.fromErrno
        }

        return n == Int(ret) ? bits: [UInt16](bits.dropLast(n - Int(ret)))

    }


    public func writeBit(address: Int, on: Bool) throws {
       guard modbus_write_bit(context, Int32(address), on ? 1: 0) > 0 else {
          throw ModbusError.fromErrno
       }
    }

    public func writeBits(address: Int, bits: [UInt8]) throws {
       let buffer = bits.withUnsafeBufferPointer { $0.baseAddress }

       guard modbus_write_bits(context, Int32(address), Int32(bits.count), buffer!) >= 0 else {
            throw ModbusError.fromErrno
       }
    }

    public func writeRegister(address: Int, value: UInt16) throws {
        guard modbus_write_register(context, Int32(address), value) > 0 else {
            throw ModbusError.fromErrno
        }
    }

    public func writeRegisters(address: Int, values: [UInt16]) throws {
       let buffer = values.withUnsafeBufferPointer { $0.baseAddress }

       guard modbus_write_registers(context, Int32(address), Int32(values.count), buffer!) >= 0 else {
            throw ModbusError.fromErrno
       }        
    }
}

public class ModbusRTU: Modbus {
    
    init(device: String, 
         baud: Int32 = 115200, 
         parity: CChar = "N".utf8CString[0], 
         dataBit: Int32 = 8, 
         stopBit: Int32 = 1) {
      super.init(context: modbus_new_rtu(device, baud, parity, dataBit, stopBit))
    }

    public enum SerialMode {
        case rs232
        case rs485        
    
        var rawValue: Int32 {
          get {
            switch self {
            case .rs232:
                return 0
            case .rs485:
                return 1  
            }
          }
          set {
            switch newValue {
            case 0:
              self = .rs232
            default:
              self = .rs485
            }
          }
        }

        init(rawValue raw: Int32) {
            self = raw == 0 ? .rs232: .rs485
        }
    }

    var serialMode: SerialMode {
        get {
            return SerialMode(rawValue: modbus_rtu_get_serial_mode(context))
        }

        set {
            modbus_rtu_set_serial_mode(context, newValue.rawValue)
        }
    }

}


public class ModbusTCP: Modbus {


    static let slave: Int = 0xFF
    static let defaultPort: Int = 502
    
    public init(ipAddress ip: String, port: Int32 ) {
      super.init(context: modbus_new_tcp(ip, port))
    }

    public func listen(n: Int) throws {
    
        guard modbus_tcp_listen(context, Int32(n)) == 0 else {
            throw ModbusError.fromErrno
        }
    }

    public func accept() throws -> Int {
        var socket: Int32 = 0

        guard modbus_tcp_accept(context, &socket) == 0 else {
            throw ModbusError.fromErrno
        }

        return Int(socket)
    }
}


extension Array where Element == UInt8 {
    mutating func setBitsFromByte(index: Int, byte: UInt8) {
        let buffer = withUnsafeMutableBufferPointer { $0.baseAddress }
        modbus_set_bits_from_byte(buffer!, Int32(index), byte)
    }
    
    mutating func setBitsFromByte(index: Int, bytes: [UInt8]) {
        let buffer = withUnsafeMutableBufferPointer { $0.baseAddress }
        let bytesBuffer = bytes.withUnsafeBufferPointer {$0.baseAddress}
        modbus_set_bits_from_bytes(buffer!, Int32(index), UInt32(bytes.count), bytesBuffer!)
    }
    
    func getByteFromBits(index: Int, count: UInt32) -> UInt8 {
        let buffer = withUnsafeBufferPointer {$0.baseAddress }
        return modbus_get_byte_from_bits(buffer!, Int32(index), count)
    }
}

extension Array where Element == UInt16 {
    
    enum FloatMode {
        case normal
        case abcd
        case dcba
        case badc
        case cdab
    }
    
    func float(start: Int, mode: FloatMode = .normal) -> Float {
        let buffer = withUnsafeBufferPointer {$0.baseAddress?.advanced(by: start)}
        switch mode {
        case .normal:
            return modbus_get_float(buffer!)
        case .abcd:
            return modbus_get_float_abcd(buffer!)
        case .dcba:
            return modbus_get_float_dcba(buffer!)
        case .badc:
            return modbus_get_float_badc(buffer!)
        case .cdab:
            return modbus_get_float_cdab(buffer!)
        }
    }
    
    mutating func setFloat(start: Int, value: Float, mode: FloatMode = .normal) {
        let buffer = withUnsafeMutableBufferPointer {$0.baseAddress?.advanced(by: start)}
        switch mode {
        case .normal:
            return modbus_set_float(value, buffer!)
        case .abcd:
            return modbus_set_float_abcd(value, buffer!)
        case .dcba:
            return modbus_set_float_dcba(value, buffer!)
        case .badc:
            return modbus_set_float_badc(value, buffer!)
        case .cdab:
            return modbus_set_float_cdab(value, buffer!)
        }
    }
    
}
