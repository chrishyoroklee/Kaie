//
//  ContentView.swift
//  Kaie
//
//  Created by 이효록 on 12/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = VoiceViewModel()

    var body: some View {
        ZStack {
            background
            VStack(spacing: 28) {
                header
                orb
                status
                controls
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 48)
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white,
                    Color(.systemGray6),
                    Color(.systemGray5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.white.opacity(0.6),
                    Color(.systemGray5).opacity(0.2),
                    Color.clear
                ],
                center: .top,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Kaie")
                .font(.custom("Avenir Next Demi Bold", size: 34))
                .foregroundStyle(.primary)
            Text("Your calm space for reflection")
                .font(.custom("Avenir Next", size: 15))
                .foregroundStyle(.secondary)
        }
    }

    private var orb: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 220, height: 220)
                .shadow(color: Color.black.opacity(0.08), radius: 30, x: 0, y: 16)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            ringColor,
                            Color(.systemGray2),
                            ringColor.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 220, height: 220)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ringColor.opacity(0.2),
                            Color(.systemGray5).opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 140
                    )
                )
                .frame(width: 180, height: 180)

            Circle()
                .stroke(ringColor.opacity(0.7), lineWidth: 1)
                .frame(width: ringPulseSize, height: ringPulseSize)
                .opacity(ringPulseOpacity)
                .blur(radius: 0.5)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: viewModel.state)

            Text(viewModel.state.label)
                .font(.custom("Avenir Next", size: 16))
                .foregroundStyle(.secondary)
                .tracking(2)
        }
        .frame(height: 260)
        .animation(.easeInOut(duration: 0.4), value: viewModel.state)
    }

    private var status: some View {
        VStack(spacing: 6) {
            if !viewModel.transcript.isEmpty {
                Text(viewModel.transcript)
                    .font(.custom("Avenir Next", size: 15))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            } else {
                Text(viewModel.statusText)
                    .font(.custom("Avenir Next", size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if !viewModel.response.isEmpty {
                Text(viewModel.response)
                    .font(.custom("Avenir Next", size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Circle()
                    .fill(ringColor.opacity(0.4))
                    .frame(width: 10, height: 10)
                Text(viewModel.isHolding ? "Release" : "Hold")
                    .font(.custom("Avenir Next Demi Bold", size: 14))
                    .foregroundStyle(.primary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 22)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                    )
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    viewModel.pressBegan()
                }
                .onEnded { _ in
                    viewModel.pressEnded()
                }
        )
    }

    private var ringColor: Color {
        switch viewModel.state {
        case .idle:
            return Color(.systemGray3)
        case .listening:
            return Color(.systemGray)
        case .thinking:
            return Color(.systemGray2)
        case .speaking:
            return Color(.systemGray4)
        }
    }

    private var ringPulseSize: CGFloat {
        viewModel.state == .listening ? 260 : 235
    }

    private var ringPulseOpacity: Double {
        viewModel.state == .listening ? 0.18 : 0.35
    }
}

#Preview {
    ContentView()
}
