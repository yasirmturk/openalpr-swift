//
//  OAScanner.mm
//  openalpr-swift
//
//  Created by Yasir M Turk on 05/01/2018.
//  Copyright © 2018 Yasir M Türk. All rights reserved.
//

#import "OAScanner.h"

using namespace std;

#import <openalpr/alpr.h>
using namespace alpr;

#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

#ifdef __cplusplus
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgcodecs/imgcodecs.hpp>
using namespace cv;
#endif


@implementation OAScanner {
    Alpr * alpr;
}

- (instancetype)initWithCountry:(NSString *)country configFile:(NSString *)configPath runtimeDir:(NSString *)runtimeDir {
    if (self = [super init]) {
        NSAssert(configPath, @"Configuration file path could not be nil");
        NSAssert(runtimeDir, @"Runtime data path could not be nil");
        alpr = new Alpr(country.length ? [country UTF8String] : [@"eu" UTF8String],
                        [configPath UTF8String],
                        [runtimeDir UTF8String] );
        
        if (alpr->isLoaded() == false) {
            NSLog(@"Error initializing OpenALPR library");
            alpr = nil;
        }
        if (!alpr) self = nil;
    }
    return self;
}

- (instancetype)initWithCountry:(NSString *)country patternRegion:(NSString *)region {
    if (self = [self initWithCountry:country
                          configFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"openalpr" ofType:@"conf"]
                          runtimeDir:[[NSBundle bundleForClass:[self class]] pathForResource:@"runtime_data" ofType:nil]]) {
        
        if (region.length) {
            alpr->setDefaultRegion([region UTF8String]);
        }
    }
    return self;
}

- (instancetype)initWithCountry:(NSString *)country {
    if (self = [self initWithCountry:country
                          configFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"openalpr" ofType:@"conf"]
                          runtimeDir:[[NSBundle bundleForClass:[self class]] pathForResource:@"runtime_data" ofType:nil]]) {
    }
    return self;
}

- (void)setPatternRegion:(NSString *)region {
    if (region.length) {
        alpr->setDefaultRegion([region UTF8String]);
    }
}

- (void)setTopN:(int)n {
    alpr->setTopN(5);
}

- (void)scanCVImage:(cv::Mat &)colorImage onSuccess:(onPlateScanSuccess)success onFailure:(onPlateScanFailure)failure {
    
    if (alpr->isLoaded() == false) {
        NSError *error = [NSError errorWithDomain:@"OpenALPR"
                                             code:-100
                                         userInfo:@{NSLocalizedDescriptionKey: @"Error loading OpenALPR"}];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToLoadwithError:)]) {
            [self.delegate didFailToLoadwithError:error];
        }
        failure(error);
    }
    
    vector<AlprRegionOfInterest> regionsOfInterest;
    AlprResults results = alpr->recognize(colorImage.data, (int)colorImage.elemSize(), colorImage.cols, colorImage.rows, regionsOfInterest);
    
    OAResults *scanResults = [[OAResults alloc] initWithAlprResults:&results];
    
    if (_JSONResults && _delegate && [_delegate respondsToSelector:@selector(didScanResultsJSON:)]) {
        [self.delegate didScanResultsJSON:[NSString stringWithUTF8String:(Alpr::toJson(results).c_str())]];
    } else if (_delegate && [_delegate respondsToSelector:@selector(didScanResults:)]) {
        [self.delegate didScanResults:scanResults];
    }
    
    NSMutableArray *bestPlates = [[NSMutableArray alloc] initWithCapacity:scanResults.plates.count];
    for (OAPlateResult *pr in scanResults.plates) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(didScanPlateResult:)]) {
            [self.delegate didScanPlateResult:pr];
        }
        
        for (OAPlate *p in pr.topNPlates) {
            NSLog(@"%@[%i] - %f", p.number, p.matchesTemplate, p.confidence);
        }
        [bestPlates addObject:pr.bestPlate];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didScanBestPlates:)]) {
        [self.delegate didScanBestPlates:bestPlates];
    }
    
    success(bestPlates);
}

- (void)scanImage:(UIImage *)image onSuccess:(onPlateScanSuccess)success onFailure:(onPlateScanFailure)failure {
    cv::Mat m = cv::Mat();
    UIImageToMat(image, m);
    [self scanCVImage:m onSuccess:success onFailure:failure];
}

- (void)scanImageAtPath:(NSString *)path onSuccess:(onPlateScanSuccess)success onFailure:(onPlateScanFailure)failure {
    cv::Mat m = imread([path UTF8String], CV_LOAD_IMAGE_COLOR);
    [self scanCVImage:m onSuccess:success onFailure:failure];
}

@end

@implementation OAScanner(ExtraConfiguration)

- (void)setCountry:(NSString *)country {
    if ([country length]) {
        alpr->setCountry([country UTF8String]);
    }
}

- (void)setPreWrap:(NSString *)preWrap {
    if ([preWrap length]) {
        alpr->setPrewarp([preWrap UTF8String]);
    }
}

- (void)setDetectRegion:(BOOL)detectRegion {
    alpr->setDetectRegion(detectRegion);
}

- (NSString *)version {
    return [NSString stringWithUTF8String:alpr->getVersion().c_str()];
}

@end

@implementation OAScanner(Utility)

+ (OAResults *)fromJSON:(NSString *)jsonString {
    AlprResults results = Alpr::fromJson([jsonString UTF8String]);
    return [[OAResults alloc] initWithAlprResults:&results];
}

@end
