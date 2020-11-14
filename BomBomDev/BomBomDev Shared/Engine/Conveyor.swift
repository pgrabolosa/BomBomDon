//
//  Conveyer.swift
//  BomBomDev
//
//  Created by Pierre Grabolosa on 14/11/2020.
//

import Foundation

enum Orientation : String, Codable {
    case left, up, right, down
    
    var integerOffset: (dx: Int, dy: Int) {
        switch self {
            case .left:
                return (-1, 0)
            case .up:
                return ( 0, 1)
            case .right:
                return ( 1, 0)
            case .down:
                return ( 0,-1)
        }
    }
    
    var rotation: CGFloat {
        switch self {
            case .left:  return 0
            case .up:    return -.pi/2
            case .right: return .pi
            case .down:  return .pi/2
        }
    }
}

struct BloodTypeMask: OptionSet, Codable {
    let rawValue: UInt8
    static let A = BloodTypeMask(rawValue: 1 << 0)
    static let B = BloodTypeMask(rawValue: 1 << 1)
    static let O = BloodTypeMask(rawValue: 1 << 2)
    
    static let all = BloodTypeMask(rawValue: 255)
}

struct ConveyorSegment : Codable {
    var length = 1
    var orientation = Orientation.left
    var bloodTypeMask = BloodTypeMask.all
}

struct Conveyor : Codable {
    var segments: [ConveyorSegment] = []
    var length: Int {
        segments.reduce(0) { $0 + $1.length }
    }
    
    /// Time required to traverse one cell
    var speed: TimeInterval = 1
    
    /// Time required to traverse the whole segment
    var duration: TimeInterval { TimeInterval(length) * speed }
}

class Parcel {
    var runner: ConveyorRunner
    init(runner:ConveyorRunner) {
        self.runner = runner
    }
    
    var created = Date()
    var age: TimeInterval { created.timeIntervalSinceNow }
    
    func progression(over conveyor: Conveyor) -> CGFloat {
        return CGFloat(age / conveyor.duration)
    }
}

class ConveyorRunner {
    var conveyor = Conveyor()
    var transportQueue: [Parcel] = []
    
    func load() {
        let parcel = Parcel(runner: self)
        transportQueue.append(parcel)
        NotificationCenter.default.post(name: .newParcel, object: parcel)
    }
}

extension Notification.Name {
    static let newParcel = Notification.Name("newParcel")
    static let droppedParcel = Notification.Name("droppedParcel")
}
