//
//  EEPackagesCell.m
//  Extender Installer
//
//  Created by Matt Clarke on 14/04/2017.
//
//

#import "EEPackagesCell.h"

@interface LSApplicationProxy : NSObject
@property (nonatomic, readonly) NSString *applicationIdentifier;
@property (nonatomic, readonly) long bundleModTime;
- (id)localizedName;
- (id)primaryIconDataForVariant:(int)arg1;
- (id)iconDataForVariant:(int)arg1;
@end

@interface UIImage (Private)
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format scale:(CGFloat)scale;
@end

@implementation EEPackagesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)_configureViewsIfNeeded {
    if (!self.localisedTitleLabel) {
        self.localisedTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.localisedTitleLabel.textColor = [UIColor darkTextColor];
        self.localisedTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.localisedTitleLabel.font = [UIFont systemFontOfSize:18];
        self.localisedTitleLabel.numberOfLines = 1;
        
        [self.contentView addSubview:self.localisedTitleLabel];
    }
    
    if (!self.icon) {
        self.icon = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.icon.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.icon];
    }
    
    if (!self.bundleIdentifierLabel) {
        self.bundleIdentifierLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.bundleIdentifierLabel.textColor = [UIColor grayColor];
        self.bundleIdentifierLabel.textAlignment = NSTextAlignmentLeft;
        self.bundleIdentifierLabel.font = [UIFont systemFontOfSize:12];
        self.bundleIdentifierLabel.numberOfLines = 1;
        
        [self.contentView addSubview:self.bundleIdentifierLabel];
    }
    
    if (!self.lastSignedLabel) {
        self.lastSignedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lastSignedLabel.textColor = [UIColor darkGrayColor];
        self.lastSignedLabel.textAlignment = NSTextAlignmentLeft;
        self.lastSignedLabel.font = [UIFont systemFontOfSize:14];
        self.lastSignedLabel.numberOfLines = 1;
        self.lastSignedLabel.text = @"Signed: x ago";
        
        [self.contentView addSubview:self.lastSignedLabel];
    }
    
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
}

- (void)setupWithProxy:(LSApplicationProxy*)proxy {
    [self _configureViewsIfNeeded];
    
    _proxy = proxy;
    
    // icon.
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:proxy.applicationIdentifier format:0 scale:[UIScreen mainScreen].scale];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.icon.image = icon;
        });
    });
    
    self.localisedTitleLabel.text = [proxy localizedName];
    self.bundleIdentifierLabel.text = proxy.applicationIdentifier;
    
    // Now, we calculate the time for this one.
    NSDate *bundleModifiedTimestamp = [NSDate dateWithTimeIntervalSinceReferenceDate:proxy.bundleModTime];
    
    NSDate *now = [NSDate date];
    unsigned int unitFlags = NSCalendarUnitSecond | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay;
    NSDateComponents *conversionInfo = [_calendar components:unitFlags fromDate:bundleModifiedTimestamp toDate:now options:0];
    
    int seconds = (int)conversionInfo.second;
    int minutes = (int)conversionInfo.minute;
    int hours = (int)conversionInfo.hour;
    int days = (int)conversionInfo.day;
    
    NSString *str = @"Signed: ";
    
    NSString *daysStr = [NSString stringWithFormat:@"%d day%@", days, days == 1 ? @"" : @"s"];
    NSString *hoursStr = [NSString stringWithFormat:@"%d hour%@", hours, hours == 1 ? @"" : @"s"];
    NSString *minStr = [NSString stringWithFormat:@"%d minute%@", minutes, minutes == 1 ? @"" : @"s"];
    NSString *secStr = [NSString stringWithFormat:@"%d second%@", seconds, seconds == 1 ? @"" : @"s"];
    
    if (days > 0) {
        // Display days and hours.
        str = [str stringByAppendingFormat:@"%@, %@", daysStr, hoursStr];
    } else if (hours > 0) {
        // Display hours and mins.
        str = [str stringByAppendingFormat:@"%@, %@", hoursStr, minStr];
    } else if (minutes > 0) {
        // Display mins and seconds.
        str = [str stringByAppendingFormat:@"%@, %@", minStr, secStr];
    } else {
        // Display seconds.
        str = [str stringByAppendingFormat:@"%@", secStr];
    }
    
    str = [str stringByAppendingString:@" ago"];
    
    self.lastSignedLabel.text = str;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.icon.frame = CGRectMake(10, 10, 30, 30);
    
    CGFloat xOrigin = 50;
    CGFloat yOrigin = 5;
    
    self.localisedTitleLabel.frame = CGRectMake(xOrigin, yOrigin, self.contentView.frame.size.width - xOrigin - 5, 25);
    
    yOrigin += 25;
    
    self.bundleIdentifierLabel.frame = CGRectMake(xOrigin, yOrigin, self.contentView.frame.size.width - xOrigin - 5, 15);
    
    yOrigin += 18;
    
    self.lastSignedLabel.frame = CGRectMake(xOrigin, yOrigin, self.contentView.frame.size.width - xOrigin - 5, 20);
}

@end
