/*
 * Copyright (c) 2018, Psiphon Inc.
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "NSError+Convenience.h"


@implementation NSError (Convenience)

+ (instancetype)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code {
    return [NSError errorWithDomain:domain code:code userInfo:nil];
}

+ (instancetype)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code andLocalizedDescription:(NSString*)localizedDescription {
    return [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:localizedDescription}];
}

+ (instancetype)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code withUnderlyingError:(NSError *)error {
    NSDictionary *errorDict = nil;
    if (error) {
        errorDict = @{NSUnderlyingErrorKey: error};
    }
    return [NSError errorWithDomain:domain code:code userInfo:errorDict];
}

@end
