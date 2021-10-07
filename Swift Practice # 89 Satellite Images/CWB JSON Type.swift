//
//  CWB JSON Type.swift
//  Swift Practice # 89 Satellite Images
//
//  Created by Dogpa's MBAir M1 on 2021/10/7.
//

import Foundation



struct CWBJSONFirst:Codable {               //第一層cwbopendata
    let cwbopendata: CWBJSONSecond
}

struct CWBJSONSecond:Codable {              //第二層dataset
    let dataset : CWBJSONThird
}


struct CWBJSONThird:Codable {               //第三層resource
    let resource: CWBJSONUrl
}


struct CWBJSONUrl:Codable {                 //第四層網址uri
    let uri: URL
}
