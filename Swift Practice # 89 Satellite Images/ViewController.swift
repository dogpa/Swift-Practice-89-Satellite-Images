//
//  ViewController.swift
//  Swift Practice # 89 Satellite Images
//
//  Created by Dogpa's MBAir M1 on 2021/10/7.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var photoTypeSegment: UISegmentedControl!            //衛星照或是雷達照或是降雨雷達
    
    @IBOutlet weak var satelliteRangeSegment: UISegmentedControl!       //衛星範圍
    
    @IBOutlet weak var satelliteTypeSegment: UISegmentedControl!        //衛星照片種類
    
    @IBOutlet weak var terrainTypeSegment: UISegmentedControl!          //有無地形
    
    @IBOutlet weak var rainRadarLoactionSegment: UISegmentedControl!    //雷達站地點
    
    @IBOutlet weak var CWBPhotoImageView: UIImageView!                  //顯示照片
    
    let satelliteDist = ["20":"O-C0042-007",    //全球可見光
                         "10":"O-B0032-001",    //東亞可見光
                         "00":"O-C0042-008",    //台灣可見光
                     
                         "21":"O-C0042-001",    //全球彩色
                         "11":"O-B0032-002",    //東亞彩色
                         "01":"O-C0042-002",    //台灣彩色
                     
                         "22":"O-C0042-005",    //全球色調強化
                         "12":"O-B0032-004",    //東亞色調強化
                         "02":"O-C0042-006",    //台灣色調強化
                     
                         "23":"O-C0042-003",    //全球黑白
                         "13":"O-B0032-003",    //東亞黑白
                         "03":"O-C0042-004",    //台灣黑白
                     
                         "5":"O-A0058-004",     //雷達有地形
                         "6":"O-A0058-003",     //雷達無地形
                     
                         "7":"O-A0084-001",     //樹林雷達
                         "8":"O-A0084-002",     //南屯雷達
                         "9":"O-A0084-003",     //林園雷達
    
    ]   //氣象局Format使用
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCWBPhoto(index: satelliteDist["00"]!)                                    //執行抓圖抓出台灣可見光的衛星雲圖
        segmentShowOrNot(Range: false, Type: false, terrain: true, location: true)  //設定各自的segmentShowOrNot是否顯示
        
    }
    
    //自定義抓中央氣象局圖片資料的Function 參數帶入為中央意象局ＪＳＯＮ指定的資料名稱
    //資料名稱透過自訂義字典來比對後帶入
    func getCWBPhoto (index:String) {
        let urlFromArray = "https://opendata.cwb.gov.tw/fileapi/v1/opendataapi/\(index)?Authorization=&format=JSON"
        //print(index)
        //檢查網址網址是否有中文透過if let 指派 urlString 取得剛剛取得的urlFromArray轉碼網址
        if let urlString = urlFromArray.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            //透過 if let 指派JSONUrl為URL類別的網址
            if let JSONUrl = URL(string: urlString){
                //透過URLSession將剛剛指派完成的JSONUrl轉型取得資料
                URLSession.shared.dataTask(with: JSONUrl) { data, response, error in
                    //指派data為DATA類別
                    if let date = data {
                        //將decoder指派為JSONDecoder()
                        let decoder = JSONDecoder()
                        //透過.dateDecodingStrategy取得日期格式為iso8601
                        decoder.dateDecodingStrategy = .iso8601
                        //使用do catch來指派searchResponse為date解碼後的SearchResponse自身
                        //而將指派為自定義型別的singerDataFromASA的資料來源透過
                        //指派完成的searchResponse的searchResponse.cwbopendata.dataset.resource.uri來取得資料使用
                        do {
                            let searchResponse = try decoder.decode(CWBJSONFirst.self , from: date)
                            //print(searchResponse.cwbopendata.dataset.resource.uri)
                            //透過主執行緒來重置CWBPhotoImageView.image
                            DispatchQueue.main.async {
                                //從網路透過自定義參數抓到中央氣象局的url後將照片顯示在CWBPhotoImageView
                                URLSession.shared.dataTask(with: searchResponse.cwbopendata.dataset.resource.uri) { data, response , error in
                                if let data = data {
                                    DispatchQueue.main.async {
                                        self.CWBPhotoImageView.image = UIImage(data: data)
                                        }
                                    }
                                }.resume()
                            }
                        }catch{
                            //若無法do或是失敗列印失敗原因
                            print(error)
                        }
                    }
                }.resume()
            }
        }
    }
    

    //自定義Function用於決定每個segment是否顯示
    func segmentShowOrNot (Range:Bool, Type:Bool, terrain: Bool, location:Bool) {
        satelliteRangeSegment.isHidden = Range
        satelliteTypeSegment.isHidden = Type
        terrainTypeSegment.isHidden = terrain
        rainRadarLoactionSegment.isHidden = location
    }
    
    //自定義Func用於從雷達回波與降雨雷達拉回到衛星雲圖後的抓圖使用
    func checkSegmentIndexInSatallite () {
        let location = satelliteRangeSegment.selectedSegmentIndex
        let type = photoTypeSegment.selectedSegmentIndex
        
        getCWBPhoto(index: satelliteDist["\(location)\(type)"]!)
    }
    
    //自定義Function用於segment拉回雷達回波值偵測地形segment後抓圖
    func checkSegmentIndexInRadar () {
        let trrrain = terrainTypeSegment.selectedSegmentIndex
        getCWBPhoto(index: satelliteDist["\(trrrain+5)"]!)
        
    }
    
    //自定義Function用於segment拉回降雨雷達後偵測雷達站地點segment後抓圖
    func cehckSegmentIndexInRain () {
        let rainLocation = rainRadarLoactionSegment.selectedSegmentIndex
        getCWBPhoto(index: satelliteDist["\(rainLocation+7)"]!)
    }
    
    
    //選擇衛星雲圖或降雨雷達或雷達回波的segment的IBAction
    @IBAction func photoTypeChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            segmentShowOrNot(Range: false, Type: false, terrain: true, location: true)
            checkSegmentIndexInSatallite ()
        }else if sender.selectedSegmentIndex == 1 {
            segmentShowOrNot(Range: true, Type: true, terrain: false, location: true)
            checkSegmentIndexInRadar ()
        }else{
            segmentShowOrNot(Range: true, Type: true, terrain: true, location: false)
            cehckSegmentIndexInRain ()
        }
    }
    
    
    //衛星雲圖的地點選項的IBAction
    @IBAction func satelliteLoactionPhotoGet(_ sender: UISegmentedControl) {
        let selfIndex = sender.selectedSegmentIndex
        let typeIndex = satelliteTypeSegment.selectedSegmentIndex
        getCWBPhoto(index: satelliteDist["\(selfIndex)\(typeIndex)"]!)
        
    }
    
    
    //衛星雲圖的圖片種類選項的IBAction
    @IBAction func satellitePhotoChoose(_ sender: UISegmentedControl) {
        let locationType = satelliteRangeSegment.selectedSegmentIndex
        let satellitePhotoType = sender.selectedSegmentIndex
        getCWBPhoto(index: satelliteDist["\(locationType)\(satellitePhotoType)"]!)
    }
    
    
    
    //雷達回波的地形選項的IBAction
    @IBAction func radarPhotoGet(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            getCWBPhoto(index: satelliteDist["5"]!)
        }else if sender.selectedSegmentIndex == 1 {
            getCWBPhoto(index: satelliteDist["6"]!)
        }
    }
    
    
    //降雨雷達的雷達地點選項的IBAction
    @IBAction func rainRadarPhotoGet(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            getCWBPhoto(index: satelliteDist["7"]!)
        }else if sender.selectedSegmentIndex == 1 {
            getCWBPhoto(index: satelliteDist["8"]!)
        }else{
            getCWBPhoto(index: satelliteDist["9"]!)
        }
    }
    
}

