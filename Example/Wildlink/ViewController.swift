//
//  ViewController.swift
//  Wildlink
//
//  Copyright (c) 2019 Wildfire Systems. All rights reserved.
//

import UIKit
import Alamofire
import Wildlink

class ViewController: UIViewController {
    
    @IBOutlet weak var urlOutlet: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let urlText = urlOutlet.text else { return }
        sleep(5)
        Wildlink.shared.createVanityURL(from: urlText) { (url, error) in
            if let url = url {
                DispatchQueue.main.async {
                    self.urlOutlet.text = url.vanityURL.absoluteString
                }
                sleep(2)
                Wildlink.shared.getCommissionSummary({ (stats, error) in
                    if let error = error {
                        log(error, with: "Commission summary")
                    }
                    print("Commission summary results: \(String(describing: stats))")
                })
                Wildlink.shared.getMerchantBy("5476062", { (merchant, error) in
                    if let error = error {
                        log(error, with: "Merchant data")
                    }
                    print("Merchant data results: \(String(describing: merchant))")
                })
                Wildlink.shared.searchMerchants(ids: [], names: [], q: nil, disabled: nil, featured: nil, sortBy: nil, sortOrder: nil, limit: nil, { (merchants, error) in
                    if let error = error {
                        log(error, with: "List of merchants")
                    }
                    print("List of merchants results: \(merchants.count)")
                    print("\(String(describing: merchants.first(where: { $0.images.count > 0 }))) ")
                })
            }
        }
        
        func log(_ error: WildlinkError, with prefix: String) {
            switch error.kind {
            case .invalidResponse:
                print("\(prefix): Unknown invalid response from the server")
            case .invalidURL:
                print("\(prefix): You provided an invalid URL to the API")
            case .serverError(let subError):
                //Wildlink will respond with a JSON dictionary ([String : Any] type) if there's an error code with
                //the ErrorMessage key holding the reason
                print("\(prefix): Error message: \(String(describing: error.errorData["ErrorMessage"]))")
                print("\(prefix): Error data: \(String(describing: error))")
                print("\(prefix): Top-level error: \(String(describing: subError))")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

