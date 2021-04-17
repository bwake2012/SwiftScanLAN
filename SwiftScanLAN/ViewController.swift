//
//  ViewController.swift
//  SwiftPing
//
//  Created by Bob Wakefield on 4/10/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView?
    var connectedDevices: [Device] = []
    var lanScanner: ScanLAN?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {

        startScanningLAN()
    }

    override func viewWillDisappear(_ animated: Bool) {

        stopScanningLAN()
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return connectedDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Device", for: indexPath)

        let device = connectedDevices[indexPath.row]
        cell.textLabel?.text = device.name
        cell.detailTextLabel?.text = device.address

        return cell
    }
}

extension ViewController {

    @IBAction func startScanningLAN() {

        lanScanner?.stopScan()

        activityIndicator.startAnimating()
        lanScanner = ScanLAN(with: self)
        connectedDevices = []
        tableView?.reloadData()
        lanScanner?.startScan()
    }

    func stopScanningLAN() {

        activityIndicator.stopAnimating()
        lanScanner?.stopScan()
    }
}

extension ViewController: ScanLANDelegate {

    func scanLANDidFindNew(address: String, with hostName: String) {

        print("Found: \(address)")

        connectedDevices.append(Device(name: hostName, address: address))

        tableView?.reloadData()
    }

    func scanLANFinishedScanning() {

        print("Scan finished")

        activityIndicator.stopAnimating()

        let alert =
            UIAlertController(
                title: "Scan Finished",
                message: "Number of devices connected to the Local Area Network: \(connectedDevices.count)",
                preferredStyle: .alert)
        let action = UIAlertAction(
                title: NSLocalizedString("OK", comment: "Default action"),
                style: .default
            ) { _ in
                NSLog("The \"OK\" alert occured.")
            }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

