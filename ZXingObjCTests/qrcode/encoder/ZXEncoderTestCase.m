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

#import "ZXEncoderTestCase.h"

@implementation ZXEncoderTestCase

- (void)testGetAlphanumericCode {
  // The first ten code points are numbers.
  for (int i = 0; i < 10; ++i) {
    XCTAssertEqual([ZXEncoder alphanumericCode:'0' + i], i, @"Expected %d", i);
  }

  // The next 26 code points are capital alphabet letters.
  for (int i = 10; i < 36; ++i) {
    XCTAssertEqual([ZXEncoder alphanumericCode:'A' + i - 10], i, @"Expected %d", i);
  }

  // Others are symbol letters
  XCTAssertEqual([ZXEncoder alphanumericCode:' '], 36, @"Expected %d", 36);
  XCTAssertEqual([ZXEncoder alphanumericCode:'$'], 37, @"Expected %d", 37);
  XCTAssertEqual([ZXEncoder alphanumericCode:'%'], 38, @"Expected %d", 38);
  XCTAssertEqual([ZXEncoder alphanumericCode:'*'], 39, @"Expected %d", 39);
  XCTAssertEqual([ZXEncoder alphanumericCode:'+'], 40, @"Expected %d", 40);
  XCTAssertEqual([ZXEncoder alphanumericCode:'-'], 41, @"Expected %d", 41);
  XCTAssertEqual([ZXEncoder alphanumericCode:'.'], 42, @"Expected %d", 42);
  XCTAssertEqual([ZXEncoder alphanumericCode:'/'], 43, @"Expected %d", 43);
  XCTAssertEqual([ZXEncoder alphanumericCode:':'], 44, @"Expected %d", 44);

  // Should return -1 for other letters;
  XCTAssertEqual([ZXEncoder alphanumericCode:'a'], -1, @"Expected -1");
  XCTAssertEqual([ZXEncoder alphanumericCode:'#'], -1, @"Expected -1");
  XCTAssertEqual([ZXEncoder alphanumericCode:'\0'], -1, @"Expected -1");
}

