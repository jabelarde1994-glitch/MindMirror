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

}
