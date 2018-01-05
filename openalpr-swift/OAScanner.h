//
//  OAScanner.h
//  openalpr-swift
//
//  Created by Yasir M Turk on 05/01/2018.
//  Copyright © 2018 Yasir M Türk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OATypes.h"

typedef void(^onPlateScanSuccess)(NSArray<OAPlate *> *);
typedef void(^onPlateScanFailure)(NSError *);

@protocol OAScannerDelegate<NSObject>

@optional
- (void)didScanResults:(OAResults *)results;

- (void)didScanResultsJSON:(NSString *)results;

- (void)didScanBestPlates:(NSArray<OAPlate *> *)bestPlates;

- (void)didScanPlateResult:(OAPlateResult *)plateResult;

- (void)didFailToLoadwithError:(NSError *)error;

@end

@interface OAScanner: NSObject

@property (weak) id<OAScannerDelegate> delegate;
@property BOOL JSONResults;

- (instancetype)initWithCountry:(NSString *)country configFile:(NSString *)configPath runtimeDir:(NSString *)runtimeDir;
- (instancetype)initWithCountry:(NSString *)country patternRegion:(NSString *)region;
- (instancetype)initWithCountry:(NSString *)country;

- (void)setPatternRegion:(NSString *)region;
- (void)setTopN:(int)n;

- (void)scanImage:(UIImage *)image onSuccess:(onPlateScanSuccess)success onFailure:(onPlateScanFailure)failure;
- (void)scanImageAtPath:(NSString *)path onSuccess:(onPlateScanSuccess)success onFailure:(onPlateScanFailure)failure;

@end

@interface OAScanner(ExtraConfiguration)

- (void)setCountry:(NSString *)country;
- (void)setPreWrap:(NSString *)preWrap;
- (void)setDetectRegion:(BOOL)detectRegion;
- (NSString *)version;

@end

@interface OAScanner(Utility)

+ (OAResults *)fromJSON:(NSString *)jsonString;

@end
