//
//  SVGShapeElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import "SVGShapeElement.h"

#import "CGPathAdditions.h"
#import "SVGDefsElement.h"
#import "SVGDocument.h"
#import "SVGElement+Private.h"
#import "SVGPattern.h"

#define ADAM_IS_FIXING_THE_TRANSFORM_AND_VIEW_BOX_CODE 0

@implementation SVGShapeElement

#define IDENTIFIER_LEN 256

@synthesize opacity = _opacity;

@synthesize fillType = _fillType;
@synthesize fillColor = _fillColor;
@synthesize fillPattern = _fillPattern;

@synthesize strokeWidth = _strokeWidth;
@synthesize strokeColor = _strokeColor;

@synthesize path = _path;

@synthesize fillId = _fillId;
+(void)trim
{
    //free statically allocated memory that is not needed
}

- (void)finalize {
	CGPathRelease(_path);
	[super finalize];
}

-(void)setFillColor:(SVGColor)fillColor
{
    _fillColor = fillColor;
    _fillType = SVGFillTypeSolid;
    
    if( _fillCG != nil )
        CGColorRelease(_fillCG);
    _fillCG = CGColorRetain(CGColorWithSVGColor(fillColor));
}

- (void)dealloc {
	[self loadPath:NULL];
    [self setFillPattern:nil];
    [_fillId release];
    [_styleClass release];
    
    if( _fillCG != nil )
        CGColorRelease(_fillCG);
    
    if( _strokeCG != nil )
        CGColorRelease(_strokeCG);
    
	[super dealloc];
}

- (void)loadDefaults {
	_opacity = 1.0f;
	
	_fillColor = SVGColorMake(0, 0, 0, 255);
	_fillType = SVGFillTypeSolid;
}

- (void)parseAttributes:(NSDictionary *)attributes {
	[super parseAttributes:attributes];
	
    if( [self.parent isKindOfClass:[SVGGroupElement class]] )
        attributes = [(SVGGroupElement *)self.parent fillBlanksInDictionary:attributes];
    
	id value = nil;
    
    if( (value = [attributes objectForKey:@"class"] ) )
    {
        _styleClass = [value copy];
    }
	
	if ((value = [attributes objectForKey:@"opacity"])) {
		_opacity = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"fill"])) {
		const char *cvalue = [value UTF8String];
		
		if (!strncmp(cvalue, "none", 4)) {
			_fillType = SVGFillTypeNone;
		}
		else if (!strncmp(cvalue, "url", 3)) {
			_fillType = SVGFillTypeURL;
            NSRange idKeyRange = NSMakeRange(5, [value length] - 6);
            _fillId = [[value substringWithRange:idKeyRange] retain];
		}
		else {
			_fillColor = SVGColorFromString([value UTF8String]);
			_fillType = SVGFillTypeSolid;
		}
	}
	
	if ((value = [attributes objectForKey:@"stroke-width"])) {
		_strokeWidth = [value floatValue];
	}
	
	if ((value = [attributes objectForKey:@"stroke"])) {
		const char *cvalue = [value UTF8String];
		
		if (!strncmp(cvalue, "none", 4)) {
			_strokeWidth = 0.0f;
		}
		else {
			_strokeColor = SVGColorFromString(cvalue);
			
			if (!_strokeWidth)
				_strokeWidth = 1.0f;
		}
	}
	
	if ((value = [attributes objectForKey:@"stroke-opacity"])) {
		_strokeColor.a = (uint8_t) ([value floatValue] * 0xFF);
	}
	
	if ((value = [attributes objectForKey:@"fill-opacity"])) {
		_fillColor.a = (uint8_t) ([value floatValue] * 0xFF);
	}
    
    if(_strokeWidth)
        _strokeCG = CGColorRetain(CGColorWithSVGColor(_strokeColor));
    
    if(_fillType == SVGFillTypeSolid)
        _fillCG = CGColorRetain(CGColorWithSVGColor(_fillColor));
    
}

- (void)loadPath:(CGPathRef)aPath {
	if (_path) {
		CGPathRelease(_path);
		_path = NULL;
	}
	
	if (aPath) {
        _path = CGPathCreateCopy(aPath);
	}
}

@end
