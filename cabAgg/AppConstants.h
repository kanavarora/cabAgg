//
//  AppConstants.h
//  cabAgg
//
//  Created by Kanav Arora on 2/12/16.
//  Copyright © 2016 LikwidSkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConstants : NSObject

- (id)initWithDict:(NSDictionary *)dict;
- (NSInteger)getIntForKey:(NSString *)key;
- (float)getFloatForKey:(NSString *)key;
- (NSString *)getStrForKey:(NSString *)key;
- (BOOL)getBoolForKey:(NSString *)key;

@end
