import PromiseKit
import Alamofire

public enum PMKAFResponseOptions { case raw }

/**
 To import the `Alamofire` category:

     use_frameworks!
     pod "PromiseKit/Alamofire"

 And then in your sources:

     import PromiseKit

 */
extension Alamofire.DataRequest {

    public func response(_: PMKNamespacer) -> Promise<Void> {
        return Promise { seal in
            response(queue: nil) { rsp in
                if let error = rsp.error {
                    seal.reject(error)
                } else {
                    seal.fulfill()
                }
            }
        }
    }

    /**
          firstly {
              Alamofire.request(url).responseData(with: .raw)
          }.then { data, rsp in
              print(rsp.request)
          }
     */
    public func responseData(with: PMKAFResponseOptions) -> Promise<(Data, Alamofire.DataResponse<Data>)> {
        return Promise { seal in
            responseData(queue: nil) { rsp in
                if let error = rsp.error {
                    seal.reject(error)
                } else if let data = rsp.data {
                    seal.fulfill(data, rsp)
                } else {
                    seal.reject(PMKError.invalidCallingConvention)
                }
            }
        }
    }

    /**
          firstly {
              Alamofire.request(url).responseData()
          }.then { data in
              //…
          }
     */
    public func responseData() -> Promise<Data> {
        return responseData(with: .raw).map(on: nil){ $0.0 }
    }

    /**
          firstly {
              Alamofire.request(url).responseString(with: .raw)
          }.then { string, rsp in
              print(rsp.request)
          }
     */
    public func responseString(with: PMKAFResponseOptions, encoding: String.Encoding? = nil) -> Promise<(String, Alamofire.DataResponse<String>)> {
        return Promise { pipe in
            responseString(queue: nil, encoding: encoding) { response in
                switch response.result {
                case .success(let value):
                    pipe.fulfill(value, response)
                case .failure(let error):
                    pipe.reject(error)
                }
            }
        }
    }

    /**
          firstly {
              Alamofire.request(url).responseString()
          }.then { string in
              //…
          }
     */
    public func responseString(encoding: String.Encoding? = nil) -> Promise<String> {
        return responseString(with: .raw, encoding: encoding).map(on: nil){ $0.0 }
    }

    /**
          firstly {
              Alamofire.request(url).responseJSON(with: .raw)
          }.then { json, rsp in
              print(rsp.request)
          }
     */
    public func responseJSON(with: PMKAFResponseOptions, options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<(Any, Alamofire.DataResponse<Any>)> {
        return Promise { seal in
            responseJSON(queue: nil, options: options, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    seal.fulfill(value, response)
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }

    /**
          firstly {
              Alamofire.request(url).responseJSON().flatMap{ $0 as? [String: Any] }
          }.then { json in
              // NOTE! The recommended use of `Promise.flatMap(_:)`
          }
     */
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<Any> {
        return responseJSON(with: .raw).map(on: nil){ $0.0 }
    }
}

extension Alamofire.DownloadRequest {
    /**
          firstly {
              Alamofire.download(url).responseData(with: .raw)
          }.then { data, rsp in
              print(rsp.request)
          }
     */
    public func responseData(with: PMKAFResponseOptions) -> Promise<(Data, Alamofire.DownloadResponse<Data>)> {
        return Promise { seal in
            responseData(queue: nil) { response in
                switch response.result {
                case .success(let value):
                    seal.fulfill(value, response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    /**
          firstly {
              Alamofire.download(url).responseData()
          }.then { data in
              //…
          }
     */
    public func responseData() -> Promise<Data> {
        return responseData(with: .raw).map(on: nil){ $0.0 }
    }
    
    /**
     Feeds you your destinationUrl or, if unset, the temporaryURL.
     This variant is more efficient since the `Data` of the download is not allocated into memory.
    */
    public func response(_: PMKNamespacer) -> Promise<URL> {
        return Promise { seal in
            response(queue: nil) { rsp in
                let url = rsp.destinationURL ?? rsp.temporaryURL
                seal.resolve(value: url, error: rsp.error)
            }
        }
    }
}
