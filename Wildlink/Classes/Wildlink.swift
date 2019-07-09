//
//  Wildlink.swift
//  Wildlink
//
//  Copyright © 2019 Wildfire, Systems. All rights reserved.
//

import Foundation
import Alamofire

// A type that can be initialized from a Wildlink JSON response.
protocol JSONSerializable {
    init?(dictionary: [String: Any])
}

public protocol WildlinkDelegate : class {
    func didReceive(deviceToken: String)
    func didReceive(deviceKey: String)
    func didReceive(deviceId: String)
}

// List of possible Error cases from the Wildlink SDK.
public enum WildlinkError: Error {
    case invalidURL
    case invalidResponse
}

// Enum to be used when requesting segmented query results.
public enum TimePeriod {
    case hour
    case day
    case month
    case year
}

public enum WildlinkSortBy: String {
    case id = "id"
    case name = "name"
    case disabled = "disabled"
    case featured = "featured"
}

public enum WildlinkSortOrder: String {
    case ascending = "asc"
    case descending = "desc"
}

public class Wildlink: RequestAdapter, RequestRetrier {
    
    //private variables/methods
    private typealias RefreshCompletion = (_ succeeded: Bool, _ deviceToken: String?, _ deviceKey: String?, _ deviceId: String?) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    
    private var baseUrl: URL
    private var deviceToken = ""
    private var deviceKey: String?
    private var deviceId: String?
    private var senderToken = ""
    static var apiKey = ""
    static var appID = ""
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    private let queue = DispatchQueue(label: "com.wildlink.response-queue", qos: .utility, attributes: [.concurrent])
    
    //public variables, methods
    public static let shared = Wildlink()
    public weak var delegate: WildlinkDelegate?
    
    private init(){
        self.baseUrl = APIConstants.baseUrlProd
    }
    
    // Initialize the Wildlink SDK using an AppID and App Secret. Optionally accepts a UUID previously given by the SDK.
    //
    // - parameter appId:               The identifier used with this
    // - parameter appSecret:           The vendor secret key provided by Wildlink to the consuming developer.
    // - parameter wildlinkDeviceToken: The Wildlink DeviceToken passed back by a previous call to initialize. This allows
    //                                  the consuming application to tie sessions together across runs. `nil` by default.
    // - parameter wildlinkDeviceKey:   The Wildlink DeviceKey passed back by a previous call to initialize. This allows
    //                                  the consuming application to request a new DeviceToken if the old one is lost, while
    //                                  still maintaining the history of this user (not considered a new device). `nil` by
    //                                  default.
    public func initialize(appId: String, appSecret: String, wildlinkDeviceToken: String? = nil, wildlinkDeviceKey: String? = nil) {
        self.baseUrl = APIConstants.baseUrlProd
        self.deviceKey = wildlinkDeviceKey
        Wildlink.appID = appId
        Wildlink.apiKey = appSecret
        sessionManager.adapter = self
        sessionManager.retrier = self
        guard let token = wildlinkDeviceToken else {
            refreshDeviceToken { (success, token, key, id) in
                if success, let token = token {
                    self.update(token: token)
                }
                if success, let key = key {
                    self.update(key: key)
                }
                if success, let id = id {
                    self.update(id: id)
                }
            }
            return
        }
        update(token: token)
    }
    