- (void)testChooseMode {
  // Numeric mode.
  XCTAssertEqualObjects([ZXEncoder chooseMode:@"0"], [ZXMode numericMode], @"Expected numeric mode");
  XCTAssertEqualObjects([ZXEncoder chooseMode:@"0123456789"], [ZXMode numericMode], @"Expected numeric mode");
  // Alphanumeric mode.
  XCTAssertEqualObjects([ZXEncoder chooseMode:@"A"], [ZXMode alphanumericMode], @"Expected alphanumeric mode");
  XCTAssertEqualObjects([ZXEncoder chooseMode:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"],
                       [ZXMode alphanumericMode], @"Expected alphanumeric mode");
  // 8-bit byte mode.
  XCTAssertEqualObjects([ZXEncoder chooseMode:@"a"], [ZXMode byteMode], @"Expected byte mode");
  XCTAssertEqualObjects([ZXEncoder chooseMode:@"#"], [ZXMode byteMode], @"Expected byte mode");
  XCTAssertEqualObjects([ZXEncoder chooseMode:@""], [ZXMode byteMode], @"Expected byte mode");
  // Kanji mode.  We used to use MODE_KANJI for these, but we stopped
  // doing that as we cannot distinguish Shift_JIS from other encodings
  // from data bytes alone.  See also comments in qrcode_encoder.h.

  // AIUE in Hiragana in Shift_JIS
  int8_t hiraganaBytes[8] = {0x8, 0xa, 0x8, 0xa, 0x8, 0xa, 0x8, 0xa6};
  XCTAssertEqualObjects([ZXEncoder chooseMode:[self shiftJISString:hiraganaBytes bytesLen:8]], [ZXMode byteMode],
                       @"Expected byte mode");

  // Nihon in Kanji in Shift_JIS.
  int8_t kanjiBytes[4] = {0x9, 0xf, 0x9, 0x7b};
  XCTAssertEqualObjects([ZXEncoder chooseMode:[self shiftJISString:kanjiBytes bytesLen:4]], [ZXMode byteMode],
                       @"Expected byte mode");

  // Sou-Utsu-Byou in Kanji in Shift_JIS.
  int8_t kanjiBytes2[6] = {0xe, 0x4, 0x9, 0x5, 0x9, 0x61};
  XCTAssertEqualObjects([ZXEncoder chooseMode:[self shiftJISString:kanjiBytes2 bytesLen:6]], [ZXMode byteMode],
                       @"Expected byte mode");
}

- (void)testEncode {
  ZXQRCode *qrCode = [ZXEncoder encode:@"ABCDEF" ecLevel:[ZXErrorCorrectionLevel errorCorrectionLevelH] error:nil];
  // The following is a valid QR Code that can be read by cell phones.
  NSString *expected =
    @"<<\n"
    " mode: ALPHANUMERIC\n"
    " ecLevel: H\n"
    " version: 1\n"
    " maskPattern: 0\n"
    " matrix:\n"
    " 1 1 1 1 1 1 1 0 1 1 1 1 0 0 1 1 1 1 1 1 1\n"
    " 1 0 0 0 0 0 1 0 0 1 1 1 0 0 1 0 0 0 0 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 0 1 1 0 1 0 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 1 1 1 0 1 0 1 0 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 1 1 0 0 1 0 1 1 1 0 1\n"
    " 1 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 1\n"
    " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
    " 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0\n"
    " 0 0 1 0 1 1 1 0 1 1 0 0 1 1 0 0 0 1 0 0 1\n"
    " 1 0 1 1 1 0 0 1 0 0 0 1 0 1 0 0 0 0 0 0 0\n"
    " 0 0 1 1 0 0 1 0 1 0 0 0 1 0 1 0 1 0 1 1 0\n"
    " 1 1 0 1 0 1 0 1 1 1 0 1 0 1 0 0 0 0 0 1 0\n"
    " 0 0 1 1 0 1 1 1 1 0 0 0 1 0 1 0 1 1 1 1 0\n"
    " 0 0 0 0 0 0 0 0 1 0 0 1 1 1 0 1 0 1 0 0 0\n"
    " 1 1 1 1 1 1 1 0 0 0 1 0 1 0 1 1 0 0 0 0 1\n"
    " 1 0 0 0 0 0 1 0 1 1 1 1 0 1 0 1 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 1 0 1 1 0 1 0 1 0 0 0 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 1 0 1 1 1 1 0 1 0 1 0\n"
    " 1 0 1 1 1 0 1 0 1 0 0 0 1 0 1 0 1 1 1 0 1\n"
    " 1 0 0 0 0 0 1 0 0 1 1 0 1 1 0 1 0 0 0 1 1\n"
    " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 1 0 1 0 1\n"
    ">>\n";
  XCTAssertEqualObjects([qrCode description], expected, @"Expected qr code to equal %@", expected);
}

- (void)testSimpleUTF8ECI {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.encoding = NSUTF8StringEncoding;
  ZXQRCode *qrCode = [ZXEncoder encode:@"hello" ecLevel:[ZXErrorCorrectionLevel errorCorrectionLevelH] hints:hints error:nil];
  NSString *expected =
    @"<<\n"
    " mode: BYTE\n"
    " ecLevel: H\n"
    " version: 1\n"
    " maskPattern: 3\n"
    " matrix:\n"
    " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 1\n"
    " 1 0 0 0 0 0 1 0 0 0 1 0 1 0 1 0 0 0 0 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 0 1 0 0 1 0 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 1 0 1 0 1 0 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 0 1\n"
    " 1 0 0 0 0 0 1 0 0 0 0 0 1 0 1 0 0 0 0 0 1\n"
    " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
    " 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0\n"
    " 0 0 1 1 0 0 1 1 1 1 0 0 0 1 1 0 1 0 0 0 0\n"
    " 0 0 1 1 1 0 0 0 0 0 1 1 0 0 0 1 0 1 1 1 0\n"
    " 0 1 0 1 0 1 1 1 0 1 0 1 0 0 0 0 0 1 1 1 1\n"
    " 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 0 1 0 1 1 0\n"
    " 0 0 0 0 1 0 1 1 1 1 0 0 0 0 0 1 0 0 1 0 0\n"
    " 0 0 0 0 0 0 0 0 1 1 1 1 0 0 1 1 1 0 0 0 1\n"
    " 1 1 1 1 1 1 1 0 1 1 1 0 1 0 1 1 0 0 1 0 0\n"
    " 1 0 0 0 0 0 1 0 0 0 1 0 0 1 1 1 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 0 0 0 0 1 1 0 0 0 0 0\n"
    " 1 0 1 1 1 0 1 0 1 1 1 0 1 0 0 0 1 1 0 0 0\n"
    " 1 0 1 1 1 0 1 0 1 1 0 0 0 1 0 0 1 0 0 0 0\n"
    " 1 0 0 0 0 0 1 0 0 0 0 1 1 0 1 0 1 0 1 1 0\n"
    " 1 1 1 1 1 1 1 0 0 1 0 1 1 1 0 1 1 0 0 0 0\n"
    ">>\n";
  XCTAssertEqualObjects([qrCode description], expected, @"Expected qr code to equal %@", expected);
}

- (void)testAppendModeInfo {
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendModeInfo:[ZXMode numericMode] bits:bits];
  NSString *expected = @" ...X";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
}

