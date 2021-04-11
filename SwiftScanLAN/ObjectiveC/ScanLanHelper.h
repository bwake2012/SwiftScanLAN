//
//  ScanLanHelper.h
//  SwiftScanLAN
//
//  Created by Bob Wakefield on 4/10/21.
//

#ifndef ScanLanHelper_h
#define ScanLanHelper_h

NSString * getHostFromIPAddress(const char * ipAddress);
NSString * getIPAddress();
NSArray<NSString *>* localIPAddressAndMask();
BOOL isIpAddressValid(NSString *ipAddress);

#endif /* ScanLanHelper_h */
