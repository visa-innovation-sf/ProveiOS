//
//  VFPResponse.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 13/12/2021.
//

import Foundation

struct VFPResponse: Codable {
    let vfp: String

    var description: String {
        return "VFP Token: \(vfp)"
    }
}
