//: Playground - noun: a place where people can play

import UIKit

protocol Cachable {
  var fileName: String { get }
  func transform() -> Data
}

final class Cacher {
  
  var destination: URL
  private let queue = OperationQueue()
  
  enum CacheDestination {
    case temporary
    case atFolder(String)
  }
  
  //MARK: Initialization
  
  init(destination: CacheDestination) {
    
    // Create the URL for the location of the cache resource
    switch destination {
    case .temporary:
      self.destination = URL(fileURLWithPath: NSTemporaryDirectory())
    case .atFolder(let folder):
      let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
      self.destination = URL(fileURLWithPath: documentFolder!).appendingPathComponent(folder, isDirectory: true)

      break
    }
    
    let fileManager = FileManager.default
    
    do {
      try fileManager.createDirectory(at: self.destination, withIntermediateDirectories: true, attributes: nil)
    } catch {
      fatalError("Unable to create cache URL: \(error)")
    }
  }
  
  //MARK: This function takes in the Cachable type and uses the transform method to write to the disk and returns the location back
  
  public func persist(item: Cachable, completion: @escaping (_ url: URL) -> Void) {
    
    let url = destination.appendingPathComponent(item.fileName, isDirectory: false)
    
    // Create an operation to process the request.
    let operation = BlockOperation {
      do {
        try item.transform().write(to: url, options: [.atomicWrite])
      } catch {
        fatalError("Failed to write item to cache: \(error)")
      }
    }
    
    // Set the operation's completion block to call the request's completion handler.
    operation.completionBlock = {
      completion(url)
    }
    
    // Add the operation to the queue to start the work.
    queue.addOperation(operation)
  }
}
