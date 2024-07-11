//
//  BluelockDb.swift
//  Bluelock
//
//  Created by Matthew on 11/4/2024.
//

import CoreBluetooth
import SQLite

public class BluelockDb {
    public static var main = try! BluelockDb()
    private var db: Connection

    private let tBonded = Table("Bonded")
    private let cDeviceIdentifier = Expression<UUID>("DeviceIdentifier")
    private let cAutoConnect = Expression<Bool>("AutoConnect")
    private let cAutoLock = Expression<Bool>("AutoLock")
    private let cAutoUnlock = Expression<Bool>("AutoUnlock")

    init() throws {
        let prefix = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        db = try Connection("\(prefix)/BluelockDb.sqlite3")
        try db.run(tBonded.create(ifNotExists: true) {
            $0.column(cDeviceIdentifier, primaryKey: true)
            $0.column(cAutoConnect)
            $0.column(cAutoLock)
            $0.column(cAutoUnlock)
        })
    }

    func rowDeserialize(_ row: Row) -> DeviceConfiguration {
        DeviceConfiguration(
            autoconnect: row[cAutoConnect],
            autounlock: row[cAutoUnlock],
            autolock: row[cAutoLock]
        )
    }

    func retrieveAllBonded() -> [(UUID, DeviceConfiguration)] {
        return try! db.prepare(tBonded).map {
            ($0[cDeviceIdentifier], rowDeserialize($0))
        }
    }

    func retrieve(peripheral: CBPeripheral) -> DeviceConfiguration? {
        retrieve(id: peripheral.identifier)
    }

    func retrieve(id: UUID) -> DeviceConfiguration? {
        return try! db.prepare(tBonded.filter(cDeviceIdentifier == id)).map(rowDeserialize).first
    }

    func update(config: DeviceConfiguration, peripheral: CBPeripheral) {
        update(config: config, id: peripheral.identifier)
    }

    func update(config: DeviceConfiguration, id: UUID) {
        try! db.transaction {
            try db.run(tBonded.filter(cDeviceIdentifier == id).delete())
            try db.run(tBonded.insert(
                cDeviceIdentifier <- id,
                cAutoConnect <- config.autoconnect,
                cAutoUnlock <- config.autounlock,
                cAutoLock <- config.autolock
            ))
        }
    }
}
