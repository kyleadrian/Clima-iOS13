//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchTextField.delegate = self; // this says the text field should "report" back to or notify the view controller on any actions happening with it.
        weatherManager.delegate = self;
        locationManager.delegate = self;
        
        // it's always a good idea to call your instance methods AFTER you've assigned delegated like above.
        locationManager.requestWhenInUseAuthorization();
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.requestLocation();
    }
    
}

// MARK: - WeatherManagerDelegate

extension WeatherViewController: UITextFieldDelegate {
    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.requestLocation();
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Typesomething here"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // we use an if let because textfield.text is optional and our function requires a definite string
        if let city = textField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        
        searchTextField.text = ""
    }
}

// MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    // By convention when calling on a delegate method, swift adds an underscore and the first argument is the identity of the object that CALLS the method, i.e where is the function created and called.
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        //We have to wrap any View Controller actions taken on asynchronously retrieved data in a Dispatch.main.async closure
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName);
            self.cityLabel.text = weather.cityName;
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}


// MARK: - LocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // stop looking for the location when we find it. 
            locationManager.stopUpdatingLocation()
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error)
    }
}
