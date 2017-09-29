//
//  ViewController.swift
//  Flickr API
//
//  Created by Eliot Arntz on 9/1/17.
//  Copyright © 2017 Eliot Arntz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    var searchResults: [FlickrObject] = []
    
    let cellIdentifier = "Cell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        
        let url = URL(string: "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=" + textField.text!)
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let results = json["items"] as? [[String: Any]] {
                    for result in results {
                        
                        var flickrObj = FlickrObject()
                        flickrObj.title = result["title"] as! String!
                        //                        var dictionary = result["media"] as! Dictionary
                        let dictionary: [String: String] = (result["media"] as? [String: String])!
                        flickrObj.imageName = dictionary["m"]
                        self.searchResults.append(flickrObj)
                        
                        print(flickrObj)
                        print(self.searchResults.count)
                        //                        if let name = result["name"] as? String {
                        //                            results.append(name)
                        //                        }
                    }
                    self.tableView.reloadData()
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
            
            print (data)
            
        }
        
        task.resume()
        
    }
    
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UITableViewCell else {
            
            return UITableViewCell() }
        
        let flickrObject: FlickrObject = searchResults[indexPath.row] as! FlickrObject
        
        print(cell)
        cell.textLabel?.text = flickrObject.title
        
        var imageURL = URL(string: flickrObject.imageName)
        
        downloadImage(url: imageURL!, imageView: cell.imageView!)
        return cell

    }
    
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL, imageView: UIImageView) {
    
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    
}



//"title": "IMG_3624.jpg",
//"link": "https:\/\/www.flickr.com\/photos\/stevedrust\/36134815454\/",
//"media": {
//				"m": "https:\/\/farm5.staticflickr.com\/4386\/36134815454_8a3ce4df69_m.jpg"
//},
//"date_taken": "2017-09-01T19:14:14-08:00",
//"description": " <p><a href=\"https:\/\/www.flickr.com\/people\/stevedrust\/\">stevedrust<\/a> posted a photo:<\/p> <p><a href=\"https:\/\/www.flickr.com\/photos\/stevedrust\/36134815454\/\" title=\"IMG_3624.jpg\"><img src=\"https:\/\/farm5.staticflickr.com\/4386\/36134815454_8a3ce4df69_m.jpg\" width=\"240\" height=\"180\" alt=\"IMG_3624.jpg\" \/><\/a><\/p> ",
//"published": "2017-09-02T02:14:14Z",
//"author": "nobody@flickr.com (\"stevedrust\")",
//"author_id": "41829202@N07",
//"tags": ""






//Create an app that allows a user to search for images based on tags, with the flickr API.
//
//The relevant endpoint is: https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1
//
//If the user searches for images by the tag cookies, then the relevant endpoint would be: https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=cookies
//
//Feel free to use open source libraries
//
//Some requirements…
//- User must be able to input their search query to
//Some requirements…
//- User must be able to input their search query to search for images by tag
//- The app should display image results in a feed-like fashion
//- Each feed item should display the title, along with when the image was taken
