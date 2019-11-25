//
//  ViewController.swift
//  WeatherApp
//
//  Created by Tanaji Patil on .
//  Copyright © 2019 TanajiPatil. All rights reserved.
//

import UIKit

// MARK: Weather Info tableView cell
class WeatherInfoCell: UITableViewCell {
    
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var visibility: UILabel!
    @IBOutlet weak var temparature: UILabel!
    @IBOutlet weak var cloud: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var sunrise: UILabel!
    @IBOutlet weak var sunset: UILabel!
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties Declaration
    @IBOutlet weak var favoriteOutlet: UIButton!
    @IBOutlet weak var cityNameOutlet: UITextField!
    @IBOutlet weak var weatherInfoTableView: UITableView!
    @IBOutlet weak var message: UILabel!
    
    var strLabel = UILabel()
    var activityIndicator = UIActivityIndicatorView()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    var weatherInfoDict = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Weather Information"
        
        message.isHidden = true
    }
    
    // MARK: Search City by Name
    @IBAction func SerachAction(_ sender: Any) {
        message.isHidden = true
        if (cityNameOutlet.text != "") {
            // Call API for Weather Details.
            //self.getWeatherInformation("2019/11/26")
            
            if(UserDefaults.standard.string(forKey: "city_name") != nil){
                let favoriteCity = UserDefaults.standard.string(forKey: "city_name")
                print(favoriteCity ?? "")
                
                if favoriteCity == cityNameOutlet.text {
                    favoriteOutlet.setImage(UIImage(named: "Favorite_filled"), for: .normal)
                    message.isHidden = false
                }
                else{
                    favoriteOutlet.setImage(UIImage(named: "Favorite"), for: .normal)
                }
            }
            
        }
        else{
            let alert = UIAlertController(title: nil, message: "Please Enter City Name.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: tableView delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return weatherInfoDict.count
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID_WeatherInfoCell") as! WeatherInfoCell
        
        // from weatherInfoDict set data like this
        //let data = self.weatherInfoDict[indexPath.row] as! [String:Any]
        //let date = data["dateTime"] as? String
        //cell.dateTime.text = date
        
        // Displayed Static data
        cell.dateTime.text = "Date Time: 2019/11/26  11:12:00 AM"
        cell.weatherDescription.text = " Description: Scattered clouds"
        cell.visibility.text = "Visibility: 80"
        cell.temparature.text = "Temparature: 25"
        cell.cloud.text = "Cloud: 40%"
        cell.windSpeed.text = "WindSpeed: 3.6"
        cell.humidity.text = "Humidity: 14"
        cell.sunrise.text = "Sunrise: 06:12:00 AM"
        cell.sunset.text = "Sunset: 06:20:00 PM"
        cell.backgroundColor = .random()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 116
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0.1
    }
    
    // MARK: Fovorite city
    @IBAction func FavouriteAction(_ sender: Any) {
        
        if (favoriteOutlet.imageView?.image == UIImage(named: "Favorite_filled")){
            favoriteOutlet.setImage(UIImage(named: "Favorite"), for: .normal)
        }
        else{
            if cityNameOutlet.text != "" {
                UserDefaults.standard.set("\(self.cityNameOutlet.text!)", forKey: "city_name")
                favoriteOutlet.setImage(UIImage(named: "Favorite_filled"), for: .normal)
            }
        }
    }
    
    // MARK: Share Data
    @IBAction func ShareAction(_ sender: Any) {
        let message = "Any Data" // we can share text, url, image, video, zip etc.
        let objectsToShare = [message] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: Get Weather Information from server.
    func getWeatherInformation(_ current_date:String)
    {
        self.activityIndicator("Please Wait Loading Info ...")
        
        let scriptUrl = "URL"
        let urlWithParams = scriptUrl + "?=current_date\(current_date)"
        
        let encoded = urlWithParams.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        let myUrl = NSURL(string: encoded!)
        
        let request = NSMutableURLRequest(url: myUrl! as URL)
        print(request)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            guard let data = data, error == nil else {
                print("error getDataFromServer=\(String(describing: error))")
                
                let alert = UIAlertController(title: nil, message: "Please check the network connection.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                DispatchQueue.main.async
                {
                    self.effectView.removeFromSuperview()
                }
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            DispatchQueue.main.async{
                let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    print("responseString = \(String(describing: responseString))")
                    self.weatherInfoDict =  self.convertToDictionary(text: responseString! as String)! as NSDictionary

                    let responseCode = self.weatherInfoDict["response_code"] as! Int
                    if (responseCode == 200)
                    {
                        
                        // reload tableview.
                        self.effectView.removeFromSuperview()
                    }
                    else{
                        let alert = UIAlertController(title: nil, message: "Please check the City Name.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.effectView.removeFromSuperview()
                    }
                }
            }
            task.resume()
    }
    
    // MARK: Convert string to Any
    func convertToDictionary(text: String) -> [String: Any]?{
        if let data = text.data(using: .utf8){
            do{
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            }
            catch{
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    // MARK: Activity Indicator.
    func activityIndicator(_ title: String)
    {
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 180, height: 46))
        strLabel.text = title
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        strLabel.textColor = UIColor.black
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 230, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    /*
     // Sample Response from API
     {
         "response_code": 200
         "weather_info": [
             {
                 "id": 001,
                 "dateTime": "2019/11/26  11:12:00 AM",
                 "description": "scattered clouds",
                 "visibility": 10000,
                 "temp": "25",
                 "cloudCover": "40%",
                 "windSpeed": "3.6"
                 "humidity": "20",
                 "sunrise": "06:12:00 AM",
                 "sunset": "06:20:00 PM"
             }
             {
                 "id": 002,
                 "dateTime": "2019/11/27  11:12:00 AM",
                 "description": "scattered clouds",
                 "visibility": 10000,
                 "temp": "22",
                 "cloudCover": "50%",
                 "windSpeed": "3.0"
                 "humidity": "16",
                 "sunrise": "06:10:00 AM",
                 "sunset": "06:19:00 PM"
             }
             {
                 "id": 003,
                 "dateTime": "2019/11/28  11:12:00 AM",
                 "description": "scattered clouds",
                 "visibility": 10000,
                 "temp": "24",
                 "cloudCover": "20%",
                 "windSpeed": "3.0"
                 "humidity": "20",
                 "sunrise": "06:09:00 AM",
                 "sunset": "06:23:00 PM"
             }
             {
                "id": 004,
                 "dateTime": "2019/11/29  11:12:00 AM",
                 "description": "scattered clouds",
                 "visibility": 10000,
                 "temp": "26",
                 "cloudCover": "30%",
                 "windSpeed": "3.6"
                 "humidity": "23",
                 "sunrise": "06:14:00 AM",
                 "sunset": "06:22:00 PM"
             }
             {
                 "id": 005,
                 "dateTime": "2019/11/30  11:12:00 AM",
                 "description": "scattered clouds",
                 "visibility": 10000,
                 "temp": "25",
                 "cloudCover": "40%",
                 "windSpeed": "3.9"
                 "humidity": "18",
                 "sunrise": "06:12:00 AM",
                 "sunset": "06:21:00 PM"
             }]
     }
     
     */
}

// MARK: For table view cell Random color
extension CGFloat
{
    static func random() -> CGFloat
    {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor
{
    static func random() -> UIColor
    {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

