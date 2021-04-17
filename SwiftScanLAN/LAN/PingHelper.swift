//
//  PingHelper.swift
//  SwiftScanLAN
//
//  Created by Bob Wakefield on 4/10/21.
//

import Foundation

class PingHelper: NSObject {

    typealias Callback = (Bool) -> Void

    var simplePing: SimplePing?
    let callback: Callback

    init(with address: String, of addressStyle: SimplePingAddressStyle, callback: @escaping Callback) {

        self.callback = callback

        simplePing = SimplePing(hostName: address)
        simplePing?.addressStyle = addressStyle

        super.init()

        simplePing?.delegate = self
    }

    func go() {

        simplePing?.start()
        perform(#selector(endTime), with: nil, afterDelay: 0.1)
    }
}

extension PingHelper {


    /// Create and start a ping helper for the supplied address
    /// - Parameters:
    ///   - address: IPv4 or IPv6 numeric address string
    ///   - addressStyle: the style of the address
    ///   - callback: function or closure taking Bool and returning Void
    static func ping(address: String, of addressStyle: SimplePingAddressStyle = .icmPv4, callback: @escaping Callback) {

        PingHelper(with: address, of: addressStyle, callback: callback).go()
    }
}

// finishing and timing out
extension PingHelper {

    func killPing() {

        simplePing?.stop()
        simplePing = nil
    }

    func successPing() {

        self.killPing()
        callback(true)
    }

    func failPing(_ reason: String) {

        print(reason)

        killPing()
        callback(false)
    }

    @objc func endTime () {

        if nil != self.simplePing {

            failPing("timeout")
        }
    }
}

extension PingHelper: SimplePingDelegate {

    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {

        pinger.send(with: nil)
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {

        failPing("didFailWithError: \(error.localizedDescription)")
    }
    
    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {


    }
    
    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {

        failPing("didFailToSendPacket with error: \(error.localizedDescription)")
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {

        successPing()
    }
    
    func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {


    }
}
