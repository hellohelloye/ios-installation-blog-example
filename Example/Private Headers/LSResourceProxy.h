/* Generated by RuntimeBrowser
   Image: /System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices
 */

@import Foundation;

@interface LSResourceProxy : NSObject {
    NSString *_boundApplicationIdentifier;
    NSURL *_boundContainerURL;
    NSURL *_boundDataContainerURL;
    NSString *_boundIconCacheKey;
    NSArray *_boundIconFileNames;
    BOOL _boundIconIsBadge;
    BOOL _boundIconIsPrerendered;
    NSDictionary *_boundIconsDictionary;
    NSURL *_boundResourcesDirURL;
    NSString *_localizedName;
}

@property (nonatomic, readonly) BOOL boundIconIsBadge;
@property (nonatomic, readonly) NSDictionary *iconsDictionary;
@property (nonatomic, readonly) NSString *localizedName;

// Image: /System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices

- (id)_initWithLocalizedName:(id)arg1;
- (id)_initWithLocalizedName:(id)arg1 boundApplicationIdentifier:(id)arg2 boundContainerURL:(id)arg3 dataContainerURL:(id)arg4 boundResourcesDirectoryURL:(id)arg5 boundIconsDictionary:(id)arg6 boundIconCacheKey:(id)arg7 boundIconFileNames:(id)arg8 typeOwner:(id)arg9 boundIconIsPrerendered:(BOOL)arg10 boundIconIsBadge:(BOOL)arg11;
- (id)boundApplicationIdentifier;
- (id)boundContainerURL;
- (id)boundDataContainerURL;
- (id)boundIconCacheKey;
- (id)boundIconFileNames;
- (BOOL)boundIconIsPrerendered;
- (id)boundIconsDictionary;
- (id)boundResourcesDirectoryURL;
- (void)dealloc;
- (id)iconDataForStyle:(id)arg1 width:(int)arg2 height:(int)arg3 options:(unsigned int)arg4;
- (id)iconDataForVariant:(int)arg1;
- (id)iconStyleDomain;
- (void)setBoundApplicationIdentifier:(id)arg1;
- (void)setBoundContainerURL:(id)arg1;
- (void)setBoundDataContainerURL:(id)arg1;
- (void)setBoundIconCacheKey:(id)arg1;
- (void)setBoundIconFileNames:(id)arg1;
- (void)setBoundIconIsPrerendered:(BOOL)arg1;
- (void)setBoundIconsDictionary:(id)arg1;
- (void)setBoundResourcesDirectoryURL:(id)arg1;
- (void)setTypeOwner:(id)arg1;
- (id)typeOwner;

@end