- (void)testAppendLengthInfo {
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendLengthInfo:1  // 1 letter (1/1).
                      version:[ZXQRCodeVersion versionForNumber:1]
                         mode:[ZXMode numericMode]
                         bits:bits
                        error:nil];
  NSString *expected = @" ........ .X";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);  // 10 bits.
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendLengthInfo:2  // 2 letter (2/1).
                      version:[ZXQRCodeVersion versionForNumber:10]
                         mode:[ZXMode alphanumericMode]
                         bits:bits
                        error:nil];
  expected = @" ........ .X.";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);  // 11 bits.
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendLengthInfo:255  // 255 letter (255/1).
                      version:[ZXQRCodeVersion versionForNumber:27]
                         mode:[ZXMode byteMode]
                         bits:bits
                        error:nil];
  expected = @" ........ XXXXXXXX";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);  // 16 bits.
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendLengthInfo:512  // 512 letter (1024/2).
                      version:[ZXQRCodeVersion versionForNumber:40]
                         mode:[ZXMode kanjiMode]
                         bits:bits
                        error:nil];
  expected = @" ..X..... ....";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);  // 12 bits.
}

- (void)testAppendBytes {
  // Should use appendNumericBytes.
  // 1 = 01 = 0001 in 4 bits.
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendBytes:@"1" mode:[ZXMode numericMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:nil];
  NSString *expected = @" ...X";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  // Should use appendAlphanumericBytes.
  // A = 10 = 0xa = 001010 in 6 bits
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendBytes:@"A" mode:[ZXMode alphanumericMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:nil];
  expected = @" ..X.X.";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  // Lower letters such as 'a' cannot be encoded in MODE_ALPHANUMERIC.
  NSError *error;
  if ([ZXEncoder appendBytes:@"a" mode:[ZXMode alphanumericMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:&error] ||
      error.code != ZXWriterError) {
    XCTFail(@"Expected ZXWriterError");
  }
  // Should use append8BitBytes.
  // 0x61, 0x62, 0x63
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendBytes:@"abc" mode:[ZXMode byteMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:nil];
  expected = @" .XX....X .XX...X. .XX...XX";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  // Anything can be encoded in QRCode.MODE_8BIT_BYTE.
  [ZXEncoder appendBytes:@"\0" mode:[ZXMode byteMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:nil];
  // Should use appendKanjiBytes.
  // 0x93, 0x5f
  bits = [[ZXBitArray alloc] init];
  int8_t bytes[2] = {0x93, 0x5f};
  [ZXEncoder appendBytes:[self shiftJISString:bytes bytesLen:2] mode:[ZXMode kanjiMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:nil];
  expected = @" .XX.XX.. XXXXX";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
}

- (void)testTerminateBits {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  [ZXEncoder terminateBits:0 bits:v error:nil];
  XCTAssertEqualObjects([v description], @"", @"Expected v to equal \"\"");
  v = [[ZXBitArray alloc] init];
  [ZXEncoder terminateBits:1 bits:v error:nil];
  NSString *expected = @" ........";
  XCTAssertEqualObjects([v description], expected, @"Expected v to equal %@", expected);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0 numBits:3];  // Append 000
  [ZXEncoder terminateBits:1 bits:v error:nil];
  expected = @" ........";
  XCTAssertEqualObjects([v description], expected, @"Expected v to equal %@", expected);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0 numBits:5];  // Append 00000
  [ZXEncoder terminateBits:1 bits:v error:nil];
  expected = @" ........";
  XCTAssertEqualObjects([v description], expected, @"Expected v to equal %@", expected);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0 numBits:8];  // Append 00000000
  [ZXEncoder terminateBits:1 bits:v error:nil];
  expected = @" ........";
  XCTAssertEqualObjects([v description], expected, @"Expected v to equal %@", expected);
  v = [[ZXBitArray alloc] init];
  [ZXEncoder terminateBits:2 bits:v error:nil];
  expected = @" ........ XXX.XX..";
  XCTAssertEqualObjects([v description], expected, @"Expected v to equal %@", expected);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0 numBits:1];  // Append 0
  [ZXEncoder terminateBits:3 bits:v error:nil];
  expected = @" ........ XXX.XX.. ...X...X";
  XCTAssertEqualObjects([v description], expected, @"Expected v to equal %@", expected);
}

