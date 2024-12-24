//
//  TimerApp.swift
//  Timer
//
//  Created by Lochana Perera on 24/12/2024.
//

import SwiftUI

@main
struct TimerApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Image("MenuBarIcon")
                .resizable()
                .renderingMode(.template)
                .frame(width: 18, height: 18)
                .scaledToFit()
        }
        .menuBarExtraStyle(.window)
    }
}