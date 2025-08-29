//
//  MQTTService.swift
//  MQTT POC
//
//  Created by Sylvan  on 29/08/2025.
//

import Foundation
import CocoaMQTT

//@MainActor
final class MQTTService: NSObject, ObservableObject {
    enum ConnectionStatus {
        case disconnected
        case connecting
        case connected

        var text: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting..."
            case .connected: return "Connected"
            }
        }
    }

    @Published var messages: [String] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected

    private var mqtt: CocoaMQTT!
    private let hostAddress = "broker.hivemq.com" //test.mosquitto.org
    private var topic: String?

    override init() {
        super.init()
        setupMQTT()
    }

    func connect() {
        print("Connecting to broker...")
        _ = mqtt.connect()
    }

    func disconnect() {
        print("Disconnecting...")
        mqtt.disconnect()
    }

    func subscribe(topic: String) {
        if connectionStatus == .connected {
            mqtt.subscribe(topic)
        } else {
            self.topic = topic
        }
    }

    func publish(topic: String, message: String) {
        mqtt.publish(topic, withString: message, qos: .qos1)
    }

    private func setupMQTT() {
        let clientID = "MQTTChatPOC-" + String(ProcessInfo.processInfo.processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: hostAddress, port: 1883)
        mqtt.delegate = self
        mqtt.keepAlive = 60
    }
}

extension MQTTService: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("[MQTT] Connected with ack: \(ack)")
        DispatchQueue.main.async {
            self.connectionStatus = .connected
        }

        if let topic {
            mqtt.subscribe(topic)
        }
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: (any Error)?) {
        print("[MQTT] Disconnected from broker: \(err?.localizedDescription ?? "No error")")
        DispatchQueue.main.async {
            self.connectionStatus = .disconnected
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let msg = message.string ?? "(No payload)"
        print("[MQTT] Message: \(msg)")
        DispatchQueue.main.async {
            self.messages.append(msg)
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("[MQTT] Subscribed to topics: \(success.allKeys.description)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("[MQTT] Unsubscribed from topics: \(topics)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("[MQTT] Published message with id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("[MQTT] Received publish ACK for id: \(id)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        // print("Sent PING")
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        // print("Received PONG")
    }
}