- (void)testGetNumDataBytesAndNumECBytesForBlockID {
  int numDataBytes[1] = {0};
  int numEcBytes[1] = {0};
  // Version 1-H.
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:26 numDataBytes:9 numRSBlocks:1 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(numDataBytes[0], 9, @"Expected numDataBytes[0] to equal %d", 9);
  XCTAssertEqual(numEcBytes[0], 17, @"Expected numEcBytes[0] to equal %d", 17);

  // Version 3-H.  2 blocks.
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:70 numDataBytes:26 numRSBlocks:2 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(numDataBytes[0], 13, @"Expected numDataBytes[0] to equal %d", 13);
  XCTAssertEqual(numEcBytes[0], 22, @"Expected numEcBytes[0] to equal %d", 22);
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:70 numDataBytes:26 numRSBlocks:2 blockID:1
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(numDataBytes[0], 13, @"Expected numDataBytes[0] to equal %d", 13);
  XCTAssertEqual(numEcBytes[0], 22, @"Expected numEcBytes[0] to equal %d", 22);

  // Version 7-H. (4 + 1) blocks.
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:196 numDataBytes:66 numRSBlocks:5 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(numDataBytes[0], 13, @"Expected numDataBytes[0] to equal %d", 13);
  XCTAssertEqual(numEcBytes[0], 26, @"Expected numEcBytes[0] to equal %d", 26);
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:196 numDataBytes:66 numRSBlocks:5 blockID:4
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(numDataBytes[0], 14, @"Expected numDataBytes[0] to equal %d", 14);
  XCTAssertEqual(numEcBytes[0], 26, @"Expected numEcBytes[0] to equal %d", 22);

  // Version 40-H. (20 + 61) blocks.
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:3706 numDataBytes:1276 numRSBlocks:81 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(numDataBytes[0], 15, @"Expected numDataBytes[0] to equal %d", 15);
  XCTAssertEqual(numEcBytes[0], 30, @"Expected numEcBytes[0] to equal %d", 30);
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:3706 numDataBytes:1276 numRSBlocks:81 blockID:20
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(numDataBytes[0], 16, @"Expected numDataBytes[0] to equal %d", 16);
  XCTAssertEqual(numEcBytes[0], 30, @"Expected numEcBytes[0] to equal %d", 30);
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:3706 numDataBytes:1276 numRSBlocks:81 blockID:80
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(numDataBytes[0], 16, @"Expected numDataBytes[0] to equal %d", 16);
  XCTAssertEqual(numEcBytes[0], 30, @"Expected numEcBytes[0] to equal %d", 30);
}

