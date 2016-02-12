//
//  AppConstants.m
//  cabAgg
//
//  Created by Kanav Arora on 2/12/16.
//  Copyright © 2016 LikwidSkin. All rights reserved.
//

#import "AppConstants.h"

@interface AppConstants ()

@property (nonatomic, readwrite, strong) NSDictionary *dict;

@end

@implementation AppConstants
- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        _dict = dict;
    }
    return self;
}

- (NSInteger)getIntForKey:(NSString *)key {
    return [self.dict[key] integerValue];
}

- (float)getFloatForKey:(NSString *)key {
    return [self.dict[key] floatValue];
}

- (NSString *)getStrForKey:(NSString *)key {
    return self.dict[key];
}

- (BOOL)getBoolForKey:(NSString *)key {
    return [self.dict[key] boolValue];
}
@end
