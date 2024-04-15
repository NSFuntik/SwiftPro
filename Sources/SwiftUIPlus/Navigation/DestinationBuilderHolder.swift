import Foundation
import SwiftUI

/// Keeps hold of the destination builder closures for a given type or local destination ID.
open class DestinationBuilderHolder: ObservableObject {
    static func identifier(for type: Any.Type) -> String {
        String(reflecting: type)
    }
    
    var builders: [String: (Any) -> AnyView?] = [:]
    var mockEmptyView: any View
    
    init(mockEmptyView: () -> some View = {EmptyView()}) {
        builders = [:]
        self.mockEmptyView = mockEmptyView()
    }
    
    func appendBuilder<T>(_ builder: @escaping (T) -> AnyView) {
        let key = Self.identifier(for: T.self)
        builders[key] = { data in
            if let typedData = data as? T {
                return builder(typedData)
            } else {
                return nil
            }
        }
    }
    
    func appendLocalBuilder(identifier: LocalDestinationID, _ builder: @escaping () -> AnyView) {
        let key = identifier.rawValue.uuidString
        builders[key] = { _ in builder() }
    }
    
    func removeLocalBuilder(identifier: LocalDestinationID) {
        let key = identifier.rawValue.uuidString
        builders[key] = nil
    }
    
    open func build<T>(_ typedData: T) -> AnyView {
        let base = (typedData as? AnyHashable)?.base
        if let identifier = (base ?? typedData) as? LocalDestinationID {
            let key = identifier.rawValue.uuidString
            if let builder = builders[key], let output = builder(typedData) {
                return output
            }
            return	AnyView(mockEmptyView)
            //		?? AnyView(VStack { Text("No view builder found for type \(key)") ; Image(systemName: "exclamationmark.triangle").imageScale(.large) })
        } else {
            var possibleMirror: Mirror? = Mirror(reflecting: base ?? typedData)
            while let mirror = possibleMirror {
                let key = Self.identifier(for: mirror.subjectType)
                
                if let builder = builders[key], let output = builder(typedData) {
                    return output
                }
                possibleMirror = mirror.superclassMirror
            }
            return	AnyView(mockEmptyView)
            //		?? AnyView(VStack { Text("No view builder found for type \(base.debugDescription)") ; Image(systemName: "exclamationmark.triangle").imageScale(.large)
            //		})
        }
        //	  return AnyView(Image(systemName: "exclamationmark.triangle"))
    }
}
