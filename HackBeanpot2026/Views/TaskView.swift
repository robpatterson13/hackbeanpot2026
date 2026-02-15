//
//  TaskView.swift
//  HackBeanpot2026
//

import SwiftUI
import Combine
import UIKit

struct TaskView: View {
    let task: HabitTask
    var onComplete: (() -> Void)? = nil

    @State private var now: Date = Date()
    @State private var showVerificationSheet = false
    @State private var showPointsSheet = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var timeRemaining: TimeInterval {
        max(0, task.expiration.timeIntervalSince(now))
    }

    private var countdownString: String {
        guard !task.isExpired else { return "Expired" }
        let interval = Int(timeRemaining)
        let hours = interval / 3600
        let minutes = (interval % 3600) / 60
        let seconds = interval % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private var expirationColor: Color {
        task.isExpired ? .red : .green
    }

    private var expirationIcon: String {
        task.isExpired ? "xmark.circle.fill" : "checkmark.circle.fill"
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.habit.displayName)
                    .font(.h2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                HStack {
                    Image(systemName: expirationIcon)
                        .foregroundColor(expirationColor)
                    Text(countdownString)
                        .font(.body)
                        .foregroundColor(expirationColor)
                        .monospacedDigit()
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 8) {
                    Label {
                        Text("\(task.habit.happinessIncrease)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } icon: {
                        Image("happiness").resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    Label {
                        Text("\(task.habit.healthIncrease)")
                            .font(.caption)
                            .foregroundColor(.red)
                    } icon: {
                        Image("health").resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    Label {
                        Text("\(task.habit.hungerIncrease)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    } icon: {
                        Image("hunger").resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
        .padding(16)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            guard !task.isExpired else { return }
            // Optional: show a points breakdown before verification
            showPointsSheet = true
        }
        .sheet(isPresented: $showPointsSheet) {
            PointsBreakdownSheet(
                habit: task.habit,
                onContinue: {
                    showPointsSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        showVerificationSheet = true
                    }
                },
                onCancel: {
                    showPointsSheet = false
                }
            )
        }
        .sheet(isPresented: $showVerificationSheet, content: {
            verificationSheetView()
        })
        .onReceive(timer) { current in
            now = current
        }
    }

    @ViewBuilder
    private func verificationSheetView() -> some View {
        VerificationSheet(habit: task.habit, onVerified: {
            onComplete?()
        })
    }
}

private struct PointsBreakdownSheet: View {
    let habit: Habit
    var onContinue: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Rewards")
                .font(.title2)
                .bold()
                .padding(.top)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image("health").resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    Text("Health +\(habit.healthIncrease)")
                        .font(.headline)
                }
                HStack {
                    Image("happiness").resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    Text("Happiness +\(habit.happinessIncrease)")
                        .font(.headline)
                }
                HStack {
                    Image("hunger").resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    Text("Hunger +\(habit.hungerIncrease)")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button("Continue") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)

            Button("Cancel") {
                onCancel()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .presentationDetents([.fraction(0.35), .medium])
    }
}

struct VerificationSheet: View {
    let habit: Habit
    var onVerified: () -> Void

    init(habit: Habit, onVerified: @escaping () -> Void = {}) {
        self.habit = habit
        self.onVerified = onVerified
    }

    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var isVerifying = false
    @State private var verificationMessage: String? = nil
    @State private var showOverride = false

    private var screenshotType: ScreenshotType? {
        switch habit.verification {
        case .screenshot:
            switch habit {
            case .jobs: return .jobs
            case .leetcode: return .leetcode
            default: return nil
            }
        default:
            return nil
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Verification")
                .font(.title)
                .padding(.top)

            switch habit.verification {
            case .confirmation(let prompt):
                Text(prompt)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                Button("Yes, I did this", action: {
                    onVerified()
                    dismiss()
                })
                .buttonStyle(.borderedProminent)

            case .screenshot(let prompt):
                Text(prompt)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()

                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if let msg = verificationMessage {
                    Text(msg)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                HStack {
                    Button("Select Screenshot", action: {
                        showingImagePicker = true
                    })
                    .buttonStyle(.bordered)

                    if isVerifying {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding(.leading, 8)
                    }
                }

                Button("Submit", action: submitVerification)
                    .buttonStyle(.borderedProminent)
                    .disabled(image == nil || isVerifying)

                if showOverride {
                    Button("Override and Complete", action: {
                        onVerified()
                        dismiss()
                    })
                    .buttonStyle(.bordered)
                }
            
            case .location(let prompt):
                LocationVerificationView(
                    prompt: prompt,
                    onComplete: {
                        onVerified()
                        dismiss()
                    },
                    onCancel: {
                        dismiss()
                    }
                )
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $image)
        }
    }

    private func submitVerification() {
        guard let image, let type = screenshotType else { return }
        isVerifying = true
        verificationMessage = "Analyzing screenshot..."
        Task {
            defer { isVerifying = false }
            do {
                let result = try await VisionTextVerifier.verify(image: image, type: type)
                if result.isConfident {
                    verificationMessage = "Looks good! Keywords: \(result.matchedKeywords.joined(separator: ", "))"
                    try? await Task.sleep(nanoseconds: 400_000_000)
                    onVerified()
                    dismiss()
                } else {
                    verificationMessage = "We couldn’t confidently verify this screenshot. Found: \(result.matchedKeywords.joined(separator: ", ")). You can try another image or override."
                    showOverride = true
                }
            } catch {
                verificationMessage = "Verification failed: \(error.localizedDescription)"
                showOverride = true
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

