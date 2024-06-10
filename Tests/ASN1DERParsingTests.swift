// swiftlint:disable force_unwrapping
//
//  ASN1DERParsingTests.swift
//  Tests
//
//  Created by Daniel Egger on 07.02.18.
//
//  ---------------------------------------------------------------------------
//  Copyright 2019 Airside Mobile Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  ---------------------------------------------------------------------------
//

import XCTest
@testable import JOSESwift

extension ASN1DERParsingError: Equatable {
    public static func == (lhs: ASN1DERParsingError, rhs: ASN1DERParsingError) -> Bool {
        switch (lhs, rhs) {
        case (.incorrectLengthFieldLength, .incorrectLengthFieldLength):
            return true
        case (.incorrectValueLength, .incorrectValueLength):
            return true
        case (.incorrectTLVLength, .incorrectTLVLength):
            return true
        default:
            return false
        }
    }
}

class ASN1DERParsingTests: XCTestCase {

    // 02 81 81          ; INTEGER (81 Bytes)
    // |  00
    // |  8f e2 41 2a 08 e8 51 a8  8c b3 e8 53 e7 d5 49 50
    // |  b3 27 8a 2b cb ea b5 42  73 ea 02 57 cc 65 33 ee
    // |  88 20 61 a1 17 56 c1 24  18 e3 a8 08 d3 be d9 31
    // |  f3 37 0b 94 b8 cc 43 08  0b 70 24 f7 9c b1 8d 5d
    // |  d6 6d 82 d0 54 09 84 f8  9f 97 01 75 05 9c 89 d4
    // |  d5 c9 1e c9 13 d7 2a 6b  30 91 19 d6 d4 42 e0 c4
    // |  9d 7c 92 71 e1 b2 2f 5c  8d ee f0 f1 17 1e d2 5f
    // |  31 5b b1 9c bc 20 55 bf  3a 37 42 45 75 dc 90 65
    let intTLVLong = [UInt8](
        Data(base64Encoded: """
            AoGBAI/iQSoI6FGojLPoU+fVSVCzJ4ory+q1QnPqAlfMZTPuiCBhoRdWwSQY46gI077ZMfM3C5S4zEMIC3Ak95yxjV3WbYLQVAmE+J+XAXU\
            FnInU1ckeyRPXKmswkRnW1ELgxJ18knHhsi9cje7w8Rce0l8xW7GcvCBVvzo3QkV13JBl
            """
        )!
    )

    // 02 01             ; INTEGER (1 Bytes)
    // |  03
    let intTLVShort = [UInt8](
        Data(base64Encoded: "AgED")!
    )

