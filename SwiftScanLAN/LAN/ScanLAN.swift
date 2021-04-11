//
//  ScanLAN.swift
//  SwiftPing
//
//  Created by Bob Wakefield on 4/10/21.
//

import Foundation

protocol ScanLANDelegate: class {

    func scanLANDidFindNew(address: String, with hostName: String)
    func scanLANFinishedScanning()
}

class ScanLAN: NSObject {

    private weak var delegate: ScanLANDelegate?

//    private var localAddress: String = ""
    private var baseAddress: String = ""
    private var currentHostAddress: Int64 = 0
    private var timer: Timer?
//    private var netMask: String = ""
    private var baseAddressEnd: Int64 = 0
    private var timerIterationNumber: Int64 = 0

    init(with delegate: ScanLANDelegate) {

        self.delegate = delegate
    }

    func startScan() {

        let localLanInfo: [String] = localIPAddressAndMask()
        guard let localAddress = localLanInfo.first,
              let netMask = localLanInfo.last
        else {
            preconditionFailure("Could not obtain local address and subnet mask!")
        }

//        self.localAddress = localAddress
//        self.netMask = netMask

        //This is used to test on the simulator
        //self.localAddress = @"192.168.1.8";
        //self.netMask = @"255.255.255.0";
        let a = localAddress.components(separatedBy: ".")
        let b = netMask.components(separatedBy: ".")
        if isIpAddressValid(localAddress) && a.count == 4 && b.count == 4 {

            for i in 0 ..< 4 {

                guard let aValue = Int64(a[i]), let bValue = Int64(b[i])
                else {
                    preconditionFailure("Unable to convert string to integer")
                }
                let and = aValue & bValue

                if !baseAddress.isEmpty {
                    baseAddress += "."
                }

                baseAddress += "\(and)"
                currentHostAddress = and
                self.baseAddressEnd = and
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in

            self.pingAddress()
        }
    }

    func stopScan() {

        timer?.invalidate()
    }
}

extension ScanLAN {

    func pingAddress() {

        currentHostAddress += 1
        let address = baseAddress + "\(currentHostAddress)"
        PingHelper.ping(address: address, callback: pingResult)
        if self.currentHostAddress >= 254 {
            timer?.invalidate()
        }
    }

    func pingResult(success: Bool) {

        timerIterationNumber += 1
        if success {
            print("SUCCESS")
            let deviceIPAddress =
                (self.baseAddress + "\(currentHostAddress)")
                    .replacingOccurrences(of: ".00", with: ".")
                    .replacingOccurrences(of: ".0", with: ".")
                    .replacingOccurrences(of: "..", with: ".0.")
            let deviceName = getHostFromIPAddress(deviceIPAddress.cString(using: .ascii)) ?? "unable to get device name"
            delegate?.scanLANDidFindNew(address: deviceIPAddress, with: deviceName)
        } else {
            print("FAILURE")
        }

        if timerIterationNumber + baseAddressEnd >= 254 {
            delegate?.scanLANFinishedScanning()
        }
    }
}

