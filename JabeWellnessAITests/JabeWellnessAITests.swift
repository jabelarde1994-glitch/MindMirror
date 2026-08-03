//
//  JabeWellnessAITests.swift
//  JabeWellnessAITests
//
//  Created by Joel Reamosio Abelarde on 5/13/26.
//

import Testing
import Foundation
@testable import JabeWellnessAI

struct JabeWellnessAITests {

    // ChatSession.dominantMood should reflect the mood that occurs most often across
    // the conversation, not just whichever mood the first tagged message happened to have.
    @Test func dominantMoodReflectsMostFrequentMoodNotFirst() async throws {
        let messages = [
            ChatMessage(content: "I'm so anxious about this",       isUser: true,  mood: .anxious, timestamp: Date()),
            ChatMessage(content: "It'll be okay, tell me more",     isUser: false, mood: nil,       timestamp: Date()),
            ChatMessage(content: "Actually I feel great now",       isUser: true,  mood: .happy,    timestamp: Date()),
            ChatMessage(content: "That's wonderful to hear!",       isUser: false, mood: nil,       timestamp: Date()),
            ChatMessage(content: "Yeah I'm really happy about it",  isUser: true,  mood: .happy,    timestamp: Date()),
        ]

        let session = ChatSession(messages: messages)

        #expect(session.dominantMood == .happy)
    }

    @Test func dominantMoodFallsBackToNeutralWhenNoMoodsPresent() async throws {
        let messages = [
            ChatMessage(content: "Hello", isUser: true,  mood: nil, timestamp: Date()),
            ChatMessage(content: "Hi!",   isUser: false, mood: nil, timestamp: Date()),
        ]

        let session = ChatSession(messages: messages)

        #expect(session.dominantMood == .neutral)
    }

    // MARK: - Trial window

    private func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }

    @Test func trialIsActiveOnTheDayItStarts() async throws {
        let start = date(daysAgo: 0)
        #expect(PremiumManager.isInTrial(start: start, now: Date(), trialDays: 7))
        #expect(PremiumManager.trialDaysRemaining(start: start, now: Date(), trialDays: 7) == 7)
    }

    @Test func trialCountsDownAsDaysElapse() async throws {
        #expect(PremiumManager.trialDaysRemaining(start: date(daysAgo: 3), now: Date(), trialDays: 7) == 4)
        #expect(PremiumManager.isInTrial(start: date(daysAgo: 3), now: Date(), trialDays: 7))
    }

    @Test func trialExpiresOnTheFinalDayAndStaysExpired() async throws {
        #expect(!PremiumManager.isInTrial(start: date(daysAgo: 7),  now: Date(), trialDays: 7))
        #expect(!PremiumManager.isInTrial(start: date(daysAgo: 30), now: Date(), trialDays: 7))
        #expect(PremiumManager.trialDaysRemaining(start: date(daysAgo: 30), now: Date(), trialDays: 7) == 0)
    }

    // A start date in the future means the device clock moved backwards. That must not
    // read as more trial than a fresh install gets.
    @Test func trialNeverReportsMoreDaysThanTheTrialLength() async throws {
        let future = Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date()
        #expect(PremiumManager.trialDaysRemaining(start: future, now: Date(), trialDays: 7) == 7)
    }

    // The trial anchor has to survive deleting the app, so it lives in the Keychain
    // rather than UserDefaults — a UserDefaults anchor granted a new trial per reinstall.
    @Test func trialAnchorRoundTripsThroughTheKeychain() async throws {
        let anchor = date(daysAgo: 2)
        TrialAnchorStore.save(anchor)

        let loaded = try #require(TrialAnchorStore.load())

        // ISO8601 serialization drops sub-second precision.
        #expect(abs(loaded.timeIntervalSince(anchor)) < 1.0)
    }

}