- (void)testInterleaveWithECBytes {
  const int dataBytesLen = 9;
  int8_t dataBytes[dataBytesLen] = {32, 65, 205, 69, 41, 220, 46, 128, 236};
  ZXBitArray *in = [[ZXBitArray alloc] init];
  for (int i = 0; i < dataBytesLen; i++) {
    [in appendBits:dataBytes[i] numBits:8];
  }
  ZXBitArray *out = [ZXEncoder interleaveWithECBytes:in numTotalBytes:26 numDataBytes:9 numRSBlocks:1 error:nil];
  const int expectedLen = 26;
  int8_t expected[expectedLen] = {
    // Data bytes.
    32, 65, 205, 69, 41, 220, 46, 128, 236,
    // Error correction bytes.
    42, 159, 74, 221, 244, 169, 239, 150, 138, 70,
    237, 85, 224, 96, 74, 219, 61,
  };
  XCTAssertEqual(out.sizeInBytes, expectedLen, @"Expected out sizeInBytes to equal %d", expectedLen);
  int8_t outArray[expectedLen];
  memset(outArray, 0, expectedLen * sizeof(int8_t));
  [out toBytes:0 array:outArray offset:0 numBytes:expectedLen];
  for (int x = 0; x < expectedLen; x++) {
    XCTAssertEqual(outArray[x], expected[x], @"Expected outArray[%d] to equal %d", x, expected[x]);
  }
  const int dataBytesLen2 = 62;
  int8_t dataBytes2[dataBytesLen2] = {
    67, 70, 22, 38, 54, 70, 86, 102, 118, 134, 150, 166, 182,
    198, 214, 230, 247, 7, 23, 39, 55, 71, 87, 103, 119, 135,
    151, 166, 22, 38, 54, 70, 86, 102, 118, 134, 150, 166,
    182, 198, 214, 230, 247, 7, 23, 39, 55, 71, 87, 103, 119,
    135, 151, 160, 236, 17, 236, 17, 236, 17, 236,
    17
  };
  in = [[ZXBitArray alloc] init];
  for (int i = 0; i < dataBytesLen2; i++) {
    [in appendBits:dataBytes2[i] numBits:8];
  }
  out = [ZXEncoder interleaveWithECBytes:in numTotalBytes:134 numDataBytes:62 numRSBlocks:4 error:nil];
  const int expectedLen2 = 134;
  int8_t expected2[expectedLen2] = {
    // Data bytes.
    67, 230, 54, 55, 70, 247, 70, 71, 22, 7, 86, 87, 38, 23, 102, 103, 54, 39,
    118, 119, 70, 55, 134, 135, 86, 71, 150, 151, 102, 87, 166,
    160, 118, 103, 182, 236, 134, 119, 198, 17, 150,
    135, 214, 236, 166, 151, 230, 17, 182,
    166, 247, 236, 198, 22, 7, 17, 214, 38, 23, 236, 39,
    17,
    // Error correction bytes.
    175, 155, 245, 236, 80, 146, 56, 74, 155, 165,
    133, 142, 64, 183, 132, 13, 178, 54, 132, 108, 45,
    113, 53, 50, 214, 98, 193, 152, 233, 147, 50, 71, 65,
    190, 82, 51, 209, 199, 171, 54, 12, 112, 57, 113, 155, 117,
    211, 164, 117, 30, 158, 225, 31, 190, 242, 38,
    140, 61, 179, 154, 214, 138, 147, 87, 27, 96, 77, 47,
    187, 49, 156, 214,
  };
  XCTAssertEqual(out.sizeInBytes, expectedLen2, @"Expected out sizeInBytes to equal %d", expectedLen2);
  int8_t outArray2[expectedLen2];
  memset(outArray2, 0, expectedLen2 * sizeof(int8_t));
  [out toBytes:0 array:outArray2 offset:0 numBytes:expectedLen2];
  for (int x = 0; x < expectedLen2; x++) {
    XCTAssertEqual(outArray2[x], expected2[x], @"Expected outArray[%d] to equal %d", x, expected2[x]);
  }
}

