//
//  ContentView.swift
//  MQTT POC
//
//  Created by Sylvan  on 29/08/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var mqttService = MQTTService()
    @State private var input = ""
    private let topic = "poc/topic"

    var body: some View {
        NavigationStack {
            VStack {
                List(mqttService.messages, id: \.self) { message in
                    Text(message)
                }

                HStack {
                    TextField("Message", text: $input)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(sendMessage)

                    Button("Send", action: sendMessage)
                        .disabled(input.isEmpty)
                }
                .padding()
            }
            .navigationTitle("MQTT POC Chat")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text(mqttService.connectionStatus.text)
                        .font(.caption)
                        .foregroundStyle(
                            mqttService.connectionStatus == .connected ? .green : .red
                        )
                }
            }
        }
        .onAppear {
            mqttService.connect()
            mqttService.subscribe(topic: topic)
        }
    }

    private func sendMessage() {
        guard !input.isEmpty else { return }
        mqttService.publish(topic: topic, message: input)
        input = ""
    }
}

#Preview {
    ContentView()
}
