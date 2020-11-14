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
    
    /// Time required to traverse one cell
    var speed: TimeInterval = 1
    
    /// Time required to traverse the whole segment
    var duration: TimeInterval { TimeInterval(length) * speed }
}

struct Conveyor : Codable {
    var segments: [ConveyorSegment] = []
    var length: Int {
        segments.reduce(0) { $0 + $1.length }
    }
    
    /// Time required to traverse the whole conveyor
    var duration: TimeInterval { segments.reduce(TimeInterval.zero) { $0 + $1.duration } }
    
    /// Time from start to each cell
    var discreteDuration: [TimeInterval] {
        var result: [TimeInterval] = []
        var clock: TimeInterval = .zero
        
        for segment in segments {
            for _ in 0..<segment.length {
                result.append(clock)
                clock += segment.speed
            }
        }
        
        return result
    }
}


protocol Agent {
    func update(_ ellapsed: TimeInterval)
}


class Parcel: Agent {
    var runner: ConveyorRunner
    init(runner:ConveyorRunner) {
        self.runner = runner
    }
    
    var age: TimeInterval = 0
    var segmentProgress = 0
    
    func progression(over conveyor: Conveyor) -> CGFloat {
        return CGFloat(age / conveyor.duration)
    }
    
    func update(_ ellapsed: TimeInterval) {
        age += ellapsed
        
        let newSegmentProgress = runner.conveyor.discreteDuration.lastIndex(where: { $0 <= age }) ?? runner.conveyor.length + 1
        segmentProgress = newSegmentProgress
        NotificationCenter.default.post(name: .parcelMovedToNewCoveyorCell, object: self)
        
        if progression(over: runner.conveyor) > 1.0 {
            NotificationCenter.default.post(name: .droppedParcel, object: self)
            runner.transportQueue.removeAll { $0 === self }
        }
    }
    
    func delivered() {
        fatalError("TODO?")
    }
}

class ConveyorRunner: Agent {
    var conveyor = Conveyor()
    var transportQueue: [Parcel] = []
    
    func load() {
        let parcel = Parcel(runner: self)
        transportQueue.append(parcel)
        NotificationCenter.default.post(name: .newParcel, object: parcel)
    }
    
    func update(_ ellapsed: TimeInterval) {
        transportQueue.forEach { $0.update(ellapsed) }
    }
    
    func remove(_ parcel: Parcel) {
        transportQueue.remove(at:transportQueue.firstIndex(where:{ $0 === parcel })!)
    }
}

extension Notification.Name {
    static let newParcel = Notification.Name("newParcel")
    static let parcelMovedToNewCoveyorCell = Notification.Name("parcelMovedToNewCoveyorCell")
    static let droppedParcel = Notification.Name("droppedParcel")
}