    // 30 82 01 0a
    //   02 82 01 01
    //     00 88 00 f3 c4 c2 7e 97 f3 48 54 f6 ea cf d7
    //     a8 05 e9 d4 08 25 22 34 d7 d9 df b7 3a 81 42
    //     70 58 47 c9 47 21 9c 84 07 bd ea 6e 06 2e bd
    //     e9 ce 3d 80 dc 8a 38 31 22 9f f5 d0 d6 31 a9
    //     3a aa 44 7f 5d 89 63 4a 36 41 6d 70 21 41 a9
    //     f6 b0 80 79 ab 23 d6 ec d2 7b 5e 92 56 1e 86
    //     87 74 7c 04 37 d0 a3 db dc cb f9 6b 45 93 a9
    //     42 d6 b3 c3 98 d3 d1 4e 64 72 d1 cb 78 10 fe
    //     18 27 8f 4f 31 ca 0a 25 02 9b a2 0e fd c2 cd
    //     4a 74 3c cd 19 35 55 90 48 0b 07 85 4e 95 6f
    //     00 d7 ae 24 68 af 3e c4 c5 31 4e ac 92 52 d8
    //     a0 2d 30 d4 32 a8 d0 ff cd 52 16 0b 0d 9c c5
    //     2a 9f 1a 7c ed b2 83 ef ba 25 60 18 9a f3 ca
    //     fc 57 66 17 13 1d 49 82 5f 2d db 68 0d 36 1e
    //     a5 90 df 01 0e a9 64 6f f6 36 b9 2f 9c ee f9
    //     58 21 f4 87 e9 66 24 56 c4 8f b2 b0 3e 18 b2
    //     d1 a3 f4 74 ec 51 b1 be cd 8c e6 06 71 9e 69
    //     6f 7b
    //   02 03
    //     01 00 01
    let sequenceTLV = [UInt8](
        Data(base64Encoded: """
            MIIBCgKCAQEAiADzxMJ+l/NIVPbqz9eoBenUCCUiNNfZ37c6gUJwWEfJRyGchAe96m4GLr3pzj2A3Io4MSKf9dDWMak6qkR/XYljSjZBbXA\
            hQan2sIB5qyPW7NJ7XpJWHoaHdHwEN9Cj29zL+WtFk6lC1rPDmNPRTmRy0ct4EP4YJ49PMcoKJQKbog79ws1KdDzNGTVVkEgLB4VOlW8A16\
            4kaK8+xMUxTqySUtigLTDUMqjQ/81SFgsNnMUqnxp87bKD77olYBia88r8V2YXEx1Jgl8t22gNNh6lkN8BDqlkb/Y2uS+c7vlYIfSH6WYkV\
            sSPsrA+GLLRo/R07FGxvs2M5gZxnmlvewIDAQAB
            """
        )!
    )

    func testParsingIntTLVLong() {
        let tlv = intTLVLong

        let triplet = try! tlv.nextTLVTriplet()

        XCTAssertEqual(triplet.tag, 0x02)
        XCTAssertEqual(triplet.length, [ 0x81, 0x81 ])
        XCTAssertEqual(triplet.value, [
            0x00,
            0x8f, 0xe2, 0x41, 0x2a, 0x08, 0xe8, 0x51, 0xa8, 0x8c, 0xb3, 0xe8, 0x53, 0xe7, 0xd5, 0x49, 0x50,
            0xb3, 0x27, 0x8a, 0x2b, 0xcb, 0xea, 0xb5, 0x42, 0x73, 0xea, 0x02, 0x57, 0xcc, 0x65, 0x33, 0xee,
            0x88, 0x20, 0x61, 0xa1, 0x17, 0x56, 0xc1, 0x24, 0x18, 0xe3, 0xa8, 0x08, 0xd3, 0xbe, 0xd9, 0x31,
            0xf3, 0x37, 0x0b, 0x94, 0xb8, 0xcc, 0x43, 0x08, 0x0b, 0x70, 0x24, 0xf7, 0x9c, 0xb1, 0x8d, 0x5d,
            0xd6, 0x6d, 0x82, 0xd0, 0x54, 0x09, 0x84, 0xf8, 0x9f, 0x97, 0x01, 0x75, 0x05, 0x9c, 0x89, 0xd4,
            0xd5, 0xc9, 0x1e, 0xc9, 0x13, 0xd7, 0x2a, 0x6b, 0x30, 0x91, 0x19, 0xd6, 0xd4, 0x42, 0xe0, 0xc4,
            0x9d, 0x7c, 0x92, 0x71, 0xe1, 0xb2, 0x2f, 0x5c, 0x8d, 0xee, 0xf0, 0xf1, 0x17, 0x1e, 0xd2, 0x5f,
            0x31, 0x5b, 0xb1, 0x9c, 0xbc, 0x20, 0x55, 0xbf, 0x3a, 0x37, 0x42, 0x45, 0x75, 0xdc, 0x90, 0x65
        ])
    }

    func testParsingIntTLVShort() {
        let tlv = intTLVShort

        let triplet = try! tlv.nextTLVTriplet()

        XCTAssertEqual(triplet.tag, 0x02)
        XCTAssertEqual(triplet.length, [ 0x01 ])
        XCTAssertEqual(triplet.value, [ 0x03 ])
    }

