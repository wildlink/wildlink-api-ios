//
//  ViewController.swift
//  Wildlink
//
//  Copyright (c) 2019 Wildfire Systems. All rights reserved.
//

import UIKit
import Wildlink

class ViewController: UIViewController {
    
    @IBOutlet weak var urlOutlet: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sleep(2)
        Wildlink.shared.createVanityURL(from: urlOutlet.text) { (url, error) in
            if let url = url {
                self.urlOutlet.text = url.absoluteString
                sleep(2)
                Wildlink.shared.getClickStats(from: Date(timeIntervalSinceNow: -604800), with: .hour, completion: { (results, error) in
                    print("Click stats error: \(String(describing: error))")
                    print("Click stats results: \(String(describing: results))")
                })
                Wildlink.shared.getCommissionSummary({ (stats, error) in
                    print("Commission summary error: \(String(describing: error))")
                    print("Commission summary results: \(String(describing: stats))")
                })
                Wildlink.shared.getMerchantByID("5476062", { (merchant, error) in
                    print("Merchant data error: \(String(describing: error))")
                    print("Merchant data results: \(String(describing: merchant))")
                })
                Wildlink.shared.searchMerchants(ids: [], names: [], q: nil, disabled: nil, featured: true, sortBy: nil, sortOrder: nil, limit: nil, { (merchants, error) in
                    print("List of merchants error: \(String(describing: error))")
                    print("List of merchants results: \(merchants)")
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

