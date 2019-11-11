#import "TfAlbumSaverPlugin.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation TfAlbumSaverPlugin {
    FlutterResult albumSaverResult;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"tf_album_saver_channel"
                                     binaryMessenger:[registrar messenger]];
    TfAlbumSaverPlugin* instance = [[TfAlbumSaverPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    albumSaverResult = result;
    if ([@"saveToAlbum" isEqualToString:call.method]) {
        NSNumber *type = call.arguments[@"type"];
        NSString *filePath = call.arguments[@"filePath"];
        switch ([type intValue]) {
            case 0: {
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                ALAssetsLibrary *library = [ALAssetsLibrary new];
                [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                    result(error ? error.description : nil);
                }];
                break;
            }
            case 1:
            case 2: {
                SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
                UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, selector, NULL);
                //  result in selector
                break;
            }
            default:
                result(nil);
                break;
        }
    } else if ([@"saveImageByBytes" isEqualToString:call.method]) {
        FlutterStandardTypedData *imageBytes = call.arguments[@"imageBytes"];
        UIImage *image = [UIImage imageWithData:imageBytes.data];
        SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(image, self, selector, NULL);
        //  result in selector
    } else {
        result(FlutterMethodNotImplemented);
    }
}

//图片保存完后调用的方法
- (void)onCompleteCapture:(UIImage *)screenImage didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        albumSaverResult(error.description);
    } else {
        albumSaverResult(nil);
    }
}
@end

