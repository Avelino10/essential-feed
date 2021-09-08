//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 08/09/2021.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
