import Foundation

/**
 Write a text string onto the UART serial
 - parameters:
 - _ Text as string, with "." as a completion in the peripheral
 
 */
public func uartWriteData(_ text: String) {
    let delimitedText = text + "."
    ContentMessenger.messenger.sendMessageOfType(.writeData,
                                                 forCharacteristicUUID: .uartRX,
                                                 withData: delimitedText.microbitData)
}