- (void)testAppendNumericBytes {
  // 1 = 01 = 0001 in 4 bits.
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendNumericBytes:@"1" bits:bits];
  NSString *expected = @" ...X";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  // 12 = 0xc = 0001100 in 7 bits.
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendNumericBytes:@"12" bits:bits];
  expected = @" ...XX..";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  // 123 = 0x7b = 0001111011 in 10 bits.
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendNumericBytes:@"123" bits:bits];
  expected = @" ...XXXX. XX";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  // 1234 = "123" + "4" = 0001111011 + 0100
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendNumericBytes:@"1234" bits:bits];
  expected = @" ...XXXX. XX.X..";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  // Empty.
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendNumericBytes:@"" bits:bits];
  XCTAssertEqualObjects([bits description], @"", @"Expected bits to equal \"\"");
}

- (void)testAppendAlphanumericBytes {
  // A = 10 = 0xa = 001010 in 6 bits
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendAlphanumericBytes:@"A" bits:bits error:nil];
  NSString *expected = @" ..X.X.";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  // AB = 10 * 45 + 11 = 461 = 0x1cd = 00111001101 in 11 bits
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendAlphanumericBytes:@"AB" bits:bits error:nil];
  expected = @" ..XXX..X X.X";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  // ABC = "AB" + "C" = 00111001101 + 001100
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendAlphanumericBytes:@"ABC" bits:bits error:nil];
  expected = @" ..XXX..X X.X..XX. .";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  // Empty.
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendAlphanumericBytes:@"" bits:bits error:nil];
  XCTAssertEqualObjects([bits description], @"", @"Expected bits to equal \"\"");
  // Invalid data.
  NSError *error;
  if ([ZXEncoder appendAlphanumericBytes:@"abc" bits:[[ZXBitArray alloc] init] error:&error] || error.code != ZXWriterError) {
    XCTFail(@"Expected ZXWriterError");
  }
}

- (void)testAppend8BitBytes {
  // 0x61, 0x62, 0x63
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXEncoder append8BitBytes:@"abc" bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING];
  NSString *expected = @" .XX....X .XX...X. .XX...XX";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  // Empty.
  bits = [[ZXBitArray alloc] init];
  [ZXEncoder append8BitBytes:@"" bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING];
  XCTAssertEqualObjects([bits description], @"", @"Expected bits to equal \"\"");
}

// Numbers are from page 21 of JISX0510:2004
- (void)testAppendKanjiBytes {
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  int8_t bytes[2] = {0x93,0x5f};
  [ZXEncoder appendKanjiBytes:[self shiftJISString:bytes bytesLen:2] bits:bits error:nil];
  NSString *expected = @" .XX.XX.. XXXXX";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  int8_t bytes2[2] = {0xe4,0xaa};
  [ZXEncoder appendKanjiBytes:[self shiftJISString:bytes2 bytesLen:2] bits:bits error:nil];
  expected = @" .XX.XX.. XXXXXXX. X.X.X.X. X.";
  XCTAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
}

