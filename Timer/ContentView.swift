//
//  ContentView.swift
//  Timer
//
//  Created by Lochana Perera on 24/12/2024.
//

import SwiftUI
import UserNotifications

enum TimerMode {
    case focus
    case shortBreak
    case longBreak
    
    var duration: TimeInterval {
        switch self {
        case .focus: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }
    
    var title: String {
        switch self {
        case .focus: return "Focus Time"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
}

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Background Circle
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 180, height: 180)
                
                // Progress Ring
                Circle()
                    .trim(from: 0, to: timerManager.progress)
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 6,
                            lineCap: .round
                        )
                    )
                    .foregroundStyle(
                        timerManager.isRunning ?
                            Color.accentColor.gradient :
                            Color.secondary.gradient
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 170, height: 170)
                    .animation(.smooth, value: timerManager.progress)
                
                // Timer Display
                VStack(spacing: 4) {
                    Text(timerManager.mode.title)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Text(timerManager.timeString)
                        .font(.system(size: 44, weight: .light, design: .rounded))
                        .foregroundStyle(timerManager.isRunning ? Color.accentColor : .primary)
                        .contentTransition(.numericText())
                }
            }
            .animation(.smooth, value: timerManager.mode)
            
            Picker("Mode", selection: $timerManager.mode) {
                Text("Focus").tag(TimerMode.focus)
                Text("Short").tag(TimerMode.shortBreak)
                Text("Long").tag(TimerMode.longBreak)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button(action: { timerManager.reset() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 40, height: 40)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    if timerManager.isRunning {
                        timerManager.pause()
                    } else {
                        timerManager.start()
                    }
                }) {
                    Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(timerManager.isRunning ? Color.red : Color.accentColor)
                        .clipShape(Circle())
                        .shadow(radius: 2, y: 1)
                }
                .buttonStyle(.plain)
                
                Button(action: { timerManager.skip() }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 40, height: 40)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
        .padding(20)
        .frame(width: 320)
        .background {
            ZStack {
                if colorScheme == .dark {
                    Color.black.opacity(0.6)
                } else {
                    Color.white.opacity(0.6)
                }
                Rectangle()
                    .fill(.regularMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }
}

class TimerManager: ObservableObject {
    @Published var mode: TimerMode = .focus {
        didSet { reset() }
    }
    @Published var timeRemaining: TimeInterval
    @Published var isRunning = false
    private var timer: Timer?
    
    init() {
        self.timeRemaining = TimerMode.focus.duration
    }
    
    var progress: Double {
        1 - (timeRemaining / mode.duration)
    }
    
    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        timeRemaining = mode.duration
    }
    
    func skip() {
        withAnimation {
            switch mode {
            case .focus: mode = .shortBreak
            case .shortBreak: mode = .focus
            case .longBreak: mode = .focus
            }
        }
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            sendNotification()
            pause()
            return
        }
        timeRemaining -= 1
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "\(mode.title) Complete"
        content.subtitle = "Time's up!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    ContentView()
}