    func testParsingSequenceTLV() {
        let tlv = sequenceTLV

        let triplet = try! tlv.nextTLVTriplet()

        XCTAssertEqual(triplet.tag, 0x30)
        XCTAssertEqual(triplet.length, [ 0x82, 0x01, 0x0a ])
        XCTAssertEqual(triplet.value, [
            0x02, 0x82, 0x01, 0x01, 0x00, 0x88, 0x00, 0xf3, 0xc4, 0xc2, 0x7e, 0x97, 0xf3,
            0x48, 0x54, 0xf6, 0xea, 0xcf, 0xd7, 0xa8, 0x05, 0xe9, 0xd4, 0x08, 0x25, 0x22,
            0x34, 0xd7, 0xd9, 0xdf, 0xb7, 0x3a, 0x81, 0x42, 0x70, 0x58, 0x47, 0xc9, 0x47,
            0x21, 0x9c, 0x84, 0x07, 0xbd, 0xea, 0x6e, 0x06, 0x2e, 0xbd, 0xe9, 0xce, 0x3d,
            0x80, 0xdc, 0x8a, 0x38, 0x31, 0x22, 0x9f, 0xf5, 0xd0, 0xd6, 0x31, 0xa9, 0x3a,
            0xaa, 0x44, 0x7f, 0x5d, 0x89, 0x63, 0x4a, 0x36, 0x41, 0x6d, 0x70, 0x21, 0x41,
            0xa9, 0xf6, 0xb0, 0x80, 0x79, 0xab, 0x23, 0xd6, 0xec, 0xd2, 0x7b, 0x5e, 0x92,
            0x56, 0x1e, 0x86, 0x87, 0x74, 0x7c, 0x04, 0x37, 0xd0, 0xa3, 0xdb, 0xdc, 0xcb,
            0xf9, 0x6b, 0x45, 0x93, 0xa9, 0x42, 0xd6, 0xb3, 0xc3, 0x98, 0xd3, 0xd1, 0x4e,
            0x64, 0x72, 0xd1, 0xcb, 0x78, 0x10, 0xfe, 0x18, 0x27, 0x8f, 0x4f, 0x31, 0xca,
            0x0a, 0x25, 0x02, 0x9b, 0xa2, 0x0e, 0xfd, 0xc2, 0xcd, 0x4a, 0x74, 0x3c, 0xcd,
            0x19, 0x35, 0x55, 0x90, 0x48, 0x0b, 0x07, 0x85, 0x4e, 0x95, 0x6f, 0x00, 0xd7,
            0xae, 0x24, 0x68, 0xaf, 0x3e, 0xc4, 0xc5, 0x31, 0x4e, 0xac, 0x92, 0x52, 0xd8,
            0xa0, 0x2d, 0x30, 0xd4, 0x32, 0xa8, 0xd0, 0xff, 0xcd, 0x52, 0x16, 0x0b, 0x0d,
            0x9c, 0xc5, 0x2a, 0x9f, 0x1a, 0x7c, 0xed, 0xb2, 0x83, 0xef, 0xba, 0x25, 0x60,
            0x18, 0x9a, 0xf3, 0xca, 0xfc, 0x57, 0x66, 0x17, 0x13, 0x1d, 0x49, 0x82, 0x5f,
            0x2d, 0xdb, 0x68, 0x0d, 0x36, 0x1e, 0xa5, 0x90, 0xdf, 0x01, 0x0e, 0xa9, 0x64,
            0x6f, 0xf6, 0x36, 0xb9, 0x2f, 0x9c, 0xee, 0xf9, 0x58, 0x21, 0xf4, 0x87, 0xe9,
            0x66, 0x24, 0x56, 0xc4, 0x8f, 0xb2, 0xb0, 0x3e, 0x18, 0xb2, 0xd1, 0xa3, 0xf4,
            0x74, 0xec, 0x51, 0xb1, 0xbe, 0xcd, 0x8c, 0xe6, 0x06, 0x71, 0x9e, 0x69, 0x6f,
            0x7b, 0x02, 0x03, 0x01, 0x00, 0x01
        ])
    }

