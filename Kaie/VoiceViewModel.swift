//
//  VoiceViewModel.swift
//  Kaie
//
//  Created by 이효록 on 12/27/25.
//

import SwiftUI

enum VoiceState: String {
    case idle
    case listening
    case thinking
    case speaking

    var label: String {
        switch self {
        case .idle:
            return "Idle"
        case .listening:
            return "Listening"
        case .thinking:
            return "Thinking"
        case .speaking:
            return "Speaking"
        }
    }
}

@MainActor
final class VoiceViewModel: ObservableObject {
    @Published var state: VoiceState = .idle
    @Published var isSessionActive = false
    @Published var isUserSpeaking = false
    @Published var transcript = ""
    @Published var response = ""
    @Published var statusText = "Tap start to speak"

    private var responseTask: Task<Void, Never>?
    private var speakingTask: Task<Void, Never>?
    private let voiceService = MockVoiceService()

    func toggleSession() {
        if isSessionActive {
            stopSession()
        } else {
            startSession()
        }
    }

    private func simulatePipeline() {
        responseTask?.cancel()
        responseTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 900_000_000)
            guard !Task.isCancelled else { return }
            state = .speaking
            statusText = "Speaking..."

            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard !Task.isCancelled else { return }
            state = .idle
            statusText = "Tap start to speak"
        }
    }

    private func startSession() {
        guard !isSessionActive else { return }
        isSessionActive = true
        responseTask?.cancel()
        transcript = ""
        response = ""
        statusText = "Listening..."
        state = .listening
        playHaptic()
        voiceService.startCapture()
        simulateSpeakingActivity()
    }

    private func stopSession() {
        guard isSessionActive else { return }
        isSessionActive = false
        isUserSpeaking = false
        state = .thinking
        statusText = "Thinking..."
        voiceService.stopCapture()
        speakingTask?.cancel()
        simulatePipeline()
    }

    private func simulateSpeakingActivity() {
        speakingTask?.cancel()
        speakingTask = Task { [weak self] in
            guard let self else { return }
            while isSessionActive {
                isUserSpeaking = true
                try? await Task.sleep(nanoseconds: 600_000_000)
                isUserSpeaking = false
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }

    private func playHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
}

private final class MockVoiceService {
    func startCapture() {
        // Placeholder for audio session + mic capture.
    }

    func stopCapture() {
        // Placeholder for stopping capture and handing off to STT.
    }
}