// Numbers are from http://www.swetake.com/qr/qr3.html and
// http://www.swetake.com/qr/qr9.html
- (void)testGenerateECBytes {
  const int dataBytesLen = 9;
  int8_t dataBytes[dataBytesLen] = {32, 65, 205, 69, 41, 220, 46, 128, 236};
  int8_t *ecBytes = [ZXEncoder generateECBytes:dataBytes numDataBytes:dataBytesLen numEcBytesInBlock:17];
  const int expectedLen = 17;
  int expected[expectedLen] = {
    42, 159, 74, 221, 244, 169, 239, 150, 138, 70, 237, 85, 224, 96, 74, 219, 61
  };
  for (int x = 0; x < expectedLen; x++) {
    XCTAssertEqual(ecBytes[x] & 0xFF, expected[x], @"Expected exBytes[%d] to equal %d", x, expected[x]);
  }
  free(ecBytes);
  const int dataBytesLen2 = 15;
  int8_t dataBytes2[dataBytesLen2] = {67, 70, 22, 38, 54, 70, 86, 102, 118,
    134, 150, 166, 182, 198, 214};
  int8_t *ecBytes2 = [ZXEncoder generateECBytes:dataBytes2 numDataBytes:dataBytesLen2 numEcBytesInBlock:18];
  const int expectedLen2 = 18;
  int expected2[expectedLen2] = {
    175, 80, 155, 64, 178, 45, 214, 233, 65, 209, 12, 155, 117, 31, 140, 214, 27, 187
  };
  for (int x = 0; x < expectedLen2; x++) {
    XCTAssertEqual(ecBytes2[x] & 0xFF, expected2[x], @"Expected exBytes[%d] to equal %d", x, expected2[x]);
  }
  free(ecBytes2);
  // High-order zero coefficient case.
  const int dataBytesLen3 = 9;
  int8_t dataBytes3[dataBytesLen3] = {32, 49, 205, 69, 42, 20, 0, 236, 17};
  int8_t *ecBytes3 = [ZXEncoder generateECBytes:dataBytes3 numDataBytes:dataBytesLen3 numEcBytesInBlock:17];
  const int expectedLen3 = 17;
  int expected3[expectedLen3] = {
    0, 3, 130, 179, 194, 0, 55, 211, 110, 79, 98, 72, 170, 96, 211, 137, 213
  };
  for (int x = 0; x < expectedLen3; x++) {
    XCTAssertEqual(ecBytes3[x] & 0xFF, expected3[x], @"Expected exBytes[%d] to equal %d", x, expected3[x]);
  }
  free(ecBytes3);
}

- (void)testBugInBitVectorNumBytes {
  // There was a bug in BitVector.sizeInBytes() that caused it to return a
  // smaller-by-one value (ex. 1465 instead of 1466) if the number of bits
  // in the vector is not 8-bit aligned.  In QRCodeEncoder::InitQRCode(),
  // BitVector::sizeInBytes() is used for finding the smallest QR Code
  // version that can fit the given data.  Hence there were corner cases
  // where we chose a wrong QR Code version that cannot fit the given
  // data.  Note that the issue did not occur with MODE_8BIT_BYTE, as the
  // bits in the bit vector are always 8-bit aligned.
  //
  // Before the bug was fixed, the following test didn't pass, because:
  //
  // - MODE_NUMERIC is chosen as all bytes in the data are '0'
  // - The 3518-byte numeric data needs 1466 bytes
  //   - 3518 / 3 * 10 + 7 = 11727 bits = 1465.875 bytes
  //   - 3 numeric bytes are encoded in 10 bits, hence the first
  //     3516 bytes are encoded in 3516 / 3 * 10 = 11720 bits.
  //   - 2 numeric bytes can be encoded in 7 bits, hence the last
  //     2 bytes are encoded in 7 bits.
  // - The version 27 QR Code with the EC level L has 1468 bytes for data.
  //   - 1828 - 360 = 1468
  // - In InitQRCode(), 3 bytes are reserved for a header.  Hence 1465 bytes
  //   (1468 -3) are left for data.
  // - Because of the bug in BitVector::sizeInBytes(), InitQRCode() determines
  //   the given data can fit in 1465 bytes, despite it needs 1466 bytes.
  // - Hence QRCodeEncoder.encode() failed and returned false.
  //   - To be precise, it needs 11727 + 4 (getMode info) + 14 (length info) =
  //     11745 bits = 1468.125 bytes are needed (i.e. cannot fit in 1468
  //     bytes).
  NSMutableString *builder = [NSMutableString stringWithCapacity:3518];
  for (int x = 0; x < 3518; x++) {
    [builder appendString:@"0"];
  }
  ZXQRCode *qrCode = [ZXEncoder encode:builder ecLevel:[ZXErrorCorrectionLevel errorCorrectionLevelL] error:nil];
  XCTAssertNotNil(qrCode, @"Excepted QR code");
}

- (NSString *)shiftJISString:(int8_t *)bytes bytesLen:(int)bytesLen {
  return [[NSString alloc] initWithBytes:bytes length:bytesLen encoding:NSShiftJISStringEncoding];
}

@end