    func testReadingLongInt() {
        let value = try! intTLVLong.read(.integer)

        XCTAssertEqual(value, [
            0x00,
            0x8f, 0xe2, 0x41, 0x2a, 0x08, 0xe8, 0x51, 0xa8, 0x8c, 0xb3, 0xe8, 0x53, 0xe7, 0xd5, 0x49, 0x50,
            0xb3, 0x27, 0x8a, 0x2b, 0xcb, 0xea, 0xb5, 0x42, 0x73, 0xea, 0x02, 0x57, 0xcc, 0x65, 0x33, 0xee,
            0x88, 0x20, 0x61, 0xa1, 0x17, 0x56, 0xc1, 0x24, 0x18, 0xe3, 0xa8, 0x08, 0xd3, 0xbe, 0xd9, 0x31,
            0xf3, 0x37, 0x0b, 0x94, 0xb8, 0xcc, 0x43, 0x08, 0x0b, 0x70, 0x24, 0xf7, 0x9c, 0xb1, 0x8d, 0x5d,
            0xd6, 0x6d, 0x82, 0xd0, 0x54, 0x09, 0x84, 0xf8, 0x9f, 0x97, 0x01, 0x75, 0x05, 0x9c, 0x89, 0xd4,
            0xd5, 0xc9, 0x1e, 0xc9, 0x13, 0xd7, 0x2a, 0x6b, 0x30, 0x91, 0x19, 0xd6, 0xd4, 0x42, 0xe0, 0xc4,
            0x9d, 0x7c, 0x92, 0x71, 0xe1, 0xb2, 0x2f, 0x5c, 0x8d, 0xee, 0xf0, 0xf1, 0x17, 0x1e, 0xd2, 0x5f,
            0x31, 0x5b, 0xb1, 0x9c, 0xbc, 0x20, 0x55, 0xbf, 0x3a, 0x37, 0x42, 0x45, 0x75, 0xdc, 0x90, 0x65
        ])
    }

    func testReadingShortInt() {
        let value = try! intTLVShort.read(.integer)

        XCTAssertEqual(value, [ 0x03 ])
    }

