//
//  SVGGroupElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGGroupElement.h"

#import "SVGDocument.h"

#import "SVGElement+Private.h"

@implementation SVGGroupElement

@synthesize opacity = _opacity;
@synthesize attributes = _attributes;

//didn't want to make a new utils class to store this function and it's needed by children of this class so it was the most convenient, would be better as a categorical function on NSDictinoary though

-(NSDictionary *)fillBlanksInDictionary:(NSDictionary *)highPriority
{
    if( self.attributes == nil )
        return highPriority;
    return [self dictionaryByMergingDictionary:self.attributes overridenByDictionary:highPriority];
}

-(NSDictionary *)dictionaryByMergingDictionary:(NSDictionary *)lowPriority overridenByDictionary:(NSDictionary *)highPriority
{
    NSArray *allKeys = [[lowPriority allKeys] arrayByAddingObjectsFromArray:[highPriority allKeys]];
    
    NSArray *allValues = [[lowPriority allValues] arrayByAddingObjectsFromArray:[highPriority allValues]];
    
    return [NSDictionary dictionaryWithObjects:allValues forKeys:allKeys];
}


+ (void)trim
{
    
}

- (void)dealloc {
    [_attributes release];
    [super dealloc];
}

- (void)loadDefaults {
	_opacity = 1.0f;
}

- (void)parseAttributes:(NSDictionary *)attributes {
	[super parseAttributes:attributes];
	
	id value = nil;
	
	if ((value = [attributes objectForKey:@"opacity"])) { //opacity of all elements in this group
		_opacity = [value floatValue];
	}
    
    //we can't propagate opacity down unfortunately, so we need to build a set of all the properties except a few (opacity is applied differently to groups than simply inheriting it to it's children, <g opacity occurs AFTER blending all of its children
    
    BOOL attributesFound = NO;
    NSMutableDictionary *buildDictionary = [NSMutableDictionary new];
    for( NSString *key in attributes )
    {
        if( ![key isEqualToString:@"opacity"] )
        {
            attributesFound = YES;
            [buildDictionary setObject:[attributes objectForKey:key] forKey:key];
        }
    }
    
    if( attributesFound )
    {
        _attributes = [[NSDictionary alloc] initWithDictionary:buildDictionary];
        //these properties are inherited by children of this group
    }
    [buildDictionary release];
}

@end
