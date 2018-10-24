import Foundation

/**
 UART write in to micro:bit
 - parameters:
 - _ Text as a String, this cannot be omitted.
 */
public func uartWriteData(_ text: String) {
    
    let delimitedtext = text + "."
    ContentMessenger.messenger.sendMessageOfType(.writeData,
                                                 forCharacteristicUUID: .uartRX,
                                                 withData: delimitedtext.microbitData)
}
