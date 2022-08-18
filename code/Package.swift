//  Created by Shuwei Gan on 2021/8/1.
//  Copyright © 2021 Shuwei Gan. All rights reserved.

import PackageDescription

let package = Package(
    name: "PianoKeyboard",
    platforms: [
        .iOS("10.0")
    ],
    products: [
        .library(
            name: "PianoKeyboard",
            targets: ["PianoKeyboard"]
        )
    ],
    targets: [
        .target(
            name: "PianoKeyboard",
            path: "Source"
        )
    ]
)
