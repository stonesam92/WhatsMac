//
//  NSLabel.h
//  ChitChat
//
//  Courtesy: Axel Guilmin
//  http://stackoverflow.com/questions/20169298/xcode-doesnt-recognize-nslabel
//

#import <AppKit/AppKit.h>

@interface NSLabel : NSTextField

@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) NSString *text;

@end
