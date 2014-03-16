/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXDecoderResult.h"
#import "ZXDetectorResult.h"
#import "ZXMultiDetector.h"
#import "ZXQRCodeDecoder.h"
#import "ZXQRCodeDecoderMetaData.h"
#import "ZXQRCodeMultiReader.h"
#import "ZXResult.h"

@implementation ZXQRCodeMultiReader

- (NSArray *)decodeMultiple:(ZXBinaryBitmap *)image error:(NSError **)error {
  return [self decodeMultiple:image hints:nil error:error];
}

- (NSArray *)decodeMultiple:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints error:(NSError **)error {
  ZXBitMatrix *matrix = [image blackMatrixWithError:error];
  if (!matrix) {
    return nil;
  }
  NSMutableArray *results = [NSMutableArray array];
  NSArray *detectorResults = [[[ZXMultiDetector alloc] initWithImage:matrix] detectMulti:hints error:error];
  if (!detectorResults) {
    return nil;
  }
  for (ZXDetectorResult *detectorResult in detectorResults) {
    ZXDecoderResult *decoderResult = [[self decoder] decodeMatrix:[detectorResult bits] hints:hints error:nil];
    if (decoderResult) {
      NSMutableArray *points = [[detectorResult points] mutableCopy];
      // If the code was mirrored: swap the bottom-left and the top-right points.
      if ([decoderResult.other isKindOfClass:[ZXQRCodeDecoderMetaData class]]) {
        [(ZXQRCodeDecoderMetaData *)decoderResult.other applyMirroredCorrection:points];
      }
      ZXResult *result = [ZXResult resultWithText:decoderResult.text
                                         rawBytes:decoderResult.rawBytes
                                     resultPoints:points
                                           format:kBarcodeFormatQRCode];
      NSMutableArray *byteSegments = decoderResult.byteSegments;
      if (byteSegments != nil) {
        [result putMetadata:kResultMetadataTypeByteSegments value:byteSegments];
      }
      NSString *ecLevel = decoderResult.ecLevel;
      if (ecLevel != nil) {
        [result putMetadata:kResultMetadataTypeErrorCorrectionLevel value:ecLevel];
      }
      [results addObject:result];
    }
  }

  return results;
}

@end
