//
//  NSObject+RollCall.swift
//  SentientJet
//
//  Created by Jason Clark on 6/3/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

final class RollCall {

    class func setup() {
        swizzleInit()
    }

}

private extension RollCall {

    class func rollCall(sender: AnyClass) {
        print("Roll call:")
        let enumerator = ObjectCache.objects.keyEnumerator()
        while let classType = enumerator.nextObject() {
            if let hashTable = ObjectCache.objects.objectForKey(classType) as? NSHashTable, obj = hashTable.anyObject where (obj as? NSObject)?.isKindOfClass(sender) ?? false {
                print("  \(String(obj.dynamicType)) \(hashTable.allObjects.count)")
            }
        }
    }

    class func swizzleInit() {
        struct Static {
            static var token: dispatch_once_t = 0
        }

        dispatch_once(&Static.token) {
            typealias initIMP = @convention(c)(NSObject, Selector) -> NSObject

            let initSelector = #selector(NSObject.init)
            let initInstanceMethod = class_getInstanceMethod(NSObject.self, initSelector)

            var originalIMP: IMP = nil
            let swizzledIMPBlock: @convention(block) (NSObject) -> NSObject = { (receiver) -> NSObject in
                receiver.registerForRollCall()
                let imp = unsafeBitCast(originalIMP, initIMP.self)
                return imp(receiver, initSelector)
            }

            let swizzledIMP = imp_implementationWithBlock(unsafeBitCast(swizzledIMPBlock, AnyObject.self))
            originalIMP = method_setImplementation(initInstanceMethod, swizzledIMP)
        }
    }

}

private final class ObjectCache {

    static var objects = NSMapTable.strongToStrongObjectsMapTable()

    class func addObject(object: AnyObject) {
        let classType: AnyObject.Type = object.dynamicType
        if let existingHashTable = objects.objectForKey(classType) as? NSHashTable {
            existingHashTable.addObject(object)
        }
        else {
            let hashtable = NSHashTable.weakObjectsHashTable()
            hashtable.addObject(object)
            objects.setObject(hashtable, forKey: classType)
        }
    }

}

extension NSObject {
    class func rollCall() {
        RollCall.rollCall(self)
    }
}

private extension NSObject {

    static let rollCallNotificationName = "rollCall"

    func registerForRollCall() {
        if let objectNamespace = moduleNameForObject(self), localNamespace = moduleNameForObject(AppDelegate) where objectNamespace == localNamespace {
            ObjectCache.addObject(self)
        }
    }

    func moduleNameForObject(object: AnyObject) -> String? {
        return NSStringFromClass(object_getClass(object)).componentsSeparatedByString(".").first
    }

}
