# Adam
(New) Client for gobbl
Old one is here https://github.com/gobbl/adam-deprecated

##Gobbl
Food Next Door


### Dependencies
1. Facebook SDK
2. [Alamofire](https://github.com/Alamofire/Alamofire)
3. [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
4. (optional)Mixpanel SDK

#### Before Run
Pod install.
We manage [Alamofire](https://github.com/Alamofire/Alamofire) and [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) by [Cocoapods](https://github.com/cocoapods/cocoapods). So before we bagan we mus run

`pod install` or `pod update` if you already installed it.

To able to work with current version of server side we have to midify some of the Alamofire library: in order to meet the server's request prameter format.

1. We add this function.
  ```swift
  func queryArrayComponents(key: String, _ value: AnyObject) -> [(String, String)] {
    var components: [(String, String)] = []
    if let array = value as? [AnyObject] {
      var arrayVar:String = ""
      for value in array {
        arrayVar += escape("\(value)")
        arrayVar += ","
      }
      arrayVar.removeAtIndex(arrayVar.endIndex.predecessor())
      components.extend([(escape(key),arrayVar)])
    }
    return components
  }
  ```
  
2. Inside the encode funciton we add the if condition so when we found the batch request(in Array) we shall use `queryArrayComponets()` instead.
  ```swift
  func query(parameters: [String: AnyObject]) -> String {
    var isArray = false
    var components: [(String, String)] = []
    for key in sorted(Array(parameters.keys), <) {
      let value: AnyObject! = parameters[key]
  
      if let array = value as? [AnyObject] {
        isArray = true
        var QueryComponent = self.queryArrayComponents(key, value)
        components += QueryComponent
      } else {
        var QueryComponent = self.queryComponents(key, value)
        components += QueryComponent
      }
        
    }
    return join("&", components.map{"\($0)=\($1)"})
  }
  ```