    // Generate a Wildlink URL string from a URL object.
    //
    // - parameter originalURL:     The URL object the user would like to convert to a Wildlink.
    // - parameter completion:      Completion closure to be called once the URL is converted to a Wildlink
    public func createVanityURL(from originalURL: URL, _ completion: @escaping(_ url: URL?, _ error: Error?) -> ()) {
        let queryUrl = baseUrl.appendingPathComponent("vanity")
        
        // Add Headers
        let headers = [
            "Content-Type":"application/json",
            ]
        
        // JSON Body
        let parameters: [String : Any] = [
            "URL": originalURL.absoluteString
        ]
        
        sessionManager.request(queryUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue, options: .allowFragments, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any], let vanityUrlString = json["VanityURL"] as? String {
                        let vanityUrl = URL(string:vanityUrlString)
                        completion(vanityUrl, nil)
                        self.parseResponseHeaders(response.response)
                    }
                    else {
                        completion(nil, WildlinkError.invalidResponse)
                    }
                    
                case .failure(let error):
                    if let data = response.data,
                        let info = String(data: data, encoding: .utf8) {
                        Logger.error(info)
                    }
                    completion(nil, error as Error)
                }
            })
    }
    
    // Generate a Wildlink URL string from a string object. Helper wrapper around the URL version.
    //
    // - parameter originalURL:     The URL object the user would like to convert to a Wildlink.
    // - parameter completion:      Completion closure to be called once the URL is converted to a Wildlink
    public func createVanityURL(from originalURL: String, _ completion: @escaping (_ url: URL?, _ error: Error?) -> ()) {
        guard let url = URL(string: originalURL) else {
            completion(nil, WildlinkError.invalidURL)
            return
        }
        createVanityURL(from: url, completion)
    }
    
    // Get the device click stats across a time period (potentially open-ended). Use the segmentation parameter to break
    // the results down into consumable buckets.
    //
    // - parameter start:           Date object defining the beginning of the query period.
    // - parameter end:             Optional Date object defining the end of the query period. If `nil`, Date.Now is used.
    // - parameter segmentation:    Separate the response by hour, day, month or year. Defaults to day.
    // - parameter completion:      Completion closure to be called once the stats are computed and downloaded.
    public func getClickStats(from start: Date, to end: Date? = nil, with segmentation: TimePeriod = .day, completion: @escaping (_ stats: [ClickStats]?, _ error: Error?) -> ()) {
        let queryUrl = baseUrl.appendingPathComponent("device/stats/clicks")
        
        // Add Headers
        let headers = [
            "Content-Type":"application/json",
            ]
        
        // JSON Body
        var parameters: [String : Any] = [
            "by": segmentation,
            "start": start.utc
        ]
        if let end = end {
            parameters["end"] = end.utc
        }
        
        sessionManager.request(queryUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue, options: .allowFragments, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? Array<[String: Any]> {
                        let arr = json.compactMap { ClickStats(dictionary: $0) }
                        completion(arr, nil)
                        self.parseResponseHeaders(response.response)
                    } else {
                        completion(nil, WildlinkError.invalidResponse)
                    }

                case .failure(let error):
                    if let data = response.data,
                        let info = String(data: data, encoding: .utf8) {
                        Logger.error(info)
                    }
                    completion(nil, error as Error)
                }
            })
    }
    
    // Get the commission statistics for this user.
    //
    // - parameter completion:      Completion closure to be called once the commission statisticas are computed and downloaded.
    public func getCommissionSummary(_ completion: @escaping (_ stats: CommissionStats?, _ error: Error?) -> ()) {
        let queryUrl = baseUrl.appendingPathComponent("device/stats/commission-summary")
        
        // Add Headers
        let headers = [
            "Content-Type":"application/json",
            ]
        
        sessionManager.request(queryUrl, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue, options: .allowFragments, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        let stats = CommissionStats(dictionary: json)
                        completion(stats, nil)
                        self.parseResponseHeaders(response.response)
                    } else {
                        completion(nil, WildlinkError.invalidResponse)
                    }
                    
                case .failure(let error):
                    if let data = response.data,
                        let info = String(data: data, encoding: .utf8) {
                        Logger.error(info)
                    }
                    completion(nil, error as Error)
                }
            })
    }
    
    // Get the details about commissions earned by the user.
    //
    // - parameter completion:      Completion closure to be called when the results have been downloaded.
    public func getCommissionDetails(_ completion: @escaping (_ details: [CommissionDetails]?, _ error: Error?) -> ()) {
        let queryUrl = baseUrl.appendingPathComponent("device/stats/commission-detail")
        
        // Add Headers
        let headers = [
            "Content-Type":"application/json",
            ]
        
        sessionManager.request(queryUrl, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue, options: .allowFragments, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? Array<[String: Any]> {
                        let arr = json.compactMap { CommissionDetails(dictionary: $0) }
                        completion(arr, nil)
                        self.parseResponseHeaders(response.response)
                    } else {
                        completion(nil, WildlinkError.invalidResponse)
                    }
                    
                case .failure(let error):
                    if let data = response.data,
                        let info = String(data: data, encoding: .utf8) {
                        Logger.error(info)
                    }
                    completion(nil, error as Error)
                }
            })
    }
    
    public func searchMerchants(ids: [String], names: [String], q: String?, disabled: Bool?, featured: Bool?, sortBy: WildlinkSortBy?, sortOrder: WildlinkSortOrder?, limit: Int?, _ completion: @escaping (_ merchants: [Merchant], _ error: Error?) -> ()) {
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        
        //build the id query section
        let idQueries = ids.compactMap { URLQueryItem(name: "id", value: $0) }
        //build the name query section
        let nameQueries = names.compactMap{ URLQueryItem(name: "name", value: $0) }
        //combine them. NOTE: possible empty array here
        var queryItems = idQueries + nameQueries
        //if we have a q, add it to the query array
        if let q = q {
            queryItems.append(URLQueryItem(name: "q", value: q))
        }
        //if we were passed a disabled flag, build that
        if let disabled = disabled {
            queryItems.append(URLQueryItem(name: "disabled", value: disabled ? "false" : "true"))
        }
        //if we were passed a featured flag, build that
        if let featured = featured {
            queryItems.append(URLQueryItem(name: "featured", value: featured ? "false" : "true"))
        }
        //if sortBy was passed in, build it
        if let sortBy = sortBy {
            queryItems.append(URLQueryItem(name: "sort_by", value: sortBy.rawValue))
        }
        //if sortOrder was passed in, build it
        if let sortOrder = sortOrder {
            queryItems.append(URLQueryItem(name: "sort_order", value: sortOrder.rawValue))
        }
        components?.queryItems = queryItems
        //have to put the /v2 in here because .path overrides the
        //path component in the constructor
        components?.path = "/v2/merchant"
        let queryUrl = components!.url!
        
        // Add Headers
        let headers = [
            "Content-Type":"application/json",
            ]
        
        sessionManager.request(queryUrl, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue, options: .allowFragments, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String : Any], let array = json["Merchants"] as? Array<[String:Any]> {
                        let merchants = array.compactMap { Merchant(dictionary: $0) }
                        completion(merchants, nil)
                    }

                case .failure(let error):
                    if let data = response.data,
                        let info = String(data: data, encoding: .utf8) {
                        Logger.error(info)
                    }
                    completion([], error as Error)
                }
            })
    }
    
    public func getMerchantByID(_ id: String, _ completion: @escaping (_ merchant: Merchant?, _ error: Error?) -> ()) {
        let queryUrl = baseUrl.appendingPathComponent("merchant/\(id)")
        
        // Add Headers
        let headers = [
            "Content-Type":"application/json",
            ]
        
        sessionManager.request(queryUrl, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue, options: .allowFragments, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        let merchant = Merchant(dictionary: json)
                        completion(merchant, nil)
                        self.parseResponseHeaders(response.response)
                    } else {
                        completion(nil, WildlinkError.invalidResponse)
                    }
                    
                case .failure(let error):
                    if let data = response.data,
                        let info = String(data: data, encoding: .utf8) {
                        Logger.error(info)
                    }
                    completion(nil, error as Error)
                }
            })
    }
    
    // MARK: - RequestAdapter
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseUrl.absoluteString) {
            
            let iso8601DateString = Date().iso8601
            let authString = getAuthorizationString(dateString: iso8601DateString, deviceToken: deviceToken, senderToken: senderToken)
            
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
            let fullVersionString = "\(version).\(build)"
            let device = UIDevice.current.name
            let os = UIDevice.current.systemVersion
            let userAgent = "WildlinkSDK/\(fullVersionString) (\(device)) iOS \(os)"
            
            var urlRequest = urlRequest
            urlRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            urlRequest.setValue(authString, forHTTPHeaderField: "Authorization")
            urlRequest.setValue(iso8601DateString, forHTTPHeaderField: "X-WF-DateTime")
            return urlRequest
        }
        
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }

        if let response = request.task?.response as? HTTPURLResponse,
            //only retry on 5XX errors
            (response.statusCode >= 500 &&  response.statusCode < 600) {
            requestsToRetry.append(completion)

            if !isRefreshing {
                refreshDeviceToken { [weak self] succeeded, deviceToken, deviceKey, deviceId  in
                    guard let strongSelf = self else { return }

                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }

                    if let localDeviceToken = deviceToken {
                        strongSelf.deviceToken = localDeviceToken
                    }

                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    // MARK: - Private - Refresh Device Token
    
    // Requests a device token.
    // Reference: https://github.com/wildlink/deviceapi
    //
    private func refreshDeviceToken(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        let queryUrl = baseUrl.appendingPathComponent("device")
        
        let iso8601DateString = Date().iso8601
        let authString = getAuthorizationString(dateString: iso8601DateString)
        
        // Add Headers
        let headers = [
            "Content-Type":"application/json",
            "Authorization": authString,
            "X-WF-DateTime": iso8601DateString
        ]
        
        // JSON Body
        var parameters: [String : Any] = [
            "OS": UIDevice.current.systemName
        ]
        //if we have a device key, append it to the requestb
        if let key = deviceKey {
            parameters["DeviceKey"] = key
        }
        
        sessionManager.request(queryUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue, options: .allowFragments, completionHandler: { [weak self] response in
                guard let strongSelf = self else { return }
                switch response.result {
                case .success(let value):
                    
                    if let json = value as? [String: Any],
                        let deviceToken = json["DeviceToken"] as? String {
                        let deviceKey = json["DeviceKey"] as? String
                        let deviceId = json["DeviceId"] as? String
                        completion(true, deviceToken, deviceKey, deviceId)
                    } else {
                        Logger.error("Failed to refresh device token: \(String(describing: response.result))")
                        completion(false, nil, nil, nil)
                    }
                case .failure:
                    Logger.error("Failed to refresh device token: \(String(describing: response.result))")
                    completion(false, nil, nil, nil)
                }
                strongSelf.isRefreshing = false
            })
    }
    
    private func parseResponseHeaders(_ response: HTTPURLResponse?) {
        guard let localResponse = response else { return }
        
        if let localDeviceToken = localResponse.allHeaderFields["x-wf-devicetoken"], let token = localDeviceToken as? String {
            update(token: token)
        }
    }
    
    // MARK - Helper functions
    
    // Helper function to store an updated token in memory and tell the delegate about it (if set)
    //
    // - parameter token:               The new token
    func update(token: String) {
        self.deviceToken = token
        Wildlink.shared.delegate?.didReceive(deviceToken: token)
    }
    
    // Helper function to store an updated device key in memory and tell the delegate about it (if set)
    //
    // - parameter key:                 The new Wildlink device key
    func update(key: String) {
        self.deviceKey = key
        Wildlink.shared.delegate?.didReceive(deviceKey: key)
    }
    
    // Helper function to store an updated device identifier in memory and tell the delegate about it (if set)
    //
    // - parameter id:                  The new device ID
    func update(id: String) {
        self.deviceId = id
        Wildlink.shared.delegate?.didReceive(deviceId: id)
    }
}

extension Wildlink {
    
    fileprivate func getSignatureKey(dateString: String, deviceToken: String? = nil, senderToken: String? = nil) -> String {
        
        let stringToSign = "\(dateString)\n\(deviceToken ?? "")\n\(senderToken ?? "")\n"
        
        let secret = Wildlink.apiKey
        let hmac256 = stringToSign.digestHMac256(key: secret)
        
        return hmac256
    }
    
    fileprivate func getAuthorizationString(dateString: String, deviceToken: String? = nil, senderToken: String? = nil) -> String {
        
        let hmac256 = getSignatureKey(dateString: dateString, deviceToken: deviceToken, senderToken: senderToken)
        let appToken = Wildlink.appID
        
        return "WFAV1 \(appToken):\(hmac256):\(deviceToken ?? ""):\(senderToken ?? "")"
    }
    
}
