//
// Locking.swift
//  
import Foundation

// MARK: - Locking

/// Master recursive lock
internal var globalRecursiveLock = RecursiveLock()

/// Custom recursive lock
internal struct RecursiveLock {

    init() {
        let mutexAttr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        pthread_mutexattr_init(mutexAttr)
        pthread_mutexattr_settype(mutexAttr, Int32(PTHREAD_MUTEX_RECURSIVE))
        mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
        pthread_mutex_init(mutex, mutexAttr)
        pthread_mutexattr_destroy(mutexAttr)
        mutexAttr.deallocate()
    }

//    deinit {
//        pthread_mutex_destroy(mutex)
//        mutex.deallocate()
//    }

    @inline(__always) func lock() {
        pthread_mutex_lock(mutex)
    }

    @inline(__always) func unlock() {
        pthread_mutex_unlock(mutex)
    }

    @usableFromInline let mutex: UnsafeMutablePointer<pthread_mutex_t>

}

/// Master spin lock
internal let globalDebugLock = SpinLock()

#if os(macOS) || os(iOS) || os(watchOS)
/// Custom spin lock
internal struct SpinLock {

    init() {
        oslock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        oslock.initialize(to: .init())
    }

    @inline(__always) func lock() {
        os_unfair_lock_lock(oslock)
    }

    @inline(__always) func unlock() {
        os_unfair_lock_unlock(oslock)
    }

    @usableFromInline let oslock: UnsafeMutablePointer<os_unfair_lock>

}
#else
/// Custom spin lock compatible with Linux
internal struct SpinLock {

    init() {
        mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
        let attributes = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        pthread_mutexattr_init(attributes)
        pthread_mutexattr_settype(attributes, Int32(PTHREAD_MUTEX_NORMAL))
        pthread_mutex_init(mutex, attributes)
        pthread_mutexattr_destroy(attributes)
        attributes.deallocate()
    }

    @inline(__always) func lock() {
        pthread_mutex_lock(mutex)
    }

    @inline(__always) func unlock() {
        pthread_mutex_unlock(mutex)
    }

    @usableFromInline let mutex: UnsafeMutablePointer<pthread_mutex_t>
}
#endif