    func testReadingSequence() {
        let value = try! sequenceTLV.read(.sequence)

        XCTAssertEqual(value, [
            0x02, 0x82, 0x01, 0x01, 0x00, 0x88, 0x00, 0xf3, 0xc4, 0xc2, 0x7e, 0x97, 0xf3,
            0x48, 0x54, 0xf6, 0xea, 0xcf, 0xd7, 0xa8, 0x05, 0xe9, 0xd4, 0x08, 0x25, 0x22,
            0x34, 0xd7, 0xd9, 0xdf, 0xb7, 0x3a, 0x81, 0x42, 0x70, 0x58, 0x47, 0xc9, 0x47,
            0x21, 0x9c, 0x84, 0x07, 0xbd, 0xea, 0x6e, 0x06, 0x2e, 0xbd, 0xe9, 0xce, 0x3d,
            0x80, 0xdc, 0x8a, 0x38, 0x31, 0x22, 0x9f, 0xf5, 0xd0, 0xd6, 0x31, 0xa9, 0x3a,
            0xaa, 0x44, 0x7f, 0x5d, 0x89, 0x63, 0x4a, 0x36, 0x41, 0x6d, 0x70, 0x21, 0x41,
            0xa9, 0xf6, 0xb0, 0x80, 0x79, 0xab, 0x23, 0xd6, 0xec, 0xd2, 0x7b, 0x5e, 0x92,
            0x56, 0x1e, 0x86, 0x87, 0x74, 0x7c, 0x04, 0x37, 0xd0, 0xa3, 0xdb, 0xdc, 0xcb,
            0xf9, 0x6b, 0x45, 0x93, 0xa9, 0x42, 0xd6, 0xb3, 0xc3, 0x98, 0xd3, 0xd1, 0x4e,
            0x64, 0x72, 0xd1, 0xcb, 0x78, 0x10, 0xfe, 0x18, 0x27, 0x8f, 0x4f, 0x31, 0xca,
            0x0a, 0x25, 0x02, 0x9b, 0xa2, 0x0e, 0xfd, 0xc2, 0xcd, 0x4a, 0x74, 0x3c, 0xcd,
            0x19, 0x35, 0x55, 0x90, 0x48, 0x0b, 0x07, 0x85, 0x4e, 0x95, 0x6f, 0x00, 0xd7,
            0xae, 0x24, 0x68, 0xaf, 0x3e, 0xc4, 0xc5, 0x31, 0x4e, 0xac, 0x92, 0x52, 0xd8,
            0xa0, 0x2d, 0x30, 0xd4, 0x32, 0xa8, 0xd0, 0xff, 0xcd, 0x52, 0x16, 0x0b, 0x0d,
            0x9c, 0xc5, 0x2a, 0x9f, 0x1a, 0x7c, 0xed, 0xb2, 0x83, 0xef, 0xba, 0x25, 0x60,
            0x18, 0x9a, 0xf3, 0xca, 0xfc, 0x57, 0x66, 0x17, 0x13, 0x1d, 0x49, 0x82, 0x5f,
            0x2d, 0xdb, 0x68, 0x0d, 0x36, 0x1e, 0xa5, 0x90, 0xdf, 0x01, 0x0e, 0xa9, 0x64,
            0x6f, 0xf6, 0x36, 0xb9, 0x2f, 0x9c, 0xee, 0xf9, 0x58, 0x21, 0xf4, 0x87, 0xe9,
            0x66, 0x24, 0x56, 0xc4, 0x8f, 0xb2, 0xb0, 0x3e, 0x18, 0xb2, 0xd1, 0xa3, 0xf4,
            0x74, 0xec, 0x51, 0xb1, 0xbe, 0xcd, 0x8c, 0xe6, 0x06, 0x71, 0x9e, 0x69, 0x6f,
            0x7b, 0x02, 0x03, 0x01, 0x00, 0x01
        ])
    }

    func testReadingWrongType() {
        let value = try? intTLVShort.read(.sequence)

        XCTAssertNil(value)
    }

    func testSkippingLongInt() {
        let tlv = intTLVLong + intTLVShort

        let remainder = try! tlv.skip(.integer)

        XCTAssertEqual(remainder, intTLVShort)
    }

    func testShortInt() {
        let tlv = intTLVShort + intTLVLong

        let remainder = try! tlv.skip(.integer)

        XCTAssertEqual(remainder, intTLVLong)
    }

    func testSkippingSequence() {
        let tlv = sequenceTLV + intTLVLong

        let remainder = try! tlv.skip(.sequence)

        XCTAssertEqual(remainder, intTLVLong)
    }

    func testSkippingWrongType() {
        let tlv = intTLVLong + intTLVShort

        let remainder = try? tlv.skip(.sequence)

        XCTAssertNil(remainder)
    }

    func testWrongValueLength() {
        XCTAssertThrowsError(try ([
            0x02, 0x04 /* should be 0x03 */, 0x01, 0x00, 0x01
        ] as [UInt8]).nextTLVTriplet()) { error in
            XCTAssertEqual(error as? ASN1DERParsingError, ASN1DERParsingError.incorrectValueLength)
        }
    }

    func testWrongLengthLength() {
        XCTAssertThrowsError(try ([
            0x02, 0x83 /* should be 0x81 */, 0x01, 0x01
        ] as [UInt8]).nextTLVTriplet()) { error in
            XCTAssertEqual(error as? ASN1DERParsingError, ASN1DERParsingError.incorrectLengthFieldLength)
        }
    }

    func testWrongTLVLength() {
        XCTAssertThrowsError(try ([
            0x02
            ] as [UInt8]).nextTLVTriplet()) { error in
                XCTAssertEqual(error as? ASN1DERParsingError, ASN1DERParsingError.incorrectTLVLength)
        }
    }

}
// swiftlint:enable force_unwrapping
