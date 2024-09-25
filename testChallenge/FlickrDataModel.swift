//
//  FlickrDataModel.swift
//  testChallenge
//
//  Created by Wim Tanudjaja on 9/16/24.
//


import Foundation

struct FlickrImage: Codable, Identifiable {
    var id = UUID() // Generate a unique ID for SwiftUI's use
    let title: String
    let media: Media
    let author: String
    let description: String
    let published: String
    
    private enum CodingKeys: String, CodingKey {
        case title, media, author, description, published
    }
}

struct Media: Codable {
    let m: String
}

struct FlickrResponse: Codable {
    let items: [FlickrImage]
}
