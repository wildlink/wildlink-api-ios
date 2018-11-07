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
                    print("Click stats: \(String(describing: results))")
                })
                Wildlink.shared.getCommissionSummary({ (stats, error) in
                    print("Commission summary: \(String(describing: stats))")
                })
                Wildlink.shared.getMerchantByID("5476062", { (merchant, error) in
                    print("Merchant data: \(String(describing: merchant))")
                })
                Wildlink.shared.searchMerchants(ids: [], names: [], q: nil, disabled: nil, featured: true, sortBy: nil, sortOrder: nil, limit: nil, { (merchants, error) in
                    print("List of merchants: \(merchants)")
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

