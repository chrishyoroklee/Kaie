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
    @Published var isHolding = false
    @Published var transcript = ""
    @Published var response = ""
    @Published var statusText = "Tap and hold to speak"

    private var responseTask: Task<Void, Never>?
    private let voiceService = MockVoiceService()

    func pressBegan() {
        guard !isHolding else { return }
        isHolding = true
        responseTask?.cancel()
        transcript = ""
        response = ""
        statusText = "Listening..."
        state = .listening
        playHaptic()
        voiceService.startCapture()
    }

    func pressEnded() {
        guard isHolding else { return }
        isHolding = false
        state = .thinking
        statusText = "Thinking..."
        voiceService.stopCapture()
        simulatePipeline()
    }

    private func simulatePipeline() {
        responseTask?.cancel()
        responseTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 900_000_000)
            guard !Task.isCancelled else { return }
            transcript = "I have been feeling overwhelmed lately."

            try? await Task.sleep(nanoseconds: 800_000_000)
            guard !Task.isCancelled else { return }
            state = .speaking
            statusText = "Speaking..."
            response = "Thanks for sharing that. Want to talk about what feels heaviest today?"

            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard !Task.isCancelled else { return }
            state = .idle
            statusText = "Tap and hold to speak"
